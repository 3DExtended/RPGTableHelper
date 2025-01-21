#!/bin/bash
#set -e
start=`date +%s`

flutter test --update-goldens --fail-fast

end=`date +%s`
runtime=$((end-start))
echo "Took $runtime sec to run"
