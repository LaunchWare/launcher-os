# Repository quality gates, shared by the hooks in .githooks and runnable by
# hand as `nix run .#check`. The linters come from runtimeInputs, so they are
# pinned by this flake's lock rather than whatever is on PATH.

usage() {
  cat >&2 <<'EOF'
Usage: launcher-os-check [--staged] [--full]

  --staged  Check only the files in the git index, as .githooks/pre-commit does.
  --full    Also evaluate every nixosConfiguration. Costs ~30s and nix does not
            cache it, which is why only .githooks/pre-push turns it on.
EOF
}

staged=0
full=0
while [ "$#" -gt 0 ]; do
  case "$1" in
  --staged) staged=1 ;;
  --full) full=1 ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    printf 'launcher-os-check: unknown argument: %s\n\n' "$1" >&2
    usage
    exit 2
    ;;
  esac
  shift
done

cd "$(git rev-parse --show-toplevel)"

if [ -t 1 ]; then
  red=$'\033[31m'
  green=$'\033[32m'
  dim=$'\033[2m'
  reset=$'\033[0m'
else
  red=""
  green=""
  dim=""
  reset=""
fi

status=0
output=$(mktemp)
trap 'rm -f "$output"' EXIT

run_check() {
  label="$1"
  shift
  if "$@" >"$output" 2>&1; then
    printf '  %sok%s    %s\n' "$green" "$reset" "$label"
  else
    printf '  %sFAIL%s  %s\n' "$red" "$reset" "$label"
    sed 's/^/        /' "$output" >&2
    status=1
  fi
}

skip() {
  printf '  %s--    %s%s\n' "$dim" "$1" "$reset"
}

select_files() {
  if [ "$staged" -eq 1 ]; then
    git diff --cached --name-only --diff-filter=ACM -- "$@"
  else
    git ls-files -- "$@"
  fi
}

# hardware-configuration.nix is nixos-generate-config output: it is not
# nixfmt-shaped and it declares arguments it never uses. Reformatting it buys
# nothing and guarantees a conflict the next time the hardware is rescanned.
mapfile -t nix_files < <(select_files '*.nix' ':(exclude)hosts/*/hardware-configuration.nix')

mapfile -t lua_files < <(select_files '*.lua')

mapfile -t sh_files < <(select_files 'install/*.sh')

# writeShellApplication bodies, so the shell has to be named: they carry no
# shebang of their own. nixpkgs shellchecks these as well, but only while
# building the packages that embed them, and launch-or-focus pulls in 1.1 GiB
# of Hyprland to get there -- too steep a price for linting forty lines.
mapfile -t body_files < <(select_files 'bin/*' 'pkgs/*.sh')

mapfile -t workflow_files < <(select_files '.github/workflows/*.yml')

if [ "${#nix_files[@]}" -gt 0 ]; then
  run_check "nixfmt      ${#nix_files[@]} nix file(s)" nixfmt --check "${nix_files[@]}"
  run_check "deadnix     ${#nix_files[@]} nix file(s)" deadnix --fail "${nix_files[@]}"
  run_check "statix" statix check
else
  skip "nix         nothing in scope"
fi

if [ "${#sh_files[@]}" -gt 0 ]; then
  # SC1091 is install/ sourcing install/lib at runtime, which is deliberate.
  # The warnings left in that pre-Nix bootstrap predate the migration, so the
  # bar here is errors rather than a cleanup this hook would force.
  run_check "shellcheck  ${#sh_files[@]} script(s)" \
    shellcheck -e SC1091 --severity=error "${sh_files[@]}"
else
  skip "shellcheck  nothing in scope"
fi

if [ "${#body_files[@]}" -gt 0 ]; then
  run_check "shellcheck  ${#body_files[@]} script bod(ies)" \
    shellcheck -s bash -e SC1091 --severity=error "${body_files[@]}"
fi

# actionlint shells out to shellcheck for the run: blocks, which is already in
# runtimeInputs here.
if [ "${#workflow_files[@]}" -gt 0 ]; then
  run_check "actionlint  ${#workflow_files[@]} workflow(s)" actionlint "${workflow_files[@]}"
fi

if [ "${#lua_files[@]}" -gt 0 ]; then
  # Syntax only. The hypr config is hand-formatted and stylua disagrees with
  # all of it, so formatting Lua is not a gate.
  run_check "luac        ${#lua_files[@]} lua file(s)" luac -p "${lua_files[@]}"
else
  skip "luac        nothing in scope"
fi

if [ "$full" -eq 1 ]; then
  # Ambient nix on purpose: this should evaluate through the same daemon and
  # store that `los switch` will, not a second nix pinned inside this script.
  while read -r host; do
    run_check "eval        nixosConfigurations.$host" \
      nix eval --raw ".#nixosConfigurations.$host.config.system.build.toplevel.drvPath"
  done < <(nix eval --json '.#nixosConfigurations' --apply builtins.attrNames | jq -r '.[]')
fi

exit "$status"
