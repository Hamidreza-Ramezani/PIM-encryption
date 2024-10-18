#!/usr/sh 

make clean
make experiment  > /dev/null
application="$HOME/pim-encryption/experiment/pimcrypto"
results_dir="$HOME/aes-roofline-results/sep14"

for i in {8..8}; do
  for ((J=24; J<=26; J++)); do
    data_size=$((64 * i * (1 << J)))  # Calculate data_size as 64 * i * 2^J
    echo "Testing with $data_size bytes on the host..."
    #./experiment/pimcrypto host encrypt $data_size
    advisor -collect roofline -stacks -enable-cache-simulation -project-dir "${results_dir}/${data_size}" --app-working-dir="$HOME/pim-encryption/" -- $application host encrypt $data_size
  done
done




