#!/bin/bash -i
alias d=done e=unset f=printf\ -v g=local h=else i=then j=for k=while C=do E=fi
n(){ g s e i;j i in ${!u[@]};C [ $1 -ge $[i+1] ]&&[ $1 -le $[u[i]+1] ]&&s=$i
  [ $2 -ge $[i-1] ]&&[ $2 -le $[u[i]-1] ]&&e=$i;d;if [ "$s" ];i if [ "$e" ];i \
    [ $s -ne $e ]&&{ u[s]=${u[e]};e u[e];};h [ $1 -lt $s ]&&{ u[$1]=${u[s]};e u[s
  ];s=$1;};[ $2 -gt ${u[s]} ]&&u[s]=$2;E;h if [ "$e" ];i [ $1 -lt $e ]&&{ u[$1
  ]=${u[e]};e u[e];e=$1;};[ $2 -gt ${u[e]} ]&&u[e]=$2;h u[$1]=$2;E;E;};q(){ 
  g s=${1#*/} m=${1%/*} z;[ -z "${s//*.*}" ]&&s=32;y $s z;set -- ${m//./ }
  m=$[$1<<24|$2<<16|$3<<8|$4];n $[m&z] $[m|((2**32-1)^z)];};y(){ f $2 "%u" $[ (
  2**32-1)^(~0^~0<<(32-$1))];};r(){ f $2 "%s" $[$1>>24].$[$1>>16&255].$[$1>>8&
  255].$[$1&255];};t(){ g s z;k [ "$1" ];C s=32;k y $[s-1] z&&[ $1 = $[($1>>(33
  -s))<<(33-s)] ]&&[ $2 -ge $[$1|((2**32-1)^z)] ];C ((s--));d;r $1 x;echo $x/$s
  y $s z;if [ $2 -gt $[$1|((2**32-1)^z)] ];i set -- $[1+($1|((2**32-1)^z))] $2
  h shift 2;E;d;};k read w;C q $w;d;p=-1;j o in ${!u[@]};C [ $o -gt $p ]&&p=${u[
  o]}&&t $o ${u[o]};d
