#!/bin/bash
#set -e
start=`date +%s`


rm -rf lib/generated/swaggen/*
dart run build_runner build


end=`date +%s`
runtime=$((end-start))
echo "Took $runtime sec to run"
