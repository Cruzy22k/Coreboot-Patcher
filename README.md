# Coreboot Patcher

## Prerequisites
To run this script, make sure that you have both your
- ChromeOS backup rom file, most likely created from mrchromebox's firmware utility script, renamed `backup.rom`

- A clean downloaded copy of your devices UEFI fullrom, eg. `https://www.mrchromebox.tech/files/firmware/full_rom/coreboot_edk2-pujjo-mrchromebox_20250427.rom`
renamed to `coreboot.rom`

## Usage

To use this tool, place your backup.rom and coreboot.rom in the same directory.

Then, run the following command from a command prompt in that directory.


`curl -LO raw.githubusercontent.com/Cruzy22k/Coreboot-Patcher/coreboot-patcher.sh && sudo bash coreboot-patcher.sh`

Follow the steps that the script prompts, and if it succeedes, you should have a modified coreboot.rom, 
which is your UEFI FULLROM for your device, containing both your VPD and HWID, ready to be flashed to your device with 

`Intel devices: sudo ./flashrom -p internal --ifd -i bios -w coreboot.rom -N"`

`AMD devices: sudo ./flashrom -p internal -w coreboot.rom`
    