#!/bin/bash

logDir=".monitor_logs"
if [ ! -d "$HOME/$logDir" ]; then
	mkdir $HOME/$logDir
fi
pidDir=".monitor_pids"
if [ ! -d "$HOME/$pidDir" ]; then
	mkdir $HOME/$pidDir
fi

start(){
	folder="$1"
	if [ -d "$folder" ] && [ -r "$folder" ]; then
		folder="$(realpath $1)"
	elif [ -d "$folder" ] && [ ! -r "$folder" ] || [ ! -x "$folder" ]; then
		echo "$folder is not a readable or not a executable directory."
		return
	elif [ ! -d "$folder" ]; then
		echo "unknown Command:"
		echo ""
		echo "usage:"
		echo "$0 /path/to/folder"
		return
	fi
	if ! command -v inotifywait > /dev/null 2>&1; then
		echo "inotifywait not found."
		echo "Try:"
		echo "sudo apt install inotify-tools"
		return
	else
		for pidFile in "$HOME/$pidDir/"*.pid; do
			folderName="$(echo "$pidFile" | awk -F'/' '{ print $5}' | sed 's/\.pid$//' | sed 's|_|/|g')"
			found=0
			if [ "$folderName" = "$folder" ]; then
				found=1
			fi
		done
		if [ "$found" = 0 ]; then
			folderNew=$(echo "$folder" | sed 's|/|_|g')
			inotifywait -m "$folder" --format '%T | %w%f | %e' --timefmt '%Y-%m-%d %H:%M:%S' -e 'CREATE' -e 'DELETE' -e 'MODIFY' >> "$HOME/$logDir/$folderNew.log" &
			pid=$!
			echo "$pid" > "$HOME/$pidDir/$folderNew.pid"
			echo "Monitoring Started"
			echo "use '$0 stop path/to/folder' to stop the monitoring."
			echo "logs being written to: $HOME/$logDir/$folderNew.log"
		else
			echo "$folder is already being monitored."
		fi

	fi	
}
stop(){
	folder="$1"
	if [ -d "$folder" ] && [ -r "$folder" ]; then
                folder="$(realpath $1)"
        elif [ -d "$folder" ] && [ ! -r "$folder" ] || [ ! -x "$folder" ]; then
                echo "$folder is not a readable or not a executable directory."
                return
        elif [ ! -d "$folder" ]; then
                echo "$folder is not a valid directory."
                return
        fi
        if ! command -v inotifywait > /dev/null 2>&1; then
                echo "inotifywait not found."
                echo "Try:"
                echo "sudo apt install inotify-tools"
                return
        else
		folderNew=$(echo "$folder" | sed 's|/|_|g')
		pidFilePath="$HOME/$pidDir/$folderNew.pid"
		if [ -f "$pidFilePath" ]; then
			pid="$(cat $pidFilePath)"
			kill "$pid"
			if ps -p "$pid" > /dev/null 2>&1; then
				kill -9 "$pid"
			fi
			rm -f "$pidFilePath"
			echo "Monitoring of $HOME/$logDir/$foldernew has been stopped."
		else
			echo "Given folder is not being monitored."
		fi

        fi
	echo "Stopped monitoring $folder"
}
list(){
	if [ -z "$(find $HOME/$pidDir -mindepth 1 -print -quit)" ]; then
		echo "No directories are being monitored."
	else
		echo "Directories being monitored:"
		for pidFile in "$HOME/$pidDir"/*.pid; do
			folderName=$(echo "$pidFile" | awk -F'/' '{ print $5 }' | sed 's/\.pid$//' | sed 's|_|/|g')
			echo " - $folderName"
		done
	fi
}
status(){
	folder="$1"
	if [ -d "$folder" ] && [ -r "$folder" ]; then
                folder="$(realpath $1)"
        elif [ -d "$folder" ] && [ ! -r "$folder" ] || [ ! -x "$folder" ]; then
                echo "$folder is not a readable or not a executable directory."
                return
        elif [ ! -d "$folder" ]; then
                echo "$folder is not a valid directory."
                return
        fi
        if ! command -v inotifywait > /dev/null 2>&1; then
                echo "inotifywait not found."
                echo "Try:"
                echo "sudo apt install inotify-tools"
                return
        else
		folderpidPath="$HOME/$pidDir/$(echo "$folder" | sed 's|/|_|g').pid"
		if [ -f "$folderpidPath" ]; then
			echo "$folder is being monitored."
		else
			echo "$folder is not being monitored."
		fi
	fi

}
showHelp(){
	echo ""
	echo "Real-Time Directory Monitor - Bash CLI Tool"
	echo ""
	echo "Usage:"
	echo " $0 start /path/to/folder	start monitoring a directory"
	echo " $0 stop /path/to/folder	stop monitoring a directory"
	echo " $0 status /path/to/folder	checks if directory is being monitored or not"
	echo " $0 list			lists all actively monitored directories"
        echo " $0 --version or -V		show version info"
	echo " $0 --help or -h		show this help message"
	echo " Watches a folder in real-time using inotifywait."
	echo " Detects file crestion, modification, and deletion."
	echo " Logs each event with timestamp to a log file."
	echo ""
	echo "Log file:"
	echo " ~/.monitor_logs/<folder_name>.log"
	echo ""
	echo "Made with ˚ʚ♡ɞ˚ by Hammad"
	echo ""	
}
showversion(){
	echo ""
	echo "Real-Time Directory Monitor v1.0"
	echo "Author: Hammad"
	echo "Built with: Bash + inotifywait"
	echo ""
}
case $1 in
	"")
		echo "unknown:"
		echo "Try --help or -h to view help page"
		;;
	--help | -h)
		showHelp
		;;
	--version | -V)
		showversion
		;;
	start)
		if [ -z "$2" ]; then
			echo "unknown:"
			echo "Try --help or -h to view help page"
		else
			start "$2"
		fi
		;;
	stop)
		if [ -z "$2" ]; then
			echo "unknown:"
			echo "Try --help or -h to view help page"
		else
			stop "$2"
		fi
		;;
	list)
		list
		;;
	status)
		if [ -z "$2" ]; then
			echo "unknown:"
			echo "Try --help or -h to view help page"
		else
			status "$2"
		fi
		;;

	*)
		echo "Try --help or -h to view help page."
		;;
esac
