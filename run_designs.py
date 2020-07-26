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

import queue
import sys
import time
import subprocess
import threading
import logging
import datetime
import argparse
import os
import pandas as pd
from collections import OrderedDict

from scripts.report.report import Report
from scripts.config.config import ConfigHandler
import scripts.utils.utils as utils


parser = argparse.ArgumentParser(
        description="Regression test on designs")
parser.add_argument('--config_tag', '-c', action='store', default='config',
                help="config file")
parser.add_argument('--regression', '-r', action='store', default=None,
                help="regression file")
parser.add_argument('--designs', '-d', nargs='+', default=['spm'],
                help="designs to run")
parser.add_argument('--tag', '-t', action='store', default='regression',
                help="tag the log file")
parser.add_argument('--threads', '-th', action='store', type=int, default=5,
                help="number of designs in parallel")
parser.add_argument('--configuration_parameters', '-cp', action='store', default=None,
                help="file containing configuration parameters to write in report, to report all possible configurations add: all ")
parser.add_argument('--append_configurations', '-app', action='store_true', default=False,
                help="append configuration parameters provided to the existing default printed configurations")

parser.add_argument('--clean', '-cl', action='store_true', default=False,
                help="cleans all intermediate files in runs")

parser.add_argument('--delete', '-dl', action='store_true', default=False,
                help="deletes the whole run directory upon completion leaving only the final_report.txt file")

parser.add_argument('--tarList', '-tar',  nargs='+', default=None,
                help="tars the specified sub directories and deletes the whole directory leaving only the compressed version")

parser.add_argument('--htmlExtract', '-html', action='store_true', default=False,
                help="An option to extract an html summary of the final csv summary")

parser.add_argument('--defaultTestSet', '-dts', action='store_true', default=False,
                help="Runs the default test set to generate the regression sheet")

args = parser.parse_args()

regression = args.regression
tag = args.tag
if args.defaultTestSet:
        defaultTestSetFileOpener = open('./designs/defaultTestSet.list', 'r')
        designs = defaultTestSetFileOpener.read().split()
        defaultTestSetFileOpener.close()
else:
        designs = list(OrderedDict.fromkeys(args.designs))
num_workers = args.threads
config = args.config_tag
tarList = ['']
if args.tarList is not None:
        tarList = list(OrderedDict.fromkeys(args.tarList))

if args.regression is not None:
        regressionConfigurationsList = []
        regressionFileOpener = open(regression,"r")
        regressionFileContent = regressionFileOpener.read().split()
        regressionFileOpener.close()
        for k in regressionFileContent:
                if k.find("=") == -1:
                        continue
               
                if k.find("extra") != -1:
                        break
                else:
                        regressionConfigurationsList.append(k.split("=")[0])
        if len(regressionConfigurationsList):
                ConfigHandler.update_configuration_values(regressionConfigurationsList,True)

if args.configuration_parameters is not None:
        if args.configuration_parameters == "all":
                ConfigHandler.update_configuration_values_to_all(args.append_configurations)
        else:
                try:
                        tmpFile = open(args.configuration_parameters,"r")
                        if tmpFile.mode == 'r':
                                configuration_parameters = tmpFile.read().split(",")
                                ConfigHandler.update_configuration_values(configuration_parameters,args.append_configurations)
                except  OSError:
                        print ("Could not open/read file:", args.configuration_parameters)
                        sys.exit()

report_file_name = "./regression_results/{tag}_{date}".format(tag=tag, date=datetime.datetime.now().strftime('%d_%m_%Y_%H_%M'))
log = logging.getLogger("log")
log_formatter = logging.Formatter('[%(asctime)s - %(levelname)5s] %(message)s')
handler1 = logging.FileHandler("{report_file_name}.log".format(report_file_name=report_file_name), 'w')
handler1.setFormatter(log_formatter)
log.addHandler(handler1)
handler2 = logging.StreamHandler()
handler2.setFormatter(log_formatter)
log.addHandler(handler2)
log.setLevel(logging.INFO)

report_log = logging.getLogger("report_log")
report_formatter = logging.Formatter('%(message)s')
report_handler = logging.FileHandler("{report_file_name}.csv".format(report_file_name=report_file_name), 'w')
report_handler.setFormatter(report_formatter)
report_log.addHandler(report_handler)
report_log.setLevel(logging.INFO)

report_log.info(Report.get_header() + "," + ConfigHandler.get_header())

def run_design(designs_queue):
        while not designs_queue.empty():
                design, config, tag= designs_queue.get(timeout=3)  # 3s timeout
                run_path = utils.get_run_path(design=design, tag=tag)
                command = './flow.tcl -design {design} -tag {tag} -overwrite -disable_output -config_tag {config} -no_save'.format(design=design,tag=tag, config=config)
                log.info('{design} {tag} running'.format(design=design, tag=tag))
                try:
                        subprocess.check_output(command.split(), stderr=subprocess.PIPE)
                except subprocess.CalledProcessError as e:
                        error_msg = e.stderr.decode(sys.getfilesystemencoding())
                        #print(error_msg)
                        log.error('{design} {tag} failed check {run_path}error.txt'.format(design=design, run_path=run_path, tag=tag))
                        #report_log.error('{design} {tag} failed'.format(design=design, tag=tag))
                        with open(run_path + "error.txt", "w") as error_file:
                                error_file.write(error_msg)

                        #continue

                log.info('{design} {tag} finished\t Writing report..'.format(design=design, tag=tag))
                params = ConfigHandler.get_config(design, tag)

                report = Report(design, tag, params).get_report()
                report_log.info(report)
        
                with open(run_path + "final_report.txt", "w") as report_file:
                        report_file.write(Report.get_header() + ", " + ConfigHandler.get_header())
                        report_file.write("\n")
                        report_file.write(report)
                
                if args.clean:
                        log.info('{design} {tag} Cleaning tmp Directory..'.format(design=design, tag=tag))
                        moveUnPadded_cmd = "cp ./designs/{design}/runs/{tag}/tmp/merged_unpadded.lef ./designs/{design}/runs/{tag}/results/".format(
                                design=design,
                                tag=tag
                        )
                        subprocess.check_output(moveUnPadded_cmd.split())

                        clean_cmd = "rm -rf ./designs/{design}/runs/{tag}/tmp/".format(
                                design=design,
                                tag=tag
                        )
                        subprocess.check_output(clean_cmd.split())
                        log.info('{design} {tag} Cleaning tmp Directory Finished'.format(design=design, tag=tag))
               
                
                if tarList[0] != "":
                        log.info('{design} {tag} Compressing Run Directory..'.format(design=design, tag=tag))
                        if 'all' in tarList: 
                                tarAll_cmd = "tar -cvzf ./designs/{design}/runs/{design}_{tag}.tar.gz ./designs/{design}/runs/{tag}/".format(
                                        design=design,
                                        tag=tag
                                )
                                subprocess.check_output(tarAll_cmd.split())
                                
                        else:
                                tarString = "tar -cvzf ./designs/{design}/runs/{design}_{tag}.tar.gz"
                                for dirc in tarList:
                                        tarString+=  " ./designs/{design}/runs/{tag}/"+dirc
                                tar_cmd = tarString.format(
                                        design=design,
                                        tag=tag
                                )
                                subprocess.check_output(tar_cmd.split())
                        log.info('{design} {tag} Compressing Run Directory Finished'.format(design=design, tag=tag))

                if args.delete:                
                        log.info('{design} {tag} Deleting Run Directory..'.format(design=design, tag=tag))
                        
                        deleteDirectory = "rm -rf ./designs/{design}/runs/{tag}/".format(
                                design=design,
                                tag=tag
                        )
                        subprocess.check_output(deleteDirectory.split())

                        log.info('{design} {tag} Deleting Run Directory Finished..'.format(design=design, tag=tag))


print(designs)

def addCellPerMMSquaredOverCoreUtil(filename):
        data = pd.read_csv(filename)
        df = pd.DataFrame(data)
        df.insert(5, '(Cell/mm^2)/Core_Util', df['CellPer_mm^2']/(df['FP_CORE_UTIL']/100), True)
        df.to_csv(filename)


que = queue.Queue()
total_runs = 0
if regression is not None:
    regression_file = os.path.join(os.getcwd(), regression)
    print(regression_file)
    number_of_configs=0
    for design in designs:
        base_path = utils.get_design_path(design=design)
        if base_path is None:
            print("{design} not found, skipping...".format(design=design))
            continue

        base_config_path=base_path+"base_config.tcl"

        ConfigHandler.gen_base_config(design, base_config_path)
        gen_config_cmd="./scripts/config/generate_config.sh {base_config} {output_path} config_{tag} {regression_file}".format(
            base_config=base_config_path,
            output_path=base_path,
            tag=tag,
            regression_file=regression_file
            )

        number_of_configs = subprocess.check_output(gen_config_cmd.split())
        number_of_configs = int(number_of_configs.decode(sys.getdefaultencoding()))
        total_runs = total_runs + number_of_configs

        for i in range(number_of_configs):
            config_tag = "config_{tag}_{idx}".format(
                    tag=tag,
                    idx=i
                    )
            config_file = "{base_path}/{config_tag}".format(
                    base_path=base_path,
                    config_tag=config_tag,
                    )
            que.put((design, config_tag, config_tag))
else:
    for design in designs:
        default_config_tag = "config_{tag}".format(tag=tag)
        que.put((design, config, default_config_tag))


workers = []
for i in range(num_workers):
        workers.append(threading.Thread(target=run_design, args=(que,)))
        workers[i].start()

for i in range(num_workers):
        while workers[i].isAlive() == True:
                workers[i].join(100)
        print("Exiting thread", i)

log.info("Getting top results..")
best_result_cmd = "python3 ./scripts/report/get_best.py -i {input} -o {output}".format(
        input=report_handler.baseFilename,
        output=report_file_name + "_best.csv"
        )
subprocess.check_output(best_result_cmd.split())

if args.htmlExtract:
        log.info("Converting to html..")
        csv2html_result_cmd = "python3 ./scripts/csv2html/main.py {input} {output}".format(
                input=report_file_name + ".csv",
                output=report_file_name + ".html"
                )
        subprocess.check_output(csv2html_result_cmd.split())

        csv2besthtml_result_cmd = "python3 ./scripts/csv2html/main.py {input} {output}".format(
                input=report_file_name + "_best.csv",
                output=report_file_name + "_best.html"
                )
        subprocess.check_output(csv2besthtml_result_cmd.split())

addCellPerMMSquaredOverCoreUtil(report_file_name + ".csv")

addCellPerMMSquaredOverCoreUtil(report_file_name + "_best.csv")

log.info("Done")




