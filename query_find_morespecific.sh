#!/bin/bash

# find all uniq prefixes
for i_prefix in $(vast export bro "&type == \"mrt::bgp4mp::announcement\"" | bro-cut prefix | sort -u)
do
  #find all prefixes with more specific announcements
  i_list=$(timeout 2 vast export bro "&type == \"mrt::bgp4mp::announcement\" && prefix in $i_prefix" | bro-cut prefix | sort -u)
  size=$(echo "$i_list" | wc -l)

  # we need at least 2 different prefixes
  if [ "$size" -ne "1" ]; then
    echo "--------------"
    echo "$i_prefix"

    # for current and more specific prefixes: find origins
    while read -r j_prefix; do
      echo "... $j_prefix"
      origins=$(timeout 2 vast export bro "&type == \"mrt::bgp4mp::announcement\" && prefix == $j_prefix" | bro-cut origin_as | sort -u)

    #find min and max timestamp for prefix withdraws
    w_min_max=$(timeout 2 vast export bro "&type == \"mrt::bgp4mp::withdrawn\" && prefix == $j_prefix" | \
      bro-cut -d timestamp | cut -d. -f1 | awk '{a[NR]=$1}END{asort(a);print a[1],"\n"a[NR]}')
    w_min=$(echo "$w_min_max" | sed -n '1{p;q;}')
    w_max=$(echo "$w_min_max" | sed -n '2{p;q;}')
    
      # print all origins
      while read -r k_origin; do
        echo "...... AS$k_origin WMIN $w_min WMAX $_max"
      done <<< "$origins"
    done <<< "$i_list"
  fi
done
