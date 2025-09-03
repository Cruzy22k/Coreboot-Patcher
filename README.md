# Coreboot Patcher
Coreboot-Patcher automates the injection of HWID and VPD data from a backup ROM into a clean MrChromebox Coreboot ROM. This ensures that vital product data and device identifiers are retained.

> [!NOTE]  
> This program is only meant for Chromebooks/Chromeboxes.
> It comes with ABSOLUTELY NO WARRANTY.


## Prerequisites
To run this script, make sure that you have both your
- ChromeOS backup rom file, most likely created from mrchromebox's firmware utility script, renamed `backup.rom`

- A clean downloaded copy of your devices UEFI fullrom, eg.
`https://www.mrchromebox.tech/files/firmware/full_rom/coreboot_edk2-pujjo-mrchromebox_20250427.rom`
renamed to `coreboot.rom`
- An internet connection.
- A brain (optional)
-----

## Usage

To use this tool, place your backup.rom and coreboot.rom in the same directory.

Then, run the following command from a command prompt in that directory.


```
curl -LO https://raw.githubusercontent.com/Cruzy22k/Coreboot-Patcher/main/coreboot-patcher.sh && bash coreboot-patcher.sh
```

Follow the steps that the script prompts, and if it succeedes, you should have a modified coreboot.rom, 
which is your **UEFI FullRom** for your device, containing both your VPD and HWID, ready to be flashed to your device with the commands listed at the bottom of this readme.

> [!CAUTION]  
> Flashing your own firmware has the potential to brick your device. Do not do this unless you are sure you know what you're doing and have a way to recover from a bad flash. Some level of knowledge with using the Linux command line is required.

> [!NOTE]  
> You need flashrom installed on the device
You can install it with
```
wget -O flashrom.tar.gz https://mrchromebox.tech/files/util/flashrom_ups_libpci37_20240418.tar.gz && tar -zxf flashrom.tar.gz && chmod +x flashrom
```

Intel devices:
------
 ```
 sudo ./flashrom -p internal --ifd -i bios -w coreboot.rom -N
 ```

AMD devices:
------
 ```
 sudo ./flashrom -p internal -w coreboot.rom
 ```
    
