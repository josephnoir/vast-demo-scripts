#!/bin/bash

dir="/users/localadmin/persistent_vast/real-demo/mrt"

{

str_filter=""
# for i in $(vast export bro "&type == \"bro::blacklist\"" | bro-cut -d source.ip | grep "." | sort -u)
for i in $(vast export bro "&type == \"bro::conn\"" | bro-cut -d id.orig_h | grep "." | sort -u)
do
  str_filter="$str_filter|| $i in prefix "
done

str_filter=$(echo "$str_filter" | cut -c 4-)

#bzip2 -cd ${dir}/**/**/*.bz2 | vast import mrt $str_filter
for i in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23
do
  echo "bzip2 -cd ${dir}/20170807/updates.20170807.${i}*.bz2 | vast import mrt \"$str_filter\"" >> .commands.txt
done

cat .commands.txt | while read i; do printf "%q\n" "$i"; done | xargs --max-procs=24 -I CMD bash -c CMD

rm .commands.txt

} 2>/dev/null
