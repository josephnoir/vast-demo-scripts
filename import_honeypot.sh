#!/bin/bash

day=$1
dir="/users/localadmin/persistent_vast/real-demo/honeypot"

for sensor in "dark" "univ"
do
  echo "Importing data for honeypot [$sensor] and date [$day]."
  zcat ${dir}/${sensor}/${day}*/conn\.*\.gz | \
    vast import bro "id.resp_h == 91.216.216.10 || id.resp_h == 141.22.213.43"
done
