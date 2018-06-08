#!/bin/bash

# find all uniq prefixes
for i_prefix in $(vast export bro "&type == \"mrt::bgp4mp::announcement\"" | bro-cut prefix | sort -u)
do
  #find all prefixeds with more specific announcements
  i_list=$(timeout 2 vast export bro "&type == \"mrt::bgp4mp::announcement\" && prefix == $i_prefix" | bro-cut origin_as | sort -u)
  size=$(echo "$i_list" | wc -l)

  # we need at least 2 different origins
  if [ "$size" -ne "1" ]; then
    echo "--------------"
    echo "$i_prefix"

    # for current prefix: print all origin as
    while read -r j_origin; do
      echo "... $j_origin"
    done <<< "$i_list"
  fi
done
