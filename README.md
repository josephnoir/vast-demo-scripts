# Work Flow

## Build (on mobi7)

CAF commit: cdfe2c2236aebceaa13145c2999af6039dcfc3c9
```
CXX=/opt/src/clang/build/bin/clang++ LDFLAGS="$(/opt/src/clang/build/bin/llvm-config --ldflags) -lc++abi" ./configure --build-type=release --no-opencl --no-tools --no-examples
make -j 24
```

VAST commit: 2b761725981e5eafe3e09a8ca2bb70295e42b551
```
CXX=/opt/src/clang/build/bin/clang++ LDFLAGS="$(/opt/src/clang/build/bin/llvm-config --ldflags) -lc++abi" ./configure --build-type=release --with-caf=/$HOME/persistent_vast/actor-framework/build
make -j 24
```

## Commands

```
$ # start vast somewhere
$ # clean everything **[works with reset workaround]**
$ ./reset_vast_state.sh   # not sure where this is ...
$ 
$ # go to scripts folder in real-demo folder
$ # import spam blacklist + example query **[works]**
$ ./import_blacklist_for_day.sh 20170809
$ vast export bro "&type == \"bro::blacklist\"" | bro-cut -d source.network | sort -u | wc -l
$ 
$ # import bl honeypot + query**[works]**
$ ./filtered_import_honeypot_for_day.sh 2017-08-09
$ vast export bro "&type == \"bro::conn\"" | bro-cut -d id.orig_h | sort -u | wc -l
$
$ # start continous query for suspicious AS in another tab**[works, if backend does not crash during mrt import]**
$ # AS23456 youngest announcement is at 2017-08-09T21:22:29
$ vast export -c bro ":count == 23456" # vast export bro -c "origin_as == 23456"
$ 
$ # start importing data for suspicious days
$ ./filtered_import_mrt_for_day.sh 20170809
$ ./filtered_import_mrt_for_day.sh 20170808
$ 
$ # find some morespecific info
$ ./query_find_morespecific.sh > morespecific.txt
$ vim morespecific.txt
```

## Known problems

The continous query in to find announcements for the origin as does not work using the column name as the resulting expression fails to be tailored to the withdraw updates also included in the data which leads VAST to crash. Using the type as a workaround yields similar results here.

