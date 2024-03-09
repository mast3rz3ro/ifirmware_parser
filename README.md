# iFirmware Parser

*Parse firmware keys, and download SSH RAMDISK files.


## Features

1. Parse firmware decryption keys
2. Prepare SSH RAMDISK files
3. One time download
4. Cross platform

## Requirements

* Bash environment, libplist, partialZipBrowser, jq, curl

## How to get started?

```
$ git clone 'https://github.com/mast3rz3ro/ifirmware_parser'
$ cd ifirmware_parser
$ chmod +x './ifirmware_parser.sh'
$ ./ifirmware_parser.sh -h
```

* To see what variables returns the script use the debug switch:
```
$ ./ifirmware_parser.sh -p iphone9,3 -s 15 -d
```

* To download and store decryption keys use -k switch:
```
$ ./ifirmware_parser.sh -p iphone9,3 -s 15 -k
```

* To download decryption keys and ramdisk files use -r switch:
```
$ ./ifirmware_parser.sh -p iphone9,3 -s 15 -o 'somefolder' -r
```

* To use it in your shell script call it with source:

```
$ source ./ifirmware_parser.sh -p iphone9,3 -s 15 -o 'somefolder' -r
or even for searching the exact build
$ source ./ifirmware_parser.sh -p iphone9,3 -b 19H370 -o 'somefolder' -r
```

## Important Notes

* The Apple's firmwares file does not provide any firmwares for release candidate (RC).
* Currently Linux/MacOS users does not have a precompiled plistutil, thio this is not necessary.

## Credits

- [TheAppleWiki](https://theapplewiki.com) for providing decryption keys
- [jq](https://jqlang.github.io/jq/download/) Used for parsing json files
- [curl](https://curl.se/windows/) Used for downloading firmware keys
- [tihmstar](https://github.com/partialZipBrowser) for partialZipBrowser, a utility for downloading partial file from zip
- [libimobiledevice](htts://github.com/libimobiledevice/libimobiledevice) for plistutil, a utility for parsing plist files
- [sshrd_tools](https://github.com/mast3rz3ro/sshrd_tools) precompiled tools, this script uses only jq and pzb
- Firmware decryption keys download function are inspired from @meowcat454 script's 64bit-SSH-Ramdisk
- Thanks [@iam-theKid](https://github.com/iam-theKid) for making this [tool](https://github.com/iam-theKid/iOS-Firmware-Keys-Parser)