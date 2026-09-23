{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        # Hibernate writes RAM (32G) here; the headroom covers a poorly compressing image.
        swap = {
          priority = 2;
          size = "36G";
          content = {
            type = "swap";
            resumeDevice = true;
          };
        };
        root = {
          priority = 3;
          size = "187G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
        home = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/home";
          };
        };
      };
    };
  };
}
