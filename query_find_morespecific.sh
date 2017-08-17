#!/bin/bash

# caida as rel file
as_rel_file="/users/localadmin/persistent_vast/real-demo/caida_rel/as_rel.txt" 
t_vast=1

# find all uniq prefixes
for i_prefix in $(vast export bro "&type == \"mrt::bgp4mp::announcement\"" | bro-cut prefix | sort -u)
do
  #find all prefixes with more specific announcements
  i_list=$(timeout $t_vast vast export bro "&type == \"mrt::bgp4mp::announcement\" && prefix in $i_prefix" | bro-cut prefix | sort -u)
  size=$(echo "$i_list" | wc -l)

  # we need at least 2 different prefixes
  # TODO ... or at least two different origin as! -> maybe do this in another file?
  if [ "$size" -ne "1" ]; then
    echo "--------------"
    echo "$i_prefix"

    # for current and more specific prefixes: find origins
    all_origins=""
    while read -r j_prefix; do
      echo "... $j_prefix"
      
      # TODO calls this only once
      origins=$(timeout $t_vast vast export bro "&type == \"mrt::bgp4mp::announcement\" && prefix == $j_prefix" | bro-cut origin_as | sort -u)

      # save all origins for relationship check
      all_origins=$(echo -e "$all_origins\n$origins")
              
      # print youngest announcement

      #find min and max timestamp for prefix withdraws
      # TODO make nice withdrawel print
      #w_min_max=$(timeout 2 vast export bro "&type == \"mrt::bgp4mp::withdrawn\" && prefix == $j_prefix" | \
      #  bro-cut -d timestamp | cut -d. -f1 | awk '{a[NR]=$1}END{asort(a);print a[1],"\n"a[NR]}')
      #
      #echo "$w_min_max"
      #w_min=$(echo "$w_min_max" | sed -n '1{p;q;}')
      #w_max=$(echo "$w_min_max" | sed -n '2{p;q;}')
      
      # print all origins
      while read -r k_origin; do
        echo "...... AS$k_origin WMIN $w_min WMAX $_max"
      done <<< "$origins"
    done <<< "$i_list"

    # remove trailing newline and find unique ASNs
    all_origins=$(echo -e "$all_origins" | tail -n +2 | sort -u)
    o_size=$(echo -e "$all_origins" | wc -l)
    info_orig=$(echo "$all_origins" | tr '\n' '|')
    echo ". |$info_orig"

    # print relationship, if available, in case of >1 origins
    if [ "$o_size" -ne "1" ]; then
        
      # permute ASNs, search relationship
      while read -r x_origin; do
        while read -r y_origin; do
          if [ "$x_origin" -ne "$y_origin" ]; then
            rel=$(grep "$x_origin|$y_origin" "$as_rel_file")

            if [[ ! -z "$rel" ]]; then
              echo "... |$rel"
            fi
          fi
        done <<< "$all_origins"
      done <<< "$all_origins"
    fi
  fi
done
