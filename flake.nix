{
  description = "FoxOS Large Assets Repository";
  
  outputs = { self }: {
    # Export asset paths
    assets = {
      grub = self + "/grub";
      refind = self + "/refind";
      plymouth = self + "/plymouth";
      systemd = self + "/systemd";
      common = self + "/common";
    };
  };
}
