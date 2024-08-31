#!/usr/sh 

data_file="data/host.csv"
if [ -f "$data_file" ]; then
    rm "$data_file"
fi

echo "Operation,Data size, execution time" > $data_file
make experiment  > /dev/null

#for mode in host aesni; do
for mode in host; do
data_file="data/host.csv"
for operation in encrypt
do
	data_size=16384
	while [ $data_size -le $((1 << 35)) ]
	do
		for i in {1..1}
		do
			echo "Testing with $data_size bytes in $mode mode..."
			./experiment/pimcrypto $mode $operation $data_size >> $data_file
		done
		data_size=$(($data_size * 2))
	done
done
done



data_file="data/cost.csv"
if [ -f "$data_file" ]; then
    rm "$data_file"
fi
make experiment  > /dev/null

echo "Tasklets,DPUs,Operation,Data size,Allocation time,Loading time,Data" \
" copy in,Parameter copy in,Launch,Data copy out,Performance count copy" \
" out,Free DPUs,Performance count min, max, average" > $data_file

for ranks in {1..9}; do
	data_per_dpu=16
	while [ $data_per_dpu -lt $((2 << 26)) ]
	do
		echo "Testing with $data_per_dpu bytes per DPU across $ranks ranks..."
		dpus=$((64 * $ranks))
		./experiment/pimcrypto dpu $dpus encrypt $(($ranks * 64 * $data_per_dpu)) >> $data_file
		data_per_dpu=$(($data_per_dpu * 2))
	done
done

awk 'BEGIN{FS=","; OFS=","} NR==1{print "version", "parallelism", "time"} NR>1 {print "dpus="$2, $4/2^20, $5+$6+$7+$8+$9+$10+$11+$12}' $data_file > "data/dpu_all_included.csv"

awk 'BEGIN{FS=","; OFS=","} NR==1{print "version", "parallelism", "time"} NR>1 {print "dpus="$2, $4/2^20, $9}' $data_file > "data/dpu_only_launch.csv"






