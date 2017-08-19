#!/bin/bash

day=$1
#echo "Importing data for blacklist [intelmq] for [$day]."
#cat $dir/**/$day*events.log | vast import bro 'classification.type == "spam"'

dir="/users/localadmin/persistent_vast/real-demo/honeypot"

str_filter=""
for i in $(vast export bro "&type == \"bro::blacklist\"" | bro-cut -d source.network | grep "/" | sort -u)
do
  str_filter="$str_filter|| id.orig_h in $i "
done

str_filter=$(echo "$str_filter" | cut -c 4-)
zcat ${dir}/**/$day*/conn.*.log.gz | vast import bro $str_filter
