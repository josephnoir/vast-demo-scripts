#!/bin/bash

# find all uniq prefixes
for i_prefix in $(vast export bro "&type == \"mrt::bgp4mp::announcement\"" | bro-cut prefix | sort -u)
do

  #find min and max timestamp for prefix
  min_max=$(timeout 2 vast export bro "&type == \"mrt::bgp4mp::announcement\" && prefix == $i_prefix" | \
    bro-cut timestamp | cut -d. -f1 | awk '{a[NR]=$1}END{asort(a);print a[1],"\n"a[NR]}')
  min=$(echo "$min_max" | sed -n '1{p;q;}')
  max=$(echo "$min_max" | sed -n '2{p;q;}')

  # arithmetic expension: whats the delta
  delta=$((max-min))
  
  # delta small enough to be suspicious?
  threshold="$((60*60*4))"
  if (( delta < threshold )); then

    echo "--------------"
    human_delta=$(date -d@$delta -u +%H:%M:%S)
    echo -e "${i_prefix}\t${human_delta}"
    echo " "
   
    # do we have less/more specific announcements for prefix?
    prefix_list=$(timeout 2 vast export bro "&type == \"mrt::bgp4mp::announcement\" && (prefix in $i_prefix || prefix ni $i_prefix )" | bro-cut prefix | sort -u)

    while read -r j_prefix; do

      echo ". $j_prefix"

      # do we have multiple origins for prefix?
      origins=$(timeout 2 vast export bro "&type == \"mrt::bgp4mp::announcement\" && prefix == $j_prefix" | bro-cut origin_as | sort -u)
          
      # print all origins
      while read -r k_origin; do
        echo "..  AS$k_origin"
      done <<< "$origins"

    done <<< "$prefix_list"

    # TODO which ip from BL matches which prefix?
    # TODO which ip from HP matches which prefix?
    # TODO what's the delta for less/more specific announcements?
  fi
done
