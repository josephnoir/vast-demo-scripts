#!/bin/bash

# caida as rel file
as_rel_file="/users/localadmin/persistent_vast/real-demo/caida_rel/as_rel.txt" 
t_vast=0.5

# find all uniq prefixes
for i_prefix in $(vast export bro "&type == \"mrt::bgp4mp::announcement\"" | bro-cut prefix | sort -u)
do
  #find all prefixes with more specific announcements
  # i_list=$(timeout $t_vast vast export bro "&type == \"mrt::bgp4mp::announcement\" && prefix in $i_prefix" | bro-cut prefix | sort -u)
  # size=$(echo "$i_list" | wc -l)
  more_spec=$(timeout $t_vast vast export bro "&type == \"mrt::bgp4mp::announcement\" && prefix in $i_prefix")
  i_list=$(echo "$more_spec" | bro-cut prefix | sort -u)
  n_orig=$(echo "$more_spec" | bro-cut origin_as | sort -u | wc -l)

  # we need at least two different origins!
  if [ "$n_orig" -ne "1" ]; then
    echo "--------------"
    echo "$i_prefix"

    # for current and more specific prefixes: find origins
    all_origins=""
    while read -r j_prefix; do
      
      echo "... $j_prefix"

      # get youngest withdrawel for current prefix 
      w_min=$(timeout $t_vast vast export bro \
        "&type == \"mrt::bgp4mp::withdrawn\" && prefix == $j_prefix" | \
        bro-cut -d timestamp | sort | sed -n '1{p;q;}'| cut -d+ -f1 )
      echo "... [WMIN: $w_min]"
      ##find min and max timestamp for prefix withdraws
      #w_min_max=$(timeout 2 vast export bro "&type == \"mrt::bgp4mp::withdrawn\" && prefix == $j_prefix" | \
      #  bro-cut timestamp | cut -d. -f1 | awk '{a[NR]=$1}END{asort(a);print a[1],"\n"a[NR]}')
      #w_min=$(echo "$w_min_max" | sed -n '1{p;q;}')
      #w_max=$(echo "$w_min_max" | sed -n '2{p;q;}')
      
      # find all origins for current prefix
      origins=$(timeout $t_vast vast export bro \
        "&type == \"mrt::bgp4mp::announcement\" && prefix == $j_prefix" | \
        bro-cut origin_as | sort -u)

      # save all origins for relationship check
      all_origins=$(echo -e "$all_origins\n$origins")
              
      # print all origins for more specific prefix
      while read -r k_origin; do
        # get youngest announcement for each origin of current prefix
        a_min=$(timeout $t_vast vast export bro \
          "&type == \"mrt::bgp4mp::announcement\" && prefix == $j_prefix && origin_as == $k_origin" | \
          bro-cut -d timestamp | sort | sed -n '1{p;q;}'| cut -d+ -f1)
        echo -e "...... AS$k_origin\t[AMIN: $a_min]"
      done <<< "$origins"
    done <<< "$i_list"

    # remove trailing newline and find unique ASNs for all origins of more specific prefixes
    all_origins=$(echo -e "$all_origins" | tail -n +2 | sort -u)
    o_size=$(echo -e "$all_origins" | wc -l)
    info_orig=$(echo "$all_origins" | tr '\n' '|')
    echo ". |$info_orig"

    # print relationship, if available, in case of >1 origins
    if [ "$o_size" -ne "1" ]; then
        
      # permute ASNs, search relationship
      found="no"
      while read -r x_origin; do
        while read -r y_origin; do
          if [ "$x_origin" -ne "$y_origin" ]; then
            rel=$(grep "$x_origin|$y_origin" "$as_rel_file")
            # print if relation ship exists
            if [[ ! -z "$rel" ]]; then
              echo "... |$rel"
              found="yes"
            fi
          fi
        done <<< "$all_origins"
      done <<< "$all_origins"
      if [ "$found" == "no" ]; then
        echo "... NOREL!"
      fi
    fi
  fi
done
