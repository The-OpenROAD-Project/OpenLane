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

test_set=$1
export PDK_ROOT=$(pwd)/pdks
export RUN_ROOT=$(pwd)
echo $PDK_ROOT
echo $RUN_ROOT
docker run -it -v $RUN_ROOT:/openLANE_flow -v $PDK_ROOT:$PDK_ROOT -e PDK_ROOT=$PDK_ROOT -u $(id -u $USER):$(id -g $USER) openlane:rc3  bash -c "python3 run_designs.py -d $(cat $RUN_ROOT/travisCI/$test_set) -t TEST_$test_set -dl -th 20 -b regression_results/benchmark_results/SW_HD.csv -p 30"

FILE=$RUN_ROOT/regression_results/TEST_$test_set*/TEST_$test_set*_design_test_report.csv
echo "Verbose Differences with the Benchmark"
cat $RUN_ROOT/regression_results/TEST_$test_set*/TEST_$test_set*.rpt 
echo "Full report:"
cat $RUN_ROOT/regression_results/TEST_$test_set*/TEST_$test_set*_best.csv
echo "Fail/Pass report:"
echo "Design,Status,Reason"
cat $FILE
crashSignal=$(find $FILE)
if ! [[ $crashSignal ]]; then exit -1; fi
val=$(grep "FAILED" $FILE | wc -l)
if ! [[ $val ]]; then val=0; fi
exit $val