#!/usr/bin/env bash

#set -x

# this script checks out all the projects to build

# args:
#   1) directory to create and use
#   2) os
#   3) project (dmd, druntime, phobos)
#   4) git url
#   5) git ref

. src/setup_env.sh "$2"

top=$PWD

echo -e "\tmerging pull: $3 $4 $5"

cd $top/$1/$3

if [ "$2" == "Win_32_64" -o "$2" == "Win_32" ]; then
    git stash --quiet
fi

echo >> $top/$1/$3-merge.log
N=3
for i in 1 2 3; do
    echo "fetching $4 $5 (attempt: $i/$N)" >> $top/$1/$3-merge.log 2>&1
    git fetch $4 $5 >> $top/$1/$3-merge.log 2>&1
    if [ $? -eq 0 ]; then
        break
    fi
    if [ $i -eq $N ]; then
        echo -e "\tfailed to fetch from pull repo"
        exit 1
    fi
    sleep 5
done

echo >> $top/$1/$3-merge.log
echo "merging FETCH_HEAD" >> $top/$1/$3-merge.log
git merge FETCH_HEAD >> $top/$1/$3-merge.log 2>&1
if [ $? -ne 0 ]; then
    echo -e "\tfailed to merge pull repo"
    exit 1
fi

if [ "$2" == "Win_32_64" -o "$2" == "Win_32" ]; then
    git stash pop --quiet
fi

cd $top
