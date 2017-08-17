#!/bin/bash

dir="/users/localadmin/persistent_vast/real-demo/state"

vast stop
rm -r $dir

vast start -d $dir
