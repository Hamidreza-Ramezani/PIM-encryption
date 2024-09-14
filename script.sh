#!/usr/sh 

data_file="data/host.csv"
make clean
make experiment  > /dev/null
echo "Operation,Data size, execution time\n" > $data_file
data_size=16

for i in {1..1}; do
  for ((J=4; J<=26; J++)); do
    data_size=$((64 * i * (1 << J)))  # Calculate data_size as 64 * i * 2^J
    echo "Testing with $data_size bytes on the host..."
    ./experiment/pimcrypto host encrypt $data_size >> $data_file
  done
done


#while [ $data_size -le $((1 << 35)) ]
#do
#       echo "Testing with $data_size bytes on the host..."
#       ./experiment/pimcrypto host encrypt $data_size >> $data_file
#       data_size=$(($data_size * 2))
#done


awk 'BEGIN{FS=","; OFS=","} NR==1{print "version", "parallelism", "time"} NR>1 {print $1, $2, $3}' "data/host.csv" > "data/host-graph.csv"

rm "data/host.csv"

#data_file="data/cost.csv"
#
#echo "Tasklets,DPUs,Operation,Data size,Allocation time,Loading time,Data" \
#" copy in,Parameter copy in,Launch,Data copy out,Performance count copy" \
#" out,Free DPUs,Performance count min, max, average" > $data_file
#make experiment  > /dev/null
#
#for ranks in {1..36}; do
#	data_per_dpu=16
#	while [ $data_per_dpu -lt $((2 << 26)) ]
#	do
#		echo "Testing with $data_per_dpu bytes per DPU across $ranks ranks..."
#		dpus=$((64 * $ranks))
#		./experiment/pimcrypto dpu $dpus encrypt $(($ranks * 64 * $data_per_dpu)) >> $data_file
#		data_per_dpu=$(($data_per_dpu * 2))
#	done
#done
#
#
#awk 'BEGIN{FS=","; OFS=","} NR==1{print "version", "parallelism", "time"} NR>1 {print "dpus="$2, $4, $5+$6+$7+$8+$9+$10+$11+$12}' $data_file > "data/dpu_all_included.csv"
#
#awk 'BEGIN{FS=","; OFS=","} NR==1{print "version", "parallelism", "time"} NR>1 {print "dpus="$2, $4, $9}' $data_file > "data/dpu_only_launch.csv"


sudo chown hamidkeb:hamidkeb "/home/hamidkeb/pim-encryption/data/*"
sudo chown hamidkeb:hamidkeb "/home/hamidkeb/pim-encryption/data/"



