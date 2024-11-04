#!/usr/bin/env bash
		
		
		source ./misc/platform_check.sh
		
		####### Aligment note: #######
		#  Main statement 0 tab      #
		#  Sub statement 1 tabs      #
		#  Other commands 2 tabs     #
		##############################

		################################################
		# 	Author: mast3rz3ro                         #
		# 	MIT License Copyright (c) 2024 mast3rz3ro  #
		################################################
		


		##############################
		#    Reset the variables     #
		##############################
	
	# Vars for check
	firmkeys_header=
	debug_mode=
	update_mode=
	file_json=
	ramdisk_download=
	keys_download=
	multi_model=
	model_ver1=
	model_ver2=
	
	# User input
	search_product=
	search_ios=
	
	# Parsed from json
	cpid=
	product_name=
	product_model=
	ios_version=
	build_version=
	ipsw_filename=
	ipsw_url=

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
	if [ "$multi_model" = 'yes' ] && [ "$search_model" = "$model_ver2" ]; then
		head_number="2"
	else
		head_number=""
	fi
		firmkeys_header=$($jq -c 'to_entries[] | select(.key | endswith("#ibec'$head_number'")) | .key' $file_json)
if [ "$firmkeys_header" != '' ] && [ "$firmkeys_header" != 'null' ]; then
		product_name=$(echo $firmkeys_header | sed 's/.*(\([^_]*\)).*/\1/')
		build_version=$(echo $firmkeys_header | sed 's/.*_\([^_]*\)_.*/\1/')

	# If firmware_keys already exist then use it
	if [ -s 'misc/firmware_keys/'"$product_name"_"$build_version"'.json' ]; then
		echo '[!] Using the firmware_keys:' "$file_json"
		file_json='misc/firmware_keys/'"$product_name"_"$build_version"'.json'
	elif [ ! -s 'misc/firmware_keys/'"$product_name"_"$build_version"'.json' ]; then
		echo '[-] Copying firmware_keys into folder'
		mkdir -p 'misc/firmware_keys'
		cp "$file_json" 'misc/firmware_keys/'"$product_name"_"$build_version"'.json'
	fi

		echo '[-] Parsing... decryption_keys'
		ibec_iv=$($jq -c 'to_entries[] | select(.key | endswith("ibec")) | .value.iv' $file_json | sed 's/"//g; s/\[//g; s/\]//g')
		ibec_key=$ibec_iv$($jq -c 'to_entries[] | select(.key | endswith("ibec")) | .value.key' $file_json | sed 's/"//g; s/\[//g; s/\]//g')
		ibss_iv=$($jq -c 'to_entries[] | select(.key | endswith("ibss")) | .value.iv' $file_json | sed 's/"//g; s/\[//g; s/\]//g;')
		ibss_key=$ibss_iv$($jq -c 'to_entries[] | select(.key | endswith("ibss")) | .value.key' $file_json | sed 's/"//g; s/\[//g; s/\]//g')
		iboot_iv=$($jq -c 'to_entries[] | select(.key | endswith("iboot")) | .value.iv' $file_json | sed 's/"//g; s/\[//g; s/\]//g;')
		iboot_key=$iboot_iv$($jq -c 'to_entries[] | select(.key | endswith("iboot")) | .value.key' $file_json | sed 's/"//g; s/\[//g; s/\]//g')	
		
		# Set the variables in case other parameters is used
		search_product="$product_name"
		search_version="$build_version"
		value_json='buildid'
	
elif [ -s 'misc/firmware_keys/__.json' ]; then
		echo '[e] Found wrong stored file!'
		echo '[!] Deleting file: misc/firmware_keys/__.json'
		rm -f 'misc/firmware_keys/__.json'
		echo '[!] Please put the firm_keys into working dir'
		exit
else
		echo "[e] Couldn't find #ibec object."
		echo "[!] Please select the desired 'firmware_keys.json' file."
		exit
fi

}


# Function 2 (firmwares.json parser file found on official apple website)
func_firmware_parser (){
		
		# Below lines are only selects the first value of jq return (which is the last updated ios)
		echo '[-] Parsing device info (from firmwares.json)...'
		ios_version=$($jq '.devices."'$search_product'".firmwares[] | select(."'$value_json'" | startswith("'$search_version'")) | .version' $file_json | sed -n 1p | sed 's/"//g')
		build_version=$($jq '.devices."'$search_product'".firmwares[] | select(."'$value_json'" | startswith("'$search_version'")) | .buildid' $file_json | sed -n 1p | sed 's/"//g')

if [ "$ios_version" != '' ] && [ "$ios_version" != 'null' ] && [ "$build_version" != '' ] && [ "$build_version" != 'null' ]; then
		cpid=$($jq '.devices."'$search_product'".cpid' $file_json | sed 's/"//g' | tr [:upper:] [:lower:])
		cpid='0x'$(printf '%x' $cpid) # convert cpid from demical to hex
		product_model=$($jq '.devices."'$search_product'".BoardConfig' $file_json | sed 's/"//g' | tr [:upper:] [:lower:])
	if [ "$search_product" = 'iPhone8,1' ] || [ "$search_product" = 'iPhone8,2' ] || [ "$search_product" = 'iPhone8,4' ] || [ "$search_product" = 'iPad6,11' ] || [ "$search_product" = 'iPad6,12' ]; then
		# Apple's firmwares.json only stores on model per product name
		# the actual model name will be parsed from BuildManifest.plist found in iPSW file
		# I could't implement way better than @meowcat454 method, i admit it
		# the case is these 5 product models has different model versions
		# and the buildmanifest could contain 4, 8 or 12 models version
		multi_model='yes'
	fi
		
		ipsw_filename=$($jq '.devices."'$search_product'".firmwares[] | select(."'$value_json'" | startswith("'$search_version'")) | .filename' $file_json | sed -n 1p | sed 's/"//g')
		ipsw_url=$($jq '.devices."'$search_product'".firmwares[] | select(."'$value_json'" | startswith("'$search_version'")) | .url' $file_json | sed -n 1p | sed 's/"//g')
		
		product_name="$search_product" # rather than parsing again it's already set by user input
		major_ios=${ios_version:0:2}
		minor_ios=${ios_version:3:1}
		
###############################################################################################
		if [ ! -d './misc/build_manifest' ]; then mkdir -p './misc/build_manifest'; fi
		build_manifest="./misc/build_manifest/"$product_name"_"$ios_version"_"$build_version".plist"
	if [ ! -s "$build_manifest" ]; then
		echo '[!] Downloading: BuildManifest.plist ...'
		"$pzb" -g 'BuildManifest.plist' "$ipsw_url" -o "$build_manifest"
	fi
	if [ ! -s "$build_manifest" ]; then
		# [bug] pzb output switch in macos are broken !
		echo '[!] PZB in macOS/Linux cannot write output to another directory'
	if [ -s "./"$product_name"_"$ios_version"_"$build_version".plist" ]; then # current dir
		echo '[-] Moving from:' "./"$product_name"_"$ios_version"_"$build_version".plist"
		mv -f "./"$product_name"_"$ios_version"_"$build_version".plist" './misc/build_manifest/'
	fi
	fi
	
	# check again if build manifest is downloaded
	if [ ! -s "$build_manifest" ]; then
		echo '[!] Downloading has failed !'
		exit 1
	fi

if [ "$multi_model" = 'yes' ] && [ -s "$build_manifest" ]; then
		echo '[-] Found BuildManifest:' "$build_manifest"
		echo '[-] Checking model versions ...'
		models_ver=$(grep '<string>'"${product_model:0:2}" "$build_manifest" | awk -F '>' '{print $2}' | awk -F '<' '{print $1}')
		model_ver1=$(echo "$models_ver" | sed -n 1p)
		model_ver2=$(echo "$models_ver" | sed -n 2p)
	if [ "$search_model" != '' ]; then
	if [ "$search_model" = "$model_ver1" ] || [ "$search_model" = "$model_ver2" ]; then
		product_model="$search_model"
	elif [ "$search_model" != "$model_ver1" ] || [ "$search_model" != "$model_ver2" ]; then
		echo '[e] The model you selected:' "'$search_model'" 'does not matches' "'$model_ver1'" 'or' "'$model_ver2'"
		echo '[-] Available models for' "$product_name": "'$model_ver1'" "'$model_ver2'"
		#echo '[-] Possible model versions (ignore duplicated):' "$models_ver" | tr '\n' ' '
		exit 1
	fi
	elif [ "$search_model" = '' ]; then
		echo '[!] Please select your exact device model using -m switch'
		echo '[-] Available models for' "'$product_name'": "'$model_ver1'" "'$model_ver2'"
		exit 1
	else
		echo '[e] Could not detect model version'
		exit 1
	fi
fi
###############################################################################################

##############################################################################################
		filenames="./misc/firmware_keys/"$product_name"_"$build_version".log"
if [ ! -s "$filenames" ]; then
		# generate map file for getting ramdisk file names
		if [ ! -d './misc/firmware_keys' ]; then mkdir -p './misc/firmware_keys'; fi
		echo '[-] Getting list of ramdisk files ...'
		"$pzb" -l "$ipsw_url" > "$filenames"
fi
if [ "$(grep -Fc 'Error init failed' "$filenames")" != "0" ]; then
		echo "Error: connection was lost during filenames generate."
		echo "Please try again."
		printf "">"$filenames" # remove file without using rm
		exit 1
fi

if [ -s "$filenames" ]; then
		echo '[-] Parsing... filenames'
		hw_model=${product_model:0:3}
		firmkeys_header=$(grep iBEC.*$hw_model "$filenames" | grep -cv '.plist')
	if [ "$firmkeys_header" = '0' ]; then # if returned 0 means iboot has different name
		hw_model=''
		files_list=$(cat "$filenames" | awk -F 'f ' '{print $2}' | awk -F '.plist' '{print $1}' | tr '\n\r' ' ')
	elif [ "$firmkeys_header" = '1' ]; then # if returned 1 means match succeed
		files_list=$(cat "$filenames" | awk -F 'f ' '{print $2}' | awk -F '.plist' '{print $1}' | tr '\n\r' ' ')
	elif [ "$firmkeys_header" = '2' ]; then # if returned 2 means more models to deal with
		hw_model=${product_model:0:4}
			if [ "${hw_model:3:1}" = "a" ]; then # prevent parsing as n66a when model is n66ap
				hw_model=${product_model:0:3}
			fi
		files_list=$(cat "$filenames" | awk -F 'f ' '{print $2}' | awk -F '.plist' '{print $1}' | tr '\n\r' ' ')
	else
		printf -- "- Error unexpected model\n   Your device model is: '$product_model'\n Search pattern is: '$hw_model'\n"
		exit 100
	fi
	if [ "$product_name" = "iPad4,4" ] || [ "$product_name" = "iPad4,5" ] || [ "$product_name" = "iPad4,6" ]; then
		dummy_var="b" # ipad mini uses b suffix, while ipad air don't
	fi
		ibec_file=$(printf -- "$files_list" | tr ' ' '\n' | grep iBEC.*${hw_model}${dummy_var} | sed -n 1p | awk -F 'iBEC.' '{$1="iBEC."; print $1$2}')
		ibss_file=$(printf -- "$files_list" | tr ' ' '\n' | grep iBSS.*${hw_model}${dummy_var} | sed -n 1p | awk -F 'iBSS.' '{$1="iBSS."; print $1$2}')
		iboot_file=$(printf -- "$files_list" | tr ' ' '\n' | grep iBoot.*${hw_model}${dummy_var} | sed -n 1p | awk -F 'iBoot.' '{$1="iBoot."; print $1$2}')

		# Parse kernelcache file
		dummy_var=$(echo $files_list | tr ' ' '\n' | grep -c kernelcache) # check if there is more than one kernelcahce
	if [ "$dummy_var" = '1' ]; then
		kernel_file=$(echo $files_list | tr ' ' '\n' | grep kernelcache)
	elif [ "$dummy_var" = '2' ]; then
		dummy_var=$(echo $product_name | tr ' ' '\n' | grep -o [1-9] | sed -n 1p) # get first digit from product name e.g iphone10,4 will return 1
		if [ "$product_name" = "iPad4,4" ] || [ "$product_name" = "iPad4,5" ] || [ "$product_name" = "iPad4,6" ]; then
			dummy_var="b" # ipad mini uses b suffix, while ipad air don't
		fi
		kernel_file=$(echo $files_list | tr ' ' '\n' | grep -o kernelcache*.*"$dummy_var" | sed -n 1p)
	else
		echo '[e] Cannot parse the kernel filename !'
		exit 1
	fi
		devicetree_file=$(echo $files_list | tr ' ' '\n' | grep DeviceTree."$product_model" | sed '/plist/d' | awk -F 'DeviceTree.' '{print $2}' | sed -n 1p)
		devicetree_file='DeviceTree.'"$devicetree_file"
		#ramdisk_file=$(echo $files_list | tr ' ' '\n' | grep .dmg$ | sed -n 1p) # after sorting scheme is: update --> root --> restore
		#ramdisk_file=$(echo $files_list | tr ' ' '\n' | grep .dmg$ | sed -n 2p) # the update ramdisk should be always the second :-
	if [ "$(echo $files_list | tr ' ' '\n' | grep .dmg$ | wc -l)" = "5" ]; then
		ramdisk_file=$(echo $files_list | tr ' ' '\n' | grep .dmg$ | sed -n 3p)
	fi
		trustcache_file="$ramdisk_file"'.trustcache'
		return
fi
##############################################################################################
		
else
		echo "[e] Couldn't find any result"
		echo '[!] Please make sure to enter a valid product name and version'
	exit
	fi

}


# Function 3 (Content downloader using pzb)
func_download_ramdisk (){

		# override output for better orgnaise
		download_output="$download_output/${product_name}_${product_model}_${build_version}"
		mkdir -p "$download_output"
		echo '[!] Start downloading the ramdisk files...'

	if [ ! -s "$download_output"'/'"$ibec_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$ibec_file"
		"$pzb" -g 'Firmware/dfu/'"$ibec_file" "$ipsw_url" -o "$download_output"'/'"$ibec_file"
	fi
	if [ ! -s "$download_output"'/'"$ibss_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$ibss_file"
		"$pzb" -g 'Firmware/dfu/'"$ibss_file" "$ipsw_url" -o "$download_output"'/'"$ibss_file"
	fi
	
	if [ ! -s "$download_output"'/'"$iboot_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$iboot_file"
		"$pzb" -g 'Firmware/all_flash/'"$iboot_file" "$ipsw_url" -o "$download_output"'/'"$iboot_file"
	fi

	if [ ! -s "$download_output"'/'"$devicetree_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$devicetree_file"
		"$pzb" -g 'Firmware/all_flash/'"$devicetree_file" "$ipsw_url" -o "$download_output"'/'"$devicetree_file"
	fi
	
	if [ ! -s "$download_output"'/'"$trustcache_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$trustcache_file"
		"$pzb" -g 'Firmware/'"$trustcache_file" "$ipsw_url" -o "$download_output"'/'"$trustcache_file"
	fi

	if [ ! -s "$download_output"'/'"$kernel_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$kernel_file"
		"$pzb" -g "$kernel_file" "$ipsw_url" -o "$download_output"'/'"$kernel_file"
	fi
	
	if [ ! -s "$download_output"'/'"$ramdisk_file" ]; then
		echo '[!] Downloading into:' "$download_output"'/'"$ramdisk_file"
		"$pzb" -g "$ramdisk_file" "$ipsw_url" -o "$download_output"'/'"$ramdisk_file"
	fi

		# [bug] pzb output switch is currently broken in MacOS, this is a quick solution !
		echo '[!] PZB in macOS/Linux cannot write output to another directory'
		echo '[-] Moving downloaded files into:' "$download_output"
		if [ -s "./$ibec_file" ]; then mv -f "./$ibec_file" "$download_output"; fi
		if [ -s "./$ibss_file" ]; then mv -f "./$ibss_file" "$download_output"; fi
		if [ -s "./$iboot_file" ]; then mv -f "./$iboot_file" "$download_output"; fi
		if [ -s "./$devicetree_file" ]; then mv -f "./$devicetree_file" "$download_output"; fi
		if [ -s "./$trustcache_file" ]; then mv -f "./$trustcache_file" "$download_output"; fi
		if [ -s "./$kernel_file" ]; then mv -f "./$kernel_file" "$download_output"; fi
		if [ -s "./$ramdisk_file" ]; then mv -f "./$ramdisk_file" "$download_output"; fi
	
		
		echo '[!] Checking downloaded files...'
		if [ ! -s "$download_output"'/'"$ibec_file" ]; then echo '[e] File is missing:' "$download_output"'/'"$ibec_file"; exit; fi
		if [ ! -s "$download_output"'/'"$ibss_file" ]; then echo '[e] File is missing:' "$download_output"'/'"$ibss_file"; exit; fi
		if [ ! -s "$download_output"'/'"$iboot_file" ]; then echo '[!] File is missing:' "$download_output"'/'"$iboot_file"; fi # not necessary for randisk boot
		if [ ! -s "$download_output"'/'"$devicetree_file" ]; then echo '[e] File is missing:' "$download_output"'/'"$devicetree_file"; exit; fi
		if [ ! -s "$download_output"'/'"$trustcache_file" ]; then echo '[!] File is missing:' "$download_output"'/'"$trustcache_file"; fi # not necessary for randisk boot
		if [ ! -s "$download_output"'/'"$kernel_file" ]; then echo '[e] File is missing:' "$download_output"'/'"$kernel_file"; exit; fi
		if [ ! -s "$download_output"'/'"$ramdisk_file" ]; then echo '[e] File is missing:' "$download_output"'/'"$ramdisk_file"; exit; fi
		
		echo '[!] Download completed !'
		
}


# Function 4 (Download firmware keys from https://theapplewiki.com)
func_download_keys (){

	file_json='misc/firmware_keys/'"$product_name"_"$build_version"'.json'
	if [ ! -d 'misc/firmware_keys' ]; then mkdir -p 'misc/firmware_keys'; fi
		
if [ -s "$file_json" ]; then
		func_firmwarekeys_parser # call function
		return
		
elif [ ! -s "$file_json" ]; then
		echo '[!] Decryption keys not found !'

if [ "$plistutil" != '' ]; then
		# MacOS and Linux currently does not have plistutil
		# In case you are wondering why to use plistutil? bcz downloading 'BuildManifest.plist' are usually smaller size than downloading the whole website
		
		echo '[-] Parsing firmware codename...'
		firm_codename=$($plistutil -p "$build_manifest" | grep 'BuildTrain' -m 1 | awk -F '",' '{print $1}' | awk -F ': "' '{print $2}')
		tmp_url='https://theapplewiki.com/index.php?title=Keys:'"$firm_codename"_"$build_version"_'('"$product_name"')'
else
		echo '[!] Fetching firmware keys url...'
		tmp_url=$(curl -m 120 -s 'https://theapplewiki.com/wiki/Firmware_Keys/'"$major_ios"'.x' | grep "$build_version" | grep "$product_name" -m 1 | awk -F 'href="' '{print $2}' | awk -F '" title' '{print $1}')
		
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
		compare_build=$(grep -o "$build_version" "$file_json" | sed -n 1p)
	else
		echo '[!] An error occurred file is empty !'
		echo '[!] Target file:' "$file_json"
		exit 1
	fi
		
	if [ "$compare_build" = "$build_version" ]; then
		echo '[!] File saved as:' "$file_json"
		func_firmwarekeys_parser # call function
	else
		echo '[!] An error occurred file is corrupted !'
		echo '[-] Parsed value:' "$compare_build"
		echo '[-] Target Build Version:' "$build_version"
		exit 1
	fi
		
fi
}

# Function 5 print parsed info (debug)
debug_info (){

		# Debug mode for firmwares parser
		echo '[!] Debug Mode (parsed from firmwares.json):'
		echo '--------------------------------------------------'
		echo '     Type      |     Variable       | Returned value'
		echo '--------------------------------------------------'
		echo ' ProductName:  |' '($product_name)    |' "$product_name"
		echo ' iOS:          |' '($ios_version)     |' "$ios_version"
		echo ' Build Version:|' '($build_version)   |' "$build_version"
		echo ' Model:        |' '($product_model)   |' "$product_model"
		echo ' CPID:         |' '($cpid)            |' "$cpid"
		echo '--------------------------------------------------'
		echo ' iPSW:         |' '($ipsw_filename)   |' "$ipsw_filename"
		echo ' URL:          |' '($ipsw_url)        |' "$ipsw_url"
		echo '--------------------------------------------------'
		# Debug mode for firmwares parser
		echo '[!] Debug Mode (parsed from firmware key json):'
		echo '--------------------------------------------------'
		echo '      Type    |        Variable    | Returned value'
		echo '--------------------------------------------------'
		echo ' iBEC:        |'  '($ibec_file)          |' "$ibec_file" 
		echo ' iBSS:        |'  '($ibss_file)          |' "$ibss_file" 
		echo ' iBoot:       |'  '($iboot_file)         |' "$iboot_file"
		echo ' Kernel:      |'  '($kernel_file)        |' "$kernel_file"
		echo ' Devicetree:  |'  '($devicetree_file)    |' "$devicetree_file"
		echo ' RAMDISK:     |'  '($ramdisk_file)       |' "$ramdisk_file"
		echo ' RAMDISK:     |'  '($trustcache_file)    |' "$trustcache_file"
		echo '--------------------------------------------------'
		echo ' iBEC  IV+Key |' '($ibec_key)        |' "$ibec_key"
		echo ' iBSS  IV+Key |' '($ibss_key)        |' "$ibss_key"
		echo ' iBoot IV+Key |' '($iboot_key)       |' "$iboot_key"
		echo '--------------------------------------------------'
		echo
		echo "Note: To use these variables please call 'ifirmware_parser.sh' as source from any script."

}


		##############################
		#       Switches Stage       #
		##############################

		echo '[-] START:iFirmware-Parser'
	
	if [ "$1" = '' ]; then echo "[!] For list of available parameters use: 'ifirmware_parser.sh -h'"; fi
usage (){
		echo '------------------------------'
		echo 'iFirmware Parser'
		echo "Description: Parse firmware keys, and download SSH RAMDISK files."
		echo 'MIT License Copyright (c) 2024 mast3rz3ro'
		echo
		echo 'Usage:'
		echo '    ifirmware_parser.sh [parameters] or source ifirmware_parser.sh [parameters]'
		echo
		echo
		echo 'Switches:'
		echo '-u/--update     Update firmwares.json database'
		echo '-p/--product    Select Product name (Example: -p iPhone9,3 or -p iphone9,3)'
		echo '-m/--model      Select model version (Example: -m n66ap or -m n66map)'
		echo '-s/--ios        Search by iOS Version (Example: -s 15 or --ios 15.8)'
		echo '-b/--build      Search by Build number (Example: -b 19H or --build 19H370)'
		echo '-i/--input      Input firmware keys path for parsing (json format).'
		echo '-o/--output     Where to store downloaded ramdisk files.'
		echo '-k/--keys       Download and store firmware keys.'
		echo '-r/--ramdisk    Download ramdisk files.'
		echo '-d/--debug      Determining the vars for later use (optional).'
		echo '-h/--help       Show this message.'
		echo
		echo 'Examples:'
		echo '       ifirmware_parser.sh -u (update the firmwares database)'
		echo '       ifirmware_parser.sh -i somefile.json (Parse directly from firmware keys)'
		echo '       ifirmware_parser.sh -p iphone9,3 -s 15 (Parse latest iOS 15 info)'
		echo '       ifirmware_parser.sh -p iphone9,3 -b 19H370 -k (Download firmware keys for this exact build)'
		echo '       ifirmware_parser.sh -p iphone9,3 -s 15 -o somefolder -r (Download ramdisk files for latest iOS 15)'
		echo
		echo '------------------------------'
		exit
}


		########## Switch loop ##########
while getopts p:m:s:b:i:o:krduh option
	do
		case "${option}"
	in
		p) search_product=$(echo ${OPTARG} | tr 'p' 'P');; 
		m) search_model=$(echo ${OPTARG} | tr '[:upper:]' '[:lower:]');; 
		s) search_version="${OPTARG}"; value_json='version';;
		b) search_version="${OPTARG}"; value_json='buildid';;
		i) file_json="${OPTARG}";;
		o) download_output="${OPTARG}";;
		# Options
		k) keys_download="yes";;
		r) ramdisk_download="yes";;
		d) debug_mode="yes";;
		u) update_mode="yes";;
		h) usage;; # call function
	esac 
done


		########## Quick checks ##########

if [ "$update_mode" = 'yes' ]; then
		echo '[-] Updating firmware database ...'
		echo '[-] Downloading from: https://api.ipsw.me/v2.1/firmwares.json/condensed'
		curl -m 120 -s 'https://api.ipsw.me/v2.1/firmwares.json/condensed' -o 'misc/firmwares_new.json'
	if [ -s 'misc/firmwares_new.json' ]; then
		echo '[-] Validating:' 'misc/firmwares_new.json'
		# Why this exactly ? iTunes 10.5.3 (Windows) should be always the last value at EOF !
		check=$($jq '.iTunes.Windows[].version | select(. | startswith("10.5.3"))' './misc/firmwares_new.json' | sed 's/"//g')
	else
		echo '[!] File is empty'
		echo '[e] Update failed !'
		exit 1
	fi
	if [ "$check" = '10.5.3' ]; then
		echo '[!] Backing-up old database ...'
		cp -f 'misc/firmwares.json' 'misc/firmwares_bak'
		echo '[!] Overwriting old database ...'
		cp -f 'misc/firmwares_new.json' 'misc/firmwares.json'
		rm -f 'misc/firmwares_new.json'
		echo '[x] Update completed !'
	else
		echo '[!] Eile is corrupted !'
		echo '[e] Update failed !'
		rm -f 'misc/firmwares_new.json'
		exit 1
	fi
fi
	
if [ ! -s 'misc/firmwares.json' ]; then
		echo "[e] Couldn not find 'misc/firmwares.json'"
		exit
		
		# If file input by user not exist
	elif [ "$file_json" != '' ] && [ ! -s "$file_json" ] && [ "$search_version" = '' ] && [ "$value_json" = '' ]; then
		echo "[e] Couldn not locate the target file."
		echo '[!] Your path:' "'$file_json'"
		exit
fi	

		# Check if firm_keys been throwin for parse
if  [ -s "$file_json" ]; then
		func_firmwarekeys_parser # call function
fi

		# Parse device info
if [ "$search_product" != '' ] && [ "$search_version" != '' ] && [ "$value_json" != '' ]; then
		file_json='misc/firmwares.json'; func_firmware_parser # call function
fi

		# Check if downloading firmware keys is requested
if [ "$keys_download" = 'yes' ]; then
		func_download_keys # call function
fi

		# Check if is download ramdisk files is requested
if [ "$ramdisk_download" = 'yes' ]; then
	if [ "$download_output" = '' ]; then
		echo '[e] Output directory are not set'
		echo '[!] Please enter a valid directory for output'
		echo '[!] The directory you chose:' "'$download_output'"
		exit
	elif [ ! -d "$download_output" ]; then
		echo '[-] Creating output directory ...'
		mkdir -p "$download_output"
	fi
		func_download_ramdisk # call function		
fi

		# Show parsed info for debug
if [ "$debug_mode" = 'yes' ]; then
		debug_info # call function
fi

#return 2>/dev/null # return when called from another script

echo '[-] END:iFirmware-Parser'
