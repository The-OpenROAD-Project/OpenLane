
#!/bin/bash
# SPDX-FileCopyrightText: 2020 Efabless Corporation
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
# SPDX-License-Identifier: Apache-2.0

# Adopted from Chris Snow
# https://stackoverflow.com/questions/26082444/how-to-work-around-travis-cis-4mb-output-limit/26082445#26082445

# Abort on Error
set -e

# Test script is provided as a relative path
export WORKDIR=$(pwd)
export COMMAND=$1
export TAILING_LINES=${2:-500}
export PING_SLEEP=30s
export BUILD_OUTPUT=$WORKDIR/build.out

touch $BUILD_OUTPUT

dump_output() {
   echo Tailing the last $TAILING_LINES lines of output:
   tail -$TAILING_LINES $BUILD_OUTPUT
   rm -f $BUILD_OUTPUT
}
error_handler() {
  echo ERROR: An error was encountered with the build.
  dump_output
  kill $PING_LOOP_PID
  exit 1
}
# If an error occurs, run our error handler to output a tail of the build
trap 'error_handler' ERR

# Set up a repeating loop to send some output to Travis.

bash -c "while true; do echo \$(date) - running $COMMAND ...; sleep $PING_SLEEP; done" &
export PING_LOOP_PID=$!

# your_build_command_1 >> $BUILD_OUTPUT 2>&1
# your_build_command_2 >> $BUILD_OUTPUT 2>&1
$COMMAND >> $BUILD_OUTPUT 2>&1

# The build finished without returning an error so dump a tail of the output
dump_output

# nicely terminate the ping output loop
kill $PING_LOOP_PID
