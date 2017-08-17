#!/bin/bash

#vast export bro "&type == \"bro::blacklist\"" | bro-cut -d source.network | grep "/" | sort -u
#for i in $(vast export bro "&type == \"bro::blacklist\"" | bro-cut -d source.network | grep "/" | sort -u); do for j in ./honeypot/**/**/conn.*.log.gz; do echo "zcat $j | vast import bro \"id.orig_h in $i\""; done ; done

dir="/users/localadmin/persistent_vast/real-demo/honeypot"
#FAIL=0

str_filter=""
# for i in $(vast export bro "&type == \"bro::blacklist\"" | bro-cut -d source.ip | grep "." | sort -u)
for i in $(vast export bro "&type == \"bro::blacklist\"" | bro-cut -d source.network | grep "/" | sort -u)
do
  str_filter="$str_filter|| id.orig_h in $i "
  
  # test: import all data, count for each prefix how many events match
  #echo "vast export ascii \"id.orig_h in $i\" | wc -l"
  #counter=$(vast export ascii id.orig_h in $i | wc -l)
  #echo -e "  > $counter \t $i";
  #if [ "$counter" -ne "0" ]; then
  #  echo "$i --> $counter";
  #fi
  #echo "zcat ${dir}/**/**/conn.*.log.gz | vast import bro \"id.orig_h in $i\"" >> commands.txt
  #for j in ${dir}/**/**/conn.*.log.gz
  #do
  #  echo "zcat $j | vast import bro \"id.orig_h in $i\"" >> commands.txt
  #done
  #for job in $(jobs -p)
  #do
    #wait $job || let "FAIL+=1"
  #done
done


str_filter=$(echo "$str_filter" | cut -c 4-)
zcat ${dir}/**/**/conn.*.log.gz | vast import bro $str_filter

#cat commands.txt | xargs -I CMD --max-procs 64 bash -c CMD

#rm commands.txt

#echo "$FAIL jobs failed"

echo "Used vast at \"$(which vast)\""
