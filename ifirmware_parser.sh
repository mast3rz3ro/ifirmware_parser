#!/usr/bin/bash
		
		
		source ./misc/platform_check.sh
		
		####### Aligment note: #######
		#  Main statement 0 tab      #
		#  Sub statement 1 tabs      #
		#  Other commands 2 tabs     #
		##############################

		########################################
		# 	Written by: mast3rz3ro
		# 	Last Update: 24/12/2023
		########################################
		


		##############################
		#    Reset the variables     #
		##############################
	
	# Vars for check
	firmkeys_header=
	firmkeys_header2=
	debug_mode=
	update_mode=
	file_json=
	ramdisk_download=
	keys_download=
	
	# User input
	search_product=
	search_ios=
	
	# Parsed from json
	cpid_json=
	product_json=
	model_json=
	ios_json=
	build_json=
	ipsw_filename_json=
	ipsw_url_json=

	# Decryption keys
	ibec_iv=
	ibec_key=
	ibss_iv=
	ibss_key=
	iboot_iv=
	iboot_key=
	
	# Ramdisk files
	ibec_file=
	ibss_file=
	iboot_file=
	kernel_file=
	trustcache_file=
	devicetree_file=
	ramdisk_file=
	

		##############################
		#          Functions         #
		##############################

# Important note: functions must be declared first !

# Function 1 (firmware_keys.json parser file found on htttps://theapplewiki.com)
func_firmwarekeys_parser (){

		
		echo '[!] Checking the firmware_keys:' "$file_json"
		firmkeys_header=$($jq -c 'to_entries[] | select(.key | endswith("devicetree")) | .key' $file_json)
		firmkeys_header2=$($jq -c 'to_entries[] | select(.key | endswith("devicetree")) | .value.filename' $file_json | sed 's/"//g; s/\[//g; s/\]//g;')

if [ "$firmkeys_header" != '' ] && [ "$firmkeys_header" != 'null' ]; then
		product_json=$(echo $firmkeys_header | sed 's/.*(\([^_]*\)).*/\1/')
		model_json=$(echo $firmkeys_header2 | sed 's/.*\.\(.*\)\..*/\1/')
		build_json=$(echo $firmkeys_header | sed 's/.*_\([^_]*\)_.*/\1/')

	# If firmware_keys already exist then use it
	if [ -s 'misc/firmware_keys/'"$product_json"_"$model_json"_"$build_json"'.json' ]; then
		echo '[!] Using the firmware_keys:' "$file_json"
		file_json='misc/firmware_keys/'"$product_json"_"$model_json"_"$build_json"'.json'
	elif [ ! -s 'misc/firmware_keys/'"$product_json"_"$model_json"_"$build_json"'.json' ]; then
		echo '[-] Copying firmware_keys into folder'
		mkdir -p 'misc/firmware_keys'
		cp "$file_json" 'misc/firmware_keys/'"$product_json"_"$model_json"_"$build_json"'.json'
	fi
	
		echo '[-] Parsing... filenames'
		ibec_file=$($jq -c 'to_entries[] | select(.key | endswith("ibec")) | .value.filename' $file_json | sed 's/"//g; s/\[//g; s/\]//g' | tr 'I' 'i')
		ibss_file=$($jq -c 'to_entries[] | select(.key | endswith("ibss")) | .value.filename' $file_json | sed 's/"//g; s/\[//g; s/\]//g' | tr 'I' 'i')
		iboot_file=$($jq -c 'to_entries[] | select(.key | endswith("iboot")) | .value.filename' $file_json | sed 's/"//g; s/\[//g; s/\]//g' | tr 'I' 'i')
		kernel_file=$($jq -c 'to_entries[] | select(.key | endswith("kernelcache")) | .value.filename' $file_json | sed 's/"//g; s/\[//g; s/\]//g' | tr 'K' 'k')
		devicetree_file=$($jq -c 'to_entries[] | select(.key | endswith("devicetree")) | .value.filename' $file_json | sed 's/"//g; s/\[//g; s/\]//g')
		ramdisk_file=$($jq -c 'to_entries[] | select(.key | endswith("updateramdisk")) | .value.filename' $file_json | sed 's/"//g; s/\[//g; s/\]//g')
		trustcache_file="$ramdisk_file"'.trustcache'

		echo '[-] Parsing... decryption_keys'
		ibec_iv=$($jq -c 'to_entries[] | select(.key | endswith("ibec")) | .value.iv' $file_json | sed 's/"//g; s/\[//g; s/\]//g')
		ibec_key=$ibec_iv$($jq -c 'to_entries[] | select(.key | endswith("ibec")) | .value.key' $file_json | sed 's/"//g; s/\[//g; s/\]//g')
		ibss_iv=$($jq -c 'to_entries[] | select(.key | endswith("ibss")) | .value.iv' $file_json | sed 's/"//g; s/\[//g; s/\]//g;')
		ibss_key=$ibss_iv$($jq -c 'to_entries[] | select(.key | endswith("ibss")) | .value.key' $file_json | sed 's/"//g; s/\[//g; s/\]//g')
		iboot_iv=$($jq -c 'to_entries[] | select(.key | endswith("iboot")) | .value.iv' $file_json | sed 's/"//g; s/\[//g; s/\]//g;')
		iboot_key=$iboot_iv$($jq -c 'to_entries[] | select(.key | endswith("iboot")) | .value.key' $file_json | sed 's/"//g; s/\[//g; s/\]//g')
	
elif [ -s 'misc/firmware_keys/__.json' ]; then
		echo '[Error] Found wrong stored file!'
		echo '[!] Deleting file: misc/firmware_keys/__.json'
		rm -f 'misc/firmware_keys/__.json'
		echo '[Hint] Please put the firm_keys into working dir'
		exit
else
		echo "[Error] Couldn't find devicetree object."
		echo "[Hint] Please select the desired 'firmware_keys.json' file."
		exit
fi


	# Debug mode for firmwares parser
	if [ "$debug_mode" = 'YES' ] && [ "$keys_download" = 'YES' ]; then
		echo '[Debug] Printing variables...'
		echo '--------------------------------------------------'
		echo '- Device info:'
		echo 'ProductName ($product_json): '$product_json
		echo 'Model ($model_json): '$model_json
		echo 'Build ($build_json): '$build_json
		echo '--------------------------------------------------'
		echo '- Ramdisk Files:'
		echo 'iBEC Filename ($ibec_file): '$ibec_file
		echo 'iBSS Filename ($ibss_file): '$ibss_file 
		echo 'iBoot Filename ($iboot_file): '$iboot_file 
		echo 'Kernel Filename ($kernel_file): '$kernel_file
		echo 'Devicetree Filename ($devicetree_file): '$devicetree_file
		echo 'Ramdisk Filename ($ramdisk_file): '$ramdisk_file
		echo '--------------------------------------------------'
		echo '- Decryption keys:'
		echo 'iBEC ($ibec_key):'$ibec_key
		echo 'iBSS ($ibss_key):'$ibss_key
		echo 'iBoot ($iboot_key):'$iboot_key
		echo '--------------------------------------------------'
		echo
		echo "Note: To use these variables please call 'ifirmware_parser.sh' as source from any script."
	fi

}


# Function 2 (firmwares.json parser file found on official apple website)
func_firmware_parser (){
		
		# Below lines are only selects the first value of jq return (which is the last updated ios)
		echo '[-] Parsing... from stored firmwares.json file'
		ios_json=$($jq '.devices."'$search_product'".firmwares[] | select(."'$value_json'" | startswith("'$search_version'")) | .version' $file_json | sed -n 1p | sed 's/"//g')
		build_json=$($jq '.devices."'$search_product'".firmwares[] | select(."'$value_json'" | startswith("'$search_version'")) | .buildid' $file_json | sed -n 1p | sed 's/"//g')

	if [ "$ios_json" != '' ] && [ "$ios_json" != 'null' ] && [ "$build_json" != '' ] && [ "$build_json" != 'null' ]; then
		cpid_json=$($jq '.devices."'$search_product'".cpid' $file_json | sed 's/"//g' | tr [:upper:] [:lower:])
		cpid_json='0x'$(printf '%x' $cpid_json) # convert cpid from demical to hex
		
		model_json=$($jq '.devices."'$search_product'".BoardConfig' $file_json | sed 's/"//g' | tr [:upper:] [:lower:])
		ipsw_filename_json=$($jq '.devices."'$search_product'".firmwares[] | select(."'$value_json'" | startswith("'$search_version'")) | .filename' $file_json | sed -n 1p | sed 's/"//g')
		ipsw_url_json=$($jq '.devices."'$search_product'".firmwares[] | select(."'$value_json'" | startswith("'$search_version'")) | .url' $file_json | sed -n 1p | sed 's/"//g')
		
		product_json="$search_product" # rather than parsing again it's already set by user input
		major_ios=${ios_json:0:2}
		minor_ios=${ios_json:3:1}
		
	else
		echo "[Error] Couldn't find any result"
		echo '[Hint] Please make sure to enter a valid product name and version'
	exit
	fi
		

	# Debug mode for firmwares parser
	if [ "$debug_mode" = 'YES' ] && [ "$keys_download" != 'YES' ]; then
		echo '[Debug] Printing variables...'
		echo '--------------------------------------------------'
		echo '- Parsed from firmwares file:'
		echo 'Selected ProductName ($product_json):' "$product_json"
		echo 'Selected iOS ($ios_json):' "$ios_json"
		echo 'Selected Build ($build_json):' "$build_json"
		echo 'Selected Model ($model_json):' "$model_json"
		echo 'Selected CPID ($cpid_json):' "$cpid_json"
		echo 'iPSW ($ipsw_filename_json):' "$ipsw_filename_json"
		echo 'URL ($ipsw_url_json):' "$ipsw_url_json"
		echo '--------------------------------------------------'
		echo
		echo "Note: To use these variables please call 'ifirmware_parser.sh' as source from any script."
	fi
}


# Function 3 (Content downloader using pzb)
func_download_ramdisk (){

		echo '[!] Start downloading the ramdisk files...'
		
	if [ ! -s "$download_output"'/BuildManifest.plist' ]; then
		echo '[!] Downloading into:' "$download_output"'/BuildManifest.plist'
		"$pzb" -g 'BuildManifest.plist' "$ipsw_url_json" -o "$download_output"'/BuildManifest.plist'
	fi
	
	if [ ! -s "$download_output"'/Restore.plist' ]; then
		echo '[!] Downloading into:' "$download_output"'/Restore.plist'
		"$pzb" -g 'Restore.plist' "$ipsw_url_json" -o "$download_output"'/Restore.plist'
	fi
	
	if [ ! -s "$download_output"'/'"$ibec_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$ibec_file"
		"$pzb" -g 'Firmware/dfu/'"$ibec_file" "$ipsw_url_json" -o "$download_output"'/'"$ibec_file"
	fi
	
	if [ ! -s "$download_output"'/'"$ibss_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$ibss_file"
		"$pzb" -g 'Firmware/dfu/'"$ibss_file" "$ipsw_url_json" -o "$download_output"'/'"$ibss_file"
	fi
	
	if [ ! -s "$download_output"'/'"$iboot_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$iboot_file"
		"$pzb" -g 'Firmware/all_flash/'"$iboot_file" "$ipsw_url_json" -o "$download_output"'/'"$iboot_file"
	fi

	if [ ! -s "$download_output"'/'"$devicetree_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$devicetree_file"
		"$pzb" -g 'Firmware/all_flash/'"$devicetree_file" "$ipsw_url_json" -o "$download_output"'/'"$devicetree_file"
	fi
	
	if [ ! -s "$download_output"'/'"$trustcache_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$trustcache_file"
		"$pzb" -g 'Firmware/'"$trustcache_file" "$ipsw_url_json" -o "$download_output"'/'"$trustcache_file"
	fi

	if [ ! -s "$download_output"'/'"$kernel_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$kernel_file"
		"$pzb" -g "$kernel_file" "$ipsw_url_json" -o "$download_output"'/'"$kernel_file"
	fi
	
	if [ ! -s "$download_output"'/'"$ramdisk_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$ramdisk_file"
		"$pzb" -g "$ramdisk_file" "$ipsw_url_json" -o "$download_output"'/'"$ramdisk_file"
	fi
	if [ "$platform" = 'Darwin' ]; then
		# pzb output switch is currently broken in MacOS, this is a quick solution !
		echo '[!] PZB in Darwin cannot write output to another directory'
		echo '[-] Moving downloaded files into:' "$download_output"
		mv -f *.plist "$download_output"
		mv -f *.im4p "$download_output"
		mv -f kernelcache* "$download_output"
		mv -f *.trustcache "$download_output"
		mv -f *.dmg "$download_output"
	fi
	
		
		echo '[!] Checking downloaded files...'
		if [ ! -s "$download_output"'/BuildManifest.plist' ]; then echo 'Error missing:' "$download_output"'/BuildManifest.plist'; exit; fi
		if [ ! -s "$download_output"'/Restore.plist' ]; then echo '[!] Error missing:' "$download_output"'/Restore.plist'; exit; fi
		if [ ! -s "$download_output"'/'"$ibec_file" ]; then echo '[!] Error missing:' "$download_output"'/'"$ibec_file"; exit; fi
		if [ ! -s "$download_output"'/'"$ibss_file" ]; then echo '[!] Error missing:' "$download_output"'/'"$ibss_file"; exit; fi
		if [ ! -s "$download_output"'/'"$iboot_file" ]; then echo '[!] Warnning missing:' "$download_output"'/'"$iboot_file"; fi # not necessary for randisk boot
		if [ ! -s "$download_output"'/'"$devicetree_file" ]; then echo '[!] Error missing:' "$download_output"'/'"$devicetree_file"; exit; fi
		if [ ! -s "$download_output"'/'"$trustcache_file" ]; then echo '[!] Warnning missing:' "$download_output"'/'"$trustcache_file"; fi # not necessary for randisk boot
		if [ ! -s "$download_output"'/'"$kernel_file" ]; then echo '[!] Error missing:' "$download_output"'/'"$kernel_file"; exit; fi
		if [ ! -s "$download_output"'/'"$ramdisk_file" ]; then echo '[!] Error missing:' "$download_output"'/'"$ramdisk_file"; exit; fi
		
		echo '[!] Download completed !'
		
}


# Function 4 (Download firmware keys from https://theapplewiki.com)
func_download_keys (){

	file_json='misc/firmware_keys/'"$product_json"_"$model_json"_"$build_json"'.json'
	if [ ! -d 'misc/firmware_keys' ]; then mkdir -p 'misc/firmware_keys'; fi
		
if [ -s 'misc/firmware_keys/'"$product_json"_"$model_json"_"$build_json"'.json' ]; then
		func_firmwarekeys_parser # call function
		return
		
elif [ ! -s 'misc/firmware_keys/'"$product_json"_"$model_json"_"$build_json"'.json' ]; then
		
		echo '[!] Decryption keys not found !'
		
if [ "$plistutil" != '' ]; then
		# MacOS and Linux currently does not have plistutil
		# In case you are wondering downloading 'BuildManifest.plist' are usually smaller size than downloading the whole website
		echo '[!] Downloading BuildManifest.plist ...'
		"$pzb" -g 'BuildManifest.plist' "$ipsw_url_json" -o 'misc/firmware_keys/BuildManifest.plist'
		if [ ! -s 'misc/firmware_keys/BuildManifest.plist' ]; then echo '[!] Error could not download the BuildManifest.plist'; exit 1; fi
		
		echo '[-] Parsing firmware codename...'
		firm_codename=$($plistutil -p 'misc/firmware_keys/BuildManifest.plist' | grep 'BuildTrain' -m 1 | awk -F '",' '{print $1}' | awk -F ': "' '{print $2}')
		tmp_url='https://theapplewiki.com/index.php?title=Keys:'"$firm_codename"_"$build_json"_'('"$product_json"')'
else
		echo '[!] Fetching firmware keys url...'
		tmp_url=$(curl -m 120 -s 'https://theapplewiki.com/wiki/Firmware_Keys/'"$major_ios"'.x' | grep "$build_json" | grep "$product_json" -m 1 | awk -F 'href="' '{print $2}' | awk -F '" title' '{print $1}')
		
		# Fix url name, this can be removed if parsing the value with awk is improved (you should try it to understand the issue) !
	if [[ "$tmp_url" != 'https://theapplewiki.com/wiki/'* ]] && [[ "$tmp_url" = '/wiki/'* ]]; then
		tmp_url='https://theapplewiki.com'"$tmp_url"
	fi
fi	

if [[ "$tmp_url" = 'https://theapplewiki.com/'* ]]; then
		echo '[-] Fetching json url ...'
		tmp_url2=$(curl -m 120 -s "$tmp_url" | grep 'keypage-json-keys' | awk -F 'searchlabel%3DKeys/type%3Dsimple' '{print $1}' | awk -F 'keypage-json-keys' '{print $2}' | awk -F 'href="' '{print $2}')
		direct_json_link="$tmp_url2"'searchlabel%3DKeys/type%3Dsimple'
		
		# Fix url in case needed !
	if [[ "$direct_json_link" != 'https://theapplewiki.com/wiki/'* ]] && [[ "$direct_json_link" = '/wiki/'* ]]; then
		direct_json_link='https://theapplewiki.com'"$direct_json_link"
	fi
fi
	if [ "$direct_json_link" != '' ]; then
		echo '[-] Downloading into:' "$file_json" '...'
		curl -m 120 -s "$direct_json_link" -o "$file_json"
	else
		echo '[!] An error occurred while trying to download the firmware keys.'
		echo 'DEBUG ------------------------------'
		echo '[!] Temp URL:' "$tmp_url"
		echo '[!] Temp URL 2 (null should mean not available):' "$tmp_url2"
		echo '[!] Direct link:' "$direct_json_link"
		echo '[!] Store file as:' "$file_json"
		echo 'DEBUG ------------------------------'
		exit 1
	fi
	
	if [ -s "$file_json" ]; then
		echo '[-] Validating:' "$file_json" '...'
		compare_build=$(grep -o "$build_json" "$file_json" | sed -n 1p)
	else
		echo '[!] An error occurred file is empty !'
		echo '[!] Target file:' "$file_json"
		exit 1
	fi
		
	if [ "$compare_build" = "$build_json" ]; then
		echo '[!] File saved as:' "$file_json"
		func_firmwarekeys_parser # call function
	else
		echo '[!] An error occurred file is corrupted !'
		echo '[-] Parsed value:' "$compare_build"
		echo '[-] Target BuildID:' "$build_json"
		exit 1
	fi
		
fi
		
}


		##############################
		#       Switches Stage       #
		##############################

	echo [-] Starting iFirmware Parser...
	
	if [ "$1" = '' ]; then echo "[!] To see the switchs please use 'ifirmware_parser.sh -h'"; fi
	
	if [ "$1" = '-h' ] || [ "$1" = '-help' ] || [ "$1" = '--help' ]; then
		echo '------------------------------'
		echo "Description: Parsers the important values for creating sshrd ramdisk,
		from apple's firmwares.json and firmware_keys.json files.
		Decryption keys can be found on TheAppleWiki (https://theapplewiki.com)"
		echo
		echo 'Usage:'
		echo '    ifirmware_parser.sh arguments (--debug optional) or source ifirmware_parser.sh arguments (--debug optional)'
		echo
		echo
		echo 'Switches:'
		echo '-u/--update     Update firmwares.json database'
		echo '-p/--product    Select Product name (Example: -p iPhone9,3 or -p iphone9,3)'
		echo '-s/--ios        Search by iOS Version (Example: -s 15 or --ios 15.8)'
		echo '-b/--build      Search by Build number (Example: -b 19H or --build 19H370)'
		echo '-o/--output     Where to store downloaded ramdisk files.'
		echo '-k/--keys       Download and store firmware keys.'
		echo '-r/--ramdisk    Download ramdisk files.'
		echo '-d/--debug      Determining the vars for later use (optional).'
		echo '-h/--help       Show this message.'
		echo
		echo 'Examples:'
		echo '       ifirmware_parser.sh -u (update the firmwares database)'
		echo '       ifirmware_parser.sh somefile.json (Parse directly from firmware_keys.json file)'
		echo '       ifirmware_parser.sh -p iphone9,3 -s 15 (Parse latest iOS 15 info)'
		echo '       ifirmware_parser.sh -p iphone9,3 -b 19H370 -k (Download firmware keys for this exact build)'
		echo '       ifirmware_parser.sh -p iphone9,3 -s 15 -o somefolder -r (Download ramdisk files for latest iOS 15)'
		echo
		echo '------------------------------'
	exit
	fi 


		########## This section requires improvement ##########

		while true; do
		case "$1" in
        *".json") file_json="$1"; shift;;
        -o|--output) download_output="$2"; shift;;
        -p|--product) search_product=$(echo $2 | tr 'p' 'P'); shift;;
        -s|--ios) search_version="$2"; value_json='version'; shift;;
        -b|--build) search_version="$2"; value_json='buildid'; shift;;
		#-k|-keys) keys_download="YES"; shift;;
		#-r|-ramdisk) ramdisk_download="YES"; shift;;
        #-d|-debug) debug_mode="YES"; shift;;
        *) break
		esac
		shift
		done
		
	if [[ $1 = '-k' || $2 = '-k' || $3 = '-k' || $4 = '-k' || $5 = '-k' || $6 = '-k' ]]; then keys_download="YES"; fi
	if [[ $1 = '--keys' || $2 = '--keys' || $3 = '--keys' || $4 = '--keys' || $5 = '--keys' || $6 = '--keys' ]]; then keys_download="YES"; fi
	
	if [[ $1 = '-r' || $2 = '-r' || $3 = '-r' || $4 = '-r' || $5 = '-r' || $6 = '-r' ]]; then ramdisk_download="YES"; fi
	if [[ $1 = '--ramdisk' || $2 = '--ramdisk' || $3 = '--ramdisk' || $4 = '--ramdisk' || $5 = '--ramdisk' || $6 = '--ramdisk' ]]; then ramdisk_download="YES"; fi
	
	if [[ $1 = '-d' || $2 = '-d' || $3 = '-d' || $4 = '-d' || $5 = '-d' || $6 = '-d' ]]; then debug_mode="YES"; fi
	if [[ $1 = '--debug' || $2 = '--debug' || $3 = '--debug' || $4 = '--debug' || $5 = '--debug' || $6 = '--debug' ]]; then debug_mode="YES"; fi
	
	if [[ $1 = '-u' || $2 = '-u' || $3 = '-u' || $4 = '-u' || $5 = '-u' || $6 = '-u' ]]; then update_mode="YES"; fi
	if [[ $1 = '--update' || $2 = '--update' || $3 = '--update' || $4 = '--update' || $5 = '--update' || $6 = '--update' ]]; then update_mode="YES"; fi



		########## Quick checks ##########

if [ "$update_mode" = 'YES' ]; then
		echo '[-] Updating firmware database ...'
		echo '[-] Downloading from: https://api.ipsw.me/v2.1/firmwares.json/condensed'
		curl -m 120 -s 'https://api.ipsw.me/v2.1/firmwares.json/condensed' -o 'misc/firmwares_new.json'
	if [ -s 'misc/firmwares_new.json' ]; then
		echo '[-] Validating:' 'misc/firmwares_new.json'
		# Why this exactly ? iTunes 10.5.3 (Windows) should be always the last value at EOF !
		check=$($jq '.iTunes.Windows[].version | select(. | startswith("10.5.3"))' './misc/firmwares_new.json' | sed 's/"//g')
	else
		echo '[!] Error file is empty'
		echo '[-] Update failed !'
		exit 1
	fi
	if [ "$check" = '10.5.3' ]; then
		echo '[!] Backing-up old database ...'
		cp -f 'misc/firmwares.json' 'misc/firmwares_bak'
		echo '[!] Overwriting old database ...'
		cp -f 'misc/firmwares_new.json' 'misc/firmwares.json'
		rm -f 'misc/firmwares_new.json'
		echo '[!] Update completed !'
		exit
	else
		echo '[!] Error file is corrupted !'
		echo '[!] Update failed !'
		rm -f 'misc/firmwares_new.json'
		exit 1
	fi
fi
	
if [ ! -s 'misc/firmwares.json' ]; then
		echo "[Error] Couldn't find 'misc/firmwares.json'"
		exit
		
		# If file input by user not exist
	elif [ "$file_json" != '' ] && [ ! -s "$file_json" ] && [ "$search_version" = '' ] && [ "$value_json" = '' ]; then
		echo "[Error] Couldn't find the target file."
		echo '[Hint] Please select a correct path to firmware_keys.json file.'
		echo '[?] Your path:' $file_json
		exit
fi	

		# Check if firm_keys been throwin for parse
if  [ -s "$file_json" ] && [ "$search_version" = '' ] && [ "$value_json" = '' ]; then
		func_firmwarekeys_parser # call function
		return 2>/dev/null
		exit
		
		# Parse without keys
	elif [ "$keys_download" != 'YES' ] && [ "$ramdisk_download" != 'YES' ] && [ "$search_version" != '' ] && [ "$value_json" != '' ]; then
		file_json='misc/firmwares.json'
		func_firmware_parser # call function
		return 2>/dev/null
		exit

		# Check if is download firmware keys is requested
	elif [ "$keys_download" = 'YES' ] && [ "$search_version" != '' ] && [ "$value_json" != '' ]; then
		file_json='misc/firmwares.json'
		func_firmware_parser # call function
		func_download_keys # call function
		return 2>/dev/null
		exit
		
		# Check if is download ramdisk files is requested
	elif [ "$ramdisk_download" = 'YES' ] && [ "$search_version" != '' ] && [ "$value_json" != '' ]; then
	if [ "$download_output" = '' ]; then
		echo '[Error] Output directory are not set'
		echo '[Hint] Please enter a valid directory for output'
		echo '[!] The directory you chose:' "'$download_output'"
		exit
	elif [ ! -d "$download_output" ]; then
		echo '[-] Creating output directory ...'
		mkdir -p "$download_output"
	fi
		file_json='misc/firmwares.json'
		func_firmware_parser # call function
		func_download_keys # call function
		func_download_ramdisk # call function
		return 2>/dev/null
		exit
		
fi

echo '[!] End of script, maybe too many or wrong arguments?'
