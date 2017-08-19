#!/bin/bash

day=$1
dir="/users/localadmin/persistent_vast/real-demo/intelmq"

echo "Importing data for blacklist [intelmq] for [$day]."
cat $dir/$day/*.log | vast import bro 'classification.type == "spam"'
