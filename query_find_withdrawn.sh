#!/bin/bash

# find all uniq prefixes for withdrawn
for i_prefix in $(vast export bro "&type == \"mrt::bgp4mp::withdrawn\"" | bro-cut prefix | sort -u)
do

  #find min and max timestamp for prefix withdraws
  w_min_max=$(timeout 2 vast export bro "&type == \"mrt::bgp4mp::withdrawn\" && prefix == $i_prefix" | \
    bro-cut -d timestamp | cut -d. -f1 | awk '{a[NR]=$1}END{asort(a);print a[1],"\n"a[NR]}')
  w_min=$(echo "$w_min_max" | sed -n '1{p;q;}')
  w_max=$(echo "$w_min_max" | sed -n '2{p;q;}')
  
  #find min and max timestamp for prefix announcements
  a_min_max=$(timeout 2 vast export bro "&type == \"mrt::bgp4mp::announcement\" && prefix == $i_prefix" | \
    bro-cut -d timestamp | cut -d. -f1 | awk '{a[NR]=$1}END{asort(a);print a[1],"\n"a[NR]}')
  a_min=$(echo "$a_min_max" | sed -n '1{p;q;}')
  a_max=$(echo "$a_min_max" | sed -n '2{p;q;}')

  echo "--------------"
  echo "$i_prefix"
  echo "w_min: $w_min"
  echo "w_max: $w_max"
  echo "a_min: $a_min"
  echo "a_max: $a_max"
done
