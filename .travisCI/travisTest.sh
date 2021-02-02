#!/bin/bash
# Copyright 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "Running The Standard Test Process..."
echo "IMAGE NAME: $IMAGE_NAME"
echo "PDK ROOT: $PDK_ROOT"
echo "RUN ROOT: $RUN_ROOT"
if [ -z "$EXTRA_FLAGS" ]; then EXTRA_FLAGS=""; fi

DESIGNS_LIST=$TEST_SET

file_path=$RUN_ROOT/.travisCI/test_sets/$TEST_SET
if [ -f $file_path ]; then DESIGNS_LIST=$(cat $file_path); fi

docker run -it -v $RUN_ROOT:/openLANE_flow -v $PDK_ROOT:$PDK_ROOT -e PDK_ROOT=$PDK_ROOT -u $(id -u $USER):$(id -g $USER) $IMAGE_NAME  bash -c "python3 run_designs.py -d $DESIGNS_LIST -t TEST_$TEST_SET -dl -dt -th $(nproc) -b regression_results/benchmark_results/SW_HD.csv -p 30 $EXTRA_FLAGS"

FILE=$RUN_ROOT/regression_results/TEST_$TEST_SET/TEST_${TEST_SET}_design_test_report.csv
echo "Verbose Differences with the Benchmark"
cat $RUN_ROOT/regression_results/TEST_$TEST_SET/TEST_$TEST_SET*.rpt
echo "Full report:"
cat $RUN_ROOT/regression_results/TEST_$TEST_SET/TEST_$TEST_SET.csv
echo "Fail/Pass report:"
echo "Design,Status,Reason"
cat $FILE
crashSignal=$(find $FILE)
if ! [[ $crashSignal ]]; then exit -1; fi
val=$(grep "FAILED" $FILE | wc -l)
if ! [[ $val ]]; then val=0; fi
exit $val
