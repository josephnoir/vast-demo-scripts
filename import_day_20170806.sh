#!/bin/bash

day="2017-08-06"
dir="/users/localadmin/persistent_vast/real-demo/scripts"

$dir/import_honeypot.sh $day
$dir/import_blacklist.sh $day
