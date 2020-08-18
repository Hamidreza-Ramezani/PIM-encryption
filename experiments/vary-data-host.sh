#!/bin/bash

# Author: Jacob Grossbard
#
# This script executes pimcrypto on the host with amounts of data between 16B and 32GB
#

data_file="data/vary_data_host.csv"

echo "Operation,Data size, execution time\n" > $data_file


make experiment  > /dev/null

for operation in encrypt decrypt
do
	data_size=16
	while [ $data_size -le $((1 << 35)) ]
	do
		echo "Testing $operation with $data_size bytes on the host..."
		./experiment/pimcrypto host $operation $data_size >> $data_file
		data_size=$(($data_size * 2))
	done
done

