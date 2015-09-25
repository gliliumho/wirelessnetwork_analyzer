#!/bin/bash

echo "Enter number of lines you want to output:"
read COUNT

#make backup of the ping data used
FOLDER="databackup_`date +%d%m%y_%k%M%S`"
mkdir "$FOLDER" 
cp ping172* "$FOLDER"

COUNTER=(1)
SEQ=(0)
while [ $COUNTER -le $COUNT ]; do 	#while counter less than lines wanted
	printf "\n$COUNTER\t"
	while read F; do 		#read every file from filelist
		FLAG=0			#flag to indicate if line is missing/packet lost
		while IFS='' read -r line || [[ -n "$line" ]]; do
			#SEQ = current ping line read - eg."icmp_seq=XX"
			SEQ=`echo "$line" | grep -o 'icmp_seq.*' | cut -f1 -d ' ' | cut -f2 -d '='`
			let SEQ=SEQ	#to convert SEQ to integer
			
			#echo $line
			#echo "SEQ = $SEQ"
			#SEQ=${SEQ#0}
			#DIFF=`expr "$SEQ"-"$COUNTER"`
			#printf "SEQ: $SEQ - COUNTER: $COUNTER = DIFF: $DIFF"
			#if [if [ "$SEQ" -eq "$COUNTER" ]; then
			
			if [ $SEQ -eq $COUNTER ]; then 	#if this is line we're looking for
				grep -q "time"
				if [ $? -eq 0 ]; then 	#if there is ping time, not "Host Is Unreachable"
					#save ping time - eg. "ping=X.XXXms"
					TIME=`echo "$line" | grep -o 'time.*' | cut -f1 -d ' ' | cut -f2 -d '='`
					printf "$TIME\t"
					FLAG=1 		#indicate line is not missing/packet not lost
				fi
				sed -i '1d' $F 		#delete line scanned
				break
			
			elif [ $SEQ -gt $COUNTER ]; then	# To stop the scanning entire file for a missing sequence number
				break	
			fi
		done < $F
		if [ "$FLAG" -eq 0 ]; then #if line is missing / packet lost
			printf "\t"	#print empty tab
		fi
	done < filelist 
	let COUNTER=COUNTER+1
done
