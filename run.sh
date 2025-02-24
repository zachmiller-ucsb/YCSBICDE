#!/bin/bash

db=autumn
dir=~/YCSBICDE/$db
mkdir -p $dir

./run-$db.sh > $dir/out 2> $dir/err

exit 0
