#!/bin/bash

# Author: Jacob Grossbard
#
# This script executes pimcrypto on the host with amounts of data between 16B and 32GB
#

#data_file="data/vary_data_$mode.csv"

echo "Operation,Data size, execution time" > $data_file


make experiment  > /dev/null

#for mode in host aesni; do
for mode in host; do
#data_file="data/vary_data_$mode.csv"
data_file="data/cost.csv"
#for operation in encrypt decrypt
for operation in encrypt
do
	#data_size=16
	data_size=$((1 << 35))
	while [ $data_size -le $((1 << 35)) ]
	do
		repeats=10
		#if [ $data_size -ge $((1 << 26)) ]; then
		#	repeats=1
		#fi
		for i in {1..1}
		do
			echo "Testing with $data_size bytes in $mode mode..."
			./experiment/pimcrypto $mode $operation $data_size >> $data_file
		done
		data_size=$(($data_size * 2))
	done
done
done

