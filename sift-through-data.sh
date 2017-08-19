#!/bin/bash

# removed:
# 2017-06-30 2017-07-03 2017-07-07 2017-07-12 2017-07-13 
# 20170630 20170703 20170707 20170712 20170713 
DATES_SEP=(2017-07-16 2017-07-18 2017-07-31 2017-08-02 2017-08-03 2017-08-05 2017-08-06 2017-08-07 2017-08-08 2017-08-09 2017-08-11 2017-08-12 2017-08-14 2017-08-15)
DATES_COM=(20170716 20170718 20170731 20170802 20170803 20170805 20170806 20170807 20170808 20170809 20170811 20170812 20170814 20170815)
VSTATE="$(pwd)/.vast-state"
VPID=0

cnt=0
while [ "x${DATES_SEP[cnt]}" != "x" ]
do
  sep=${DATES_SEP[cnt]}
  com=${DATES_COM[cnt]}
  next=$(( $cnt + 1 ))
  sep_next=${DATES_SEP[next]}
  com_next=${DATES_COM[next]}
  echo "################################################################################"
  echo "Starting tests for $sep"
  echo "Using vast at $(which vast)"
  res_dir="$(pwd)/results-$sep"
  echo "Result directory: $res_dir"
# start vast
  vast -d $VSTATE start
  #VPID=$!
  #echo "Started VAST with PID = $VPID"
  echo "Started VAST with stat at $VSTATE"
# import blacklists
  echo "Importing blacklists"
  ./import_blacklist_for_day.sh $com
# import honeypots
  echo "Importing honeypot logs"
  ./filtered_import_honeypot_for_day.sh $sep
# import mrt day $cnt
  echo "Importing MRT accouncements"
  ./filtered_import_mrt_for_day.sh $com
# import mrt day $cnt + 1
  ./filtered_import_mrt_for_day.sh $com_next
# statistics script into logs
  ./query_find_ephemeralannouncements.sh > ephemeral.log
  ./query_find_morespecific.sh > morespecific.log
  ./query_find_multipleorigins.sh > multipleorigins.log
  ./query_find_withdrawn.sh > withdrawn.log
# move log files into folder
  mkdir $res_dir
  mv *.log $res_dir
# shutdown vast
  #echo "Killing VAST"
  #kill $VPID
  echo "Stopping VAST"
  vast stop
# remove state
  echo "Removing state"
  rm -rf $VSTATE
# next date
  cnt=$(( $cnt + 1 ))
done

