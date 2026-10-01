{ config, lib, ... }:
let
  cfg = config.launcher-os.laptop;
in
{
  options.launcher-os.laptop.enable = lib.mkEnableOption "laptop power management";

  config = lib.mkIf cfg.enable {
    # TLP instead of power-profiles-daemon. PPD's "balanced" profile sets
    # energy_performance_preference=balance_power on battery, which parks the
    # CPU at base clock: measured 2.2 GHz peak (decaying to 1.7 GHz as work
    # lands on E-cores) on a 5.0 GHz i7-1360P, at 48 C with the RAPL limit
    # sitting at 64 W. Nothing was throttling, it simply never ramped. Short
    # interactive bursts -- a keystroke through the compositor and back -- are
    # exactly the workload that punishes, so typing feels late. PPD 0.30 has no
    # setting between balance_power and full performance, and no config file to
    # add one. TLP does.
    services.tlp = {
      enable = true;
      settings = {
        # intel_pstate wants to stay on its own "powersave" governor; the EPP
        # values below are what actually set the performance/efficiency bias.
        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # balance_performance ramps eagerly for short bursts but still backs off
        # under sustained load, so the battery cost is small -- a keystroke
        # finishes in milliseconds either way, and racing to idle is often the
        # cheaper path. On AC there is no battery to protect.
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_performance";

        # Keep turbo available on battery; TLP otherwise defers to firmware.
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;

        # DYTC, via thinkpad_acpi. This is the knob the firmware actually reads.
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";

        # TLP's battery defaults are more aggressive than PPD's were. These two
        # buy power by adding latency, which is the thing we came here to fix,
        # so hold them at the kernel defaults rather than let TLP tighten them.
        WIFI_PWR_ON_BAT = "off";
        PCIE_ASPM_ON_BAT = "default";
      };
    };

    # Mutually exclusive with TLP, and the NixOS module asserts on it.
    services.power-profiles-daemon.enable = false;

    # No thermald: it refuses to start on this machine and exits after ~28 ms.
    #   [WARN][/sys/devices/platform/thinkpad_acpi/dytc_lapmode] present:
    #   Thermald can't run on this platform
    # That is deliberate upstream behaviour -- on a ThinkPad the firmware owns
    # thermal management through DYTC, so thermald steps aside. Enabling it here
    # only ever added a failed unit to every boot.

    services.upower.enable = true;
  };
}
