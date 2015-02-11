#!/bin/tcsh
set called=($_)
set dir = `dirname $called[2]`
pushd $dir > /dev/null
set dir_abs = `pwd`
setenv PATH ${dir_abs}:$PATH
rehash
popd > /dev/null
