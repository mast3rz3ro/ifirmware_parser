#!/usr/bin/env bash



		##############################
		#       Platform check       #
		##############################
	
	
		platform=$(uname)
		arch=$(uname -m)


		curl_check=$(which curl)
	if [ ! -s "$curl_check" ]; then
		echo '[!] Error curl is missing !'
		echo '[!] Returned value:' "$curl_check"
		echo '[-] Platform:' "$platform"
		echo '[-] Arch:' "$arch"
	exit 1
	fi
	
# Preparing and checking required tools !
	if [ "$platform" = 'Linux' ]; then
		pack='Linux'
	elif [[ "$platform" = 'MSYS'* ]] || [[ "$platform" = 'MINGW'* ]]; then
		pack='Windows'
		platform='Windows'
	elif [ "$platform" = 'Darwin' ]; then
		pack='Darwin'
	fi
	
#pack='Linux' #debug switch

if [ ! -d 'tools/'"$pack" ]; then
		url='https://raw.githubusercontent.com/mast3rz3ro/sshrd_tools/main/'"$pack"'_pack.tar.xz'
		file='./'"$pack"'_pack.tar.xz'
		echo '[!] Required tools are missing !'
		echo "[!] Downloading into: '$file' ..."
		echo "[-] URL: '$url' "
		curl -s "$url" -o "$file"
	if [ -s "$file" ]; then
		echo '[-] Download completed !'
		echo "[!] Extracting '$file' ..."
		tar -xvf "$file"
		echo "[!] Removing '$file' ..."
		rm -f "$file"
	else
		echo '[!] Error downloading has failed !'
	exit 1
	fi
fi

if [ "$platform" = 'Linux' ]; then		
	
	# Linux Stage
		
		# Parser tools
		if [ "$jq" = '' ]; then jq='./tools/Linux/jq'; fi
		if [ "$pzb" = '' ]; then pzb='./tools/Linux/pzb'; fi
		if [ "$plistutil" = '' ]; then plistutil=''; fi
		
		# SSH connection
		if [ "$iproxy" = '' ]; then iproxy='./tools/Linux/iproxy'; fi
		if [ "$sshpass" = '' ]; then sshpass='./tools/Linux/sshpass'; fi
		
		# SSHRD tools
		if [ "$iBoot64Patcher" = '' ]; then iBoot64Patcher='./tools/Linux/iBoot64Patcher'; fi
		if [ "$kairos" = '' ]; then kairos='./tools/Linux/kairos'; fi
		if [ "$kerneldiff" = '' ]; then kerneldiff='./tools/Linux/kerneldiff'; fi
		if [ "$img4" = '' ]; then img4='./tools/Linux/img4'; fi
		if [ "$img4tool" = '' ]; then img4tool='./tools/Linux/img4tool'; fi
		if [ "$hfsplus" = '' ]; then hfsplus='./tools/Linux/hfsplus'; fi
		if [ "$KPlooshFinder" = '' ]; then KPlooshFinder='./tools/Linux/KPlooshFinder'; fi
		
		# SSHRD Flasher
		if [ "$irecovery" = '' ]; then irecovery='./tools/Linux/irecovery'; fi
		if [ "$gaster" = '' ]; then gaster='./tools/Linux/gaster'; fi
			
	elif [ "$platform" = 'Windows' ] && [ "$arch" = 'x86_64' ]; then

	# Windows x64
	
		# Parser tools
		if [ "$jq" = '' ]; then jq='./tools/Windows/jq_x64'; fi
		if [ "$pzb" = '' ]; then pzb='./tools/Windows/posix/pzb'; fi
		if [ "$plistutil" = '' ]; then plistutil='./tools/Windows/libimobiledevice_x64/plistutil'; fi
		
		# SSH connection
		if [ "$iproxy" = '' ]; then iproxy='./tools/Windows/libimobiledevice_x64/iproxy'; fi
		if [ "$sshpass" = '' ]; then sshpass='./tools/Windows/posix/sshpass'; fi
		
		# SSHRD tools for Windows x64
		if [ "$iBoot64Patcher" = '' ]; then iBoot64Patcher='./tools/Windows/posix/iBoot64Patcher'; fi
		if [ "$kairos" = '' ]; then kairos='./tools/Windows/kairos_x64'; fi
		if [ "$kerneldiff" = '' ]; then kerneldiff='./tools/Windows/kerneldiff_x64'; fi
		if [ "$img4" = '' ]; then img4='./tools/Windows/posix/img4'; fi
		if [ "$img4tool" = '' ]; then img4tool='./tools/Windows/posix/img4tool'; fi
		if [ "$hfsplus" = '' ]; then hfsplus='./tools/Windows/hfsplus_x86'; fi
		if [ "$KPlooshFinder" = '' ]; then KPlooshFinder='./tools/Windows/KPlooshFinder_x64'; fi
		
		# SSHRD Flasher
		if [ "$irecovery" = '' ]; then irecovery='./tools/Windows/libimobiledevice_x64/irecovery'; fi
		if [ "$gaster" = '' ]; then gaster='./tools/Windows/gaster/gaster_x64_0x7ff'; fi
		
	elif [ "$platform" = 'Windows' ] && [ "$arch" = 'i686' ]; then

	# Windows x86/x32
	
		# Parser tools
		if [ "$jq" = '' ]; then jq='./tools/Windows/jq_x86'; fi
		if [ "$pzb" = '' ]; then pzb=echo "WARNING: PZB UTILITY ISN'T AVAILABLE FOR WIN X86"; fi
		if [ "$plistutil" = '' ]; then plistutil='./tools/Windows/libimobiledevice_x86/plistutil'; fi
		
		# SSH connection
		if [ "$iproxy" = '' ]; then iproxy='./tools/Windows/libimobiledevice_x86/iproxy'; fi
		if [ "$sshpass" = '' ]; then sshpass="WARNING: SSHPASS UTILITY ISN'T AVAILABLE FOR WIN X86"; fi
		
		# SSHRD tools for Windows x86
		if [ "$iBoot64Patcher" = '' ]; then iBoot64Patcher=echo "WARNING: IBOOT64PATCHER UTILITY ISN'T AVAILABLE FOR WIN X86"; fi
		if [ "$kairos" = '' ]; then kairos='./tools/Windows/kairos_x86'; fi
		if [ "$kerneldiff" = '' ]; then kerneldiff='./tools/Windows/kerneldiff_x86'; fi
		if [ "$img4" = '' ]; then img4=echo "WARNING: IMG4 UTILITY ISN'T AVAILABLE FOR WIN X86"; fi
		if [ "$img4tool" = '' ]; then img4tool=echo "WARNING: IMG4TOOL UTILITY ISN'T AVAILABLE FOR WIN X86"; fi
		if [ "$hfsplus" = '' ]; then hfsplus='./tools/Windows/hfsplus_x86'; fi
		if [ "$KPlooshFinder" = '' ]; then KPlooshFinder='./tools/Windows/KPlooshFinder_x86'; fi
		
		# SSHRD Flasher
		if [ "$irecovery" = '' ]; then irecovery='./tools/Windows/libimobiledevice_x86/irecovery'; fi
		if [ "$gaster" = '' ]; then gaster='./tools/Windows/gaster/gaster_x86_0x7ff'; fi

	elif [ "$platform" = 'Darwin' ]; then
	
	# Darwin (MacOS)
	
		# Parser tools
		if [ "$jq" = '' ]; then jq='./tools/Darwin/jq'; fi
		if [ "$pzb" = '' ]; then pzb='./tools/Darwin/pzb'; fi
		if [ "$plistutil" = '' ]; then plistutil=''; fi
		
		# SSH connection
		if [ "$iproxy" = '' ]; then iproxy='./tools/Darwin/iproxy'; fi
		if [ "$sshpass" = '' ]; then sshpass='./tools/Darwin/sshpass'; fi
		
		# SSHRD tools
		if [ "$iBoot64Patcher" = '' ]; then iBoot64Patcher='./tools/Darwin/iBoot64Patcher'; fi
		if [ "$kairos" = '' ]; then kairos='./tools/Darwin/kairos'; fi
		if [ "$kerneldiff" = '' ]; then kerneldiff='./tools/Darwin/kerneldiff'; fi
		if [ "$img4" = '' ]; then img4='./tools/Darwin/img4'; fi
		if [ "$img4tool" = '' ]; then img4tool='./tools/Darwin/img4tool'; fi
		if [ "$hfsplus" = '' ]; then hfsplus='./tools/Darwin/hfsplus'; fi
		if [ "$KPlooshFinder" = '' ]; then KPlooshFinder='./tools/Darwin/KPlooshFinder'; fi
		
		# SSHRD Flasher
		if [ "$irecovery" = '' ]; then irecovery='./tools/Darwin/irecovery'; fi
		if [ "$gaster" = '' ]; then gaster='./tools/Darwin/gaster'; fi
		
	else
		echo "[Error] Can't setup the tools"
		echo '[-] Platform:' "$platform"
		echo '[-] Arch:' "$arch"
	return 2>/dev/null
fi
