#!/bin/bash


#-------------------------------------------------------------------------------------------
# History
# DA 21-MAR-22 added addlog function and updated the program to copy a source file to destination with new/different file name

#-------------------------------------------------------------------------------------------

logf=~/Copier/copier.log

addlog(){
	ADDDATE="$1"
	SPLITER="$2"
	DISP="$3"
	data="$4"
	logfile="$5"
	if [[ $SPLITER == 1 ]];then
		if [[ $DISP == 1 ]];then
			echo "--------------------------------------------------------------------------------------------------------------"
		fi
		echo "--------------------------------------------------------------------------------------------------------------" >> $logfile
	fi
	if [[ $ADDDATE == 1 ]];then
		echo -e $(date)"\n" >> $logfile
	fi
	if [[ $(expr length "$data") > 1 ]] || [[ $data != 0 ]];then
		if [[ $DISP == 1 ]];then
			echo -e "$data"
		fi
		echo -e "$data" >> $logfile
	fi
}

copy(){
	src="$1"
	dest="$2"
	addlog 1 1 1 "\033[32;3m$src\033[0m > \033[36;3m$dest\033[0m" $logf
	pv "$src" > "$dest"
}

function remove(){
	#echo "remove"
	file1=$1
	file2=$2
	#echo $file1
	#echo $file2
	sumf1=$(md5sum "$file1" | cut -d " " -f 1)
	sumf2=$(md5sum "$file2" | cut -d " " -f 1)
	#echo "--------------------------------------------------------------------------------------------------------------" >> remove.dat
	if [[ "$sumf1" == "$sumf2" ]];then
		$(rm "$file1")
		addlog 1 1 0 "removed \"$file1\"" remove.dat
		addlog 0 0 0 "Source : $sumf1 $file1\nDestination : $sumf2 $file2" remove.dat
	else
		addlog 0 0 0 "\033[31;1mFile is corrupted\033[0m" remove.dat
		addlog 0 0 0 "Source : \033[31;1m$sumf1\033[35;1m $file1\033[0m\nDestination : \033[31;1m$sumf2\033[35;1m $file2\033[0m" remove.dat
	fi
	addlog 1 0 0 0 remove.dat
}

# Splits options and arguments
#-------------------------------------------------------------------------------------------
# echo "Splits options and arguments"
for i;
do
	if [[ $(echo "$i" | grep -E "^[-]") ]];
	then
		option+=("$i")
	else
		files+=("$i")
	fi
done
#-------------------------------------------------------------------------------------------
fileno=${#files[@]}

# Set Flags
#-------------------------------------------------------------------------------------------
# echo "Set Flags"
if [[ $(echo ${option[@]} | grep "[- ]*d" | wc -l ) != 0 ]];then
	DEST=True
fi
if [[ $(echo ${option[@]} | grep "[- ]*f" | wc -l ) != 0 ]];then
	FILE=True
fi
if [[ $(echo ${option[@]} | grep "[- ]*r" | wc -l ) != 0 ]];then
	REMOVE=True
fi
#-------------------------------------------------------------------------------------------

# Initial exception,destination folder/file check
#-------------------------------------------------------------------------------------------
# echo "Initial exception,destination folder/file check"
if [[ $DEST == True ]] && [[ $FILE == True ]];then
	echo "-d and -f cannot be used at the same time"
	exit
elif [[ $DEST == True ]];then
	dest_folder=${files[`expr $fileno - 1`]}
	if [[ -d "$dest_folder" ]];then
		#echo $(echo $dest_folder | grep "/$" | wc -l)
		if [[ $(echo $dest_folder | grep "/$" | wc -l ) == 0 ]];then
			dest_folder=$dest_folder"/"
		fi
	else
		if [[ -f "$dest_folder" ]];then
			echo -e "\033[31;1m$dest_folder is a file not a folder\033[0m"
		else
			echo -e "\033[31;1m$dest_folder does not exists\033[0m"
		fi
		echo -e "Operation failed!!!"
		exit
	fi
	# removing last destination folder name from list of files
	files=( "${files[@]:0:$((fileno-1))}" )
	fileno=${#files[@]}
elif [[ $FILE == True ]];then
	if [[ $fileno == 2 ]];then
		dest="${files[1]}"
		files=( "${files[@]:0:$((fileno-1))}" )
		fileno=${#files[@]}
	else
		echo -e "\033[31;1m Only 2 file names must be passed as arguments along with -f option, $fileno were given\033[0m"
		echo -e "Operation failed!!!"
		exit
	fi
else
	dest_folder=0
fi
#-------------------------------------------------------------------------------------------

#echo $files,$fileno
#echo ${files[$i]}
#exit

# Main loop
#-------------------------------------------------------------------------------------------
# echo "Main loop"
for i in $(seq 0 `expr $fileno - 1` );
do
	if [[ $FILE != True ]];then
		dest=$(echo ${files[$i]} | rev | cut -d "/" -f 1 | rev)
		if [[ $dest_folder != 0 ]];then
			dest=$dest_folder$dest
		fi
	fi
	#echo $i
	#src=$(echo ${files[$i]} | sed 's/\([^a-zA-Z0-9]\)/\\\1/g')
	src=${files[$i]}
	#echo "Source : "$src #${files[$i]}
	#echo "Destination : "$dest
	#echo $(echo "$i" | grep "^[^-]")
	#echo $(echo "$i" | wc -m > 2)
	copy "$src" "$dest"
	#echo ${option[@]} | grep "[- ]*r" | wc -l
	if [[ $REMOVE == True ]];then
		remove "$src" "$dest" &
	fi
done
#-------------------------------------------------------------------------------------------
wait

# Remove temporary log
#-------------------------------------------------------------------------------------------
# echo "Remove temporary log"
if [[ -f remove.dat ]];then
	cat remove.dat
	rm remove.dat
fi
#-------------------------------------------------------------------------------------------

#Final output
echo -e "\033[36;3mAll Transfer completed\033[0m"