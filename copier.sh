#!/bin/bash


function remove(){
	#echo "remove"
	file1=$1
	file2=$2
	#echo $file1
	#echo $file2
	sumf1=$(md5sum "$file1" | cut -d " " -f 1)
	sumf2=$(md5sum "$file2" | cut -d " " -f 1)
	if [ "$sumf1" = "$sumf2" ];then
		echo $(rm -v "$file1") >> remove.dat
		#echo -e "\nSource : $sumf1 $file1\nDestination : $sumf2 $file2"
	else
		echo -e "\033[31;1mFile is corrupted\033[0m"
		echo -e "\nSource : \033[31;1m$sumf1\033[35;1m $file1\033[0m\nDestination : \033[31;1m$sumf2\033[35;1m $file2\033[0m"
	fi
}

#echo "Main function"

for i;
do
if [ "$i" != "-r" ];then
	#echo "loop"
	src=$(echo $i | sed 's/\([^a-zA-Z0-9]\)/\\\1/g')
	dest=$(echo $i | rev | cut -d "/" -f 1 | rev)
	#echo $src
	#echo $dest
	#file1=`cat src`
	#file2=`cat dest`
	#echo "source : $file1"
	#echo "destination : $file2"
	#rm src dest
	echo -e "\033[32;3m$i\033[0m > \033[36;3m$dest\033[0m"
	pv "$i" > "$dest"
	#echo $file1,$file2
	if [ "$1" = "-r" ];then
		remove "$i" "$dest" &
	fi
fi
done

wait
cat remove.dat
rm remove.dat
echo -e "\033[36;3mAll Transfer completed\033[0m"
#main
