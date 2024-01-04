<h1 align="center">iFirmware Parser</h1>
<h2 align="center">Multi parser and RAMDISK downloader</h2>
<p align="center">
  <a href="https://github.com/mast3rz3ro/ifirmware_parser/graphs/contributors" target="_blank">
    <img src="https://img.shields.io/github/contributors/mast3rz3ro/ifirmware_parser.svg" alt="Contributors">
  </a>
  <a href="https://github.com/mast3rz3ro/ifirmware_parser/commits/main" target="_blank">
    <img src="https://img.shields.io/github/commit-activity/w/mast3rz3ro/ifirmware_parser.svg" alt="Commits">
  </a>
</p>

---

# Features

1. Parse info from apple's firmwares json file
2. Parse firmware decryption keys from json file
3. Download firmware decryption keys
4. Download SSH RAMDISK files using pzb
5. Cross platform

# Requirements

* Bash environment.

# How to use (All Platforms):

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

# Important Notes

* Feel free to send a pull request.

# Credits

- [TheAppleWiki](https://theapplewiki.com) for providing decryption keys
- [jq](https://jqlang.github.io/jq/download/) Used for parsing json files
- [curl](https://curl.se/windows/) Used for downloading firmware keys
- [tihmstar](https://github.com/partialZipBrowser) for partialZipBrowser, a utility for downloading partial file from zip
- [libimobiledevice](htts://github.com/libimobiledevice/libimobiledevice) for plistutil, a utility for parsing plist files
- [sshrd_tools](https://github.com/mast3rz3ro/sshrd_tools) precompiled tools, this script uses only jq and pzb
- Firmware decryption keys download function are inspired from @meowcat454 script's 64bit-SSH-Ramdisk
- Thanks [@iam-theKid](https://github.com/iam-theKid) for making this [tool](https://github.com/iam-theKid/iOS-Firmware-Keys-Parser)