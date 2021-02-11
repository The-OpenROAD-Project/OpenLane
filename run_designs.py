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
import copy
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
                help="Runs the default test set (all designs under ./designs/) to generate the regression sheet")
parser.add_argument('--excluded_designs', '-e', nargs='+', default=[],
                help="designs to exclude from the run")
parser.add_argument('--benchmark', '-b', action='store', default=None,
                help="benchmark report file to compare with")
parser.add_argument('--print_rem', '-p', action='store', default=None,
                help="Takes a time period, and prints the list of remaining designs periodically based on it")
parser.add_argument('--disable_timestamp', '-dt',action='store_true', default=False,
                help="Disables appending the timestamp to the file names and tags.")
parser.add_argument('--show_output', '-so',action='store_true', default=False,
                help="Enables showing the ./flow.tcl output into the stdout. If more than one design/more than one configuration is run, this flag will be treated as False, even if specified otherwise.")


args = parser.parse_args()

regression = args.regression
tag = args.tag
if args.defaultTestSet:
        designs= [x  for x in os.listdir('./designs/')]
        for i in designs:
                if os.path.isdir('./designs/'+i) == False:
                        designs.remove(i)
else:
        designs = list(OrderedDict.fromkeys(args.designs))

excluded_designs = list(OrderedDict.fromkeys(args.excluded_designs))



for excluded_design in excluded_designs:
        if excluded_design in designs:
                designs.remove(excluded_design)

show_log_output = args.show_output & (len(designs) == 1) & (args.regression is None)


if args.print_rem is not None and show_log_output == False:
        if float(args.print_rem) > 0:
                mutex = threading.Lock()
                print_rem_time = float(args.print_rem)
        else:
                print_rem_time = None
else:
        print_rem_time = None


if print_rem_time is not None:
        rem_designs = dict.fromkeys(designs, 1)

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

store_dir = ""
report_file_name = ""
if args.disable_timestamp:
        store_dir =  "./regression_results/{tag}/".format(tag=tag)
        report_file_name = "{store_dir}/{tag}".format(store_dir=store_dir,tag=tag)
else:
        store_dir =  "./regression_results/{tag}_{date}/".format(tag=tag, date=datetime.datetime.now().strftime('%d_%m_%Y_%H_%M'))
        report_file_name = "{store_dir}/{tag}_{date}".format(store_dir=store_dir,tag=tag, date=datetime.datetime.now().strftime('%d_%m_%Y_%H_%M'))

if os.path.exists(store_dir) == False:
    os.makedirs(store_dir, exist_ok=True)

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


allow_print_rem_designs = False
def printRemDesignList():
        t = threading.Timer(print_rem_time, printRemDesignList)
        t.start()
        if allow_print_rem_designs:
                print("Remaining designs (design, # of times): ",rem_designs)
        if len(rem_designs) == 0:
                t.cancel()

def rmDesignFromPrintList(design):
        if design in rem_designs.keys():
                mutex.acquire()
                try:
                        rem_designs[design]-=1        
                        if rem_designs[design] == 0:
                                rem_designs.pop(design)
                finally:
                        mutex.release()

if print_rem_time is not None:
        printRemDesignList()
        allow_print_rem_designs = True


def run_design(designs_queue):
        while not designs_queue.empty():
                design, config, tag,design_name= designs_queue.get(timeout=3)  # 3s timeout
                run_path = utils.get_run_path(design=design, tag=tag)
                command = './flow.tcl -design {design} -tag {tag} -overwrite -disable_output -config_tag {config} -no_save'.format(design=design,tag=tag, config=config)
                log.info('{design} {tag} running'.format(design=design, tag=tag))
                command = ""
                if show_log_output:
                        command = './flow.tcl -design {design} -tag {tag} -overwrite -config_tag {config} -no_save'.format(design=design,tag=tag, config=config)
                else:
                        command = './flow.tcl -design {design} -tag {tag} -overwrite -disable_output -config_tag {config} -no_save'.format(design=design,tag=tag, config=config)
                skip_rm_from_rems = False
                try:
                        if show_log_output:
                                process = subprocess.Popen(command.split(), stderr=subprocess.PIPE, stdout=subprocess.PIPE)
                                while True:
                                        output = process.stdout.readline()
                                        if not output:
                                                break
                                        if output:
                                                print (str(output.strip())[2:-1])
                        else:
                                subprocess.check_output(command.split(), stderr=subprocess.PIPE)
                except subprocess.CalledProcessError as e:
                        if print_rem_time is not None:
                                rmDesignFromPrintList(design)
                                skip_rm_from_rems = True
                        error_msg = e.stderr.decode(sys.getfilesystemencoding())
                        log.error('{design} {tag} failed check {run_path}error.txt'.format(design=design, run_path=run_path, tag=tag))
                        with open(run_path + "error.txt", "w") as error_file:
                                error_file.write(error_msg)

                if print_rem_time is not None and not skip_rm_from_rems:
                        rmDesignFromPrintList(design)

                log.info('{design} {tag} finished\t Writing report..'.format(design=design, tag=tag))
                params = ConfigHandler.get_config(design, tag)

                report = Report(design, tag, design_name,params).get_report()
                report_log.info(report)

                with open(run_path + "final_report.txt", "w") as report_file:
                        report_file.write(Report.get_header() + "," + ConfigHandler.get_header())
                        report_file.write("\n")
                        report_file.write(report)

                if args.benchmark is not None:
                        try:

                                log.info('{design} {tag} Comparing vs benchmark results..'.format(design=design, tag=tag))
                                design_benchmark_comp_cmd = "python3 scripts/compare_regression_design.py -b {benchmark} -r {this_run} -o {output_report} -d {design} -rp {run_path}".format(
                                        benchmark=args.benchmark,
                                        this_run=report_file_name + ".csv",
                                        output_report=report_file_name + "_design_test_report.csv",
                                        design=design,
                                        run_path=run_path
                                )
                                subprocess.check_output(design_benchmark_comp_cmd.split())
                        except subprocess.CalledProcessError as e:
                                error_msg = e.stderr.decode(sys.getfilesystemencoding())
                                log.error('{design} {tag} failed to compare with benchmark: {error_msg}'.format(design=design, tag=tag, error_msg=error_msg))

                if args.clean:
                        try:
                                log.info('{design} {tag} Cleaning tmp Directory..'.format(design=design, tag=tag))
                                moveUnPadded_cmd = "cp {run_path}/tmp/merged_unpadded.lef {run_path}/results/".format(
                                        run_path=run_path,
                                        tag=tag
                                )
                                subprocess.check_output(moveUnPadded_cmd.split())

                                clean_cmd = "rm -rf {run_path}/tmp/".format(
                                        run_path=run_path,
                                        tag=tag
                                )
                                subprocess.check_output(clean_cmd.split())
                                log.info('{design} {tag} Cleaning tmp Directory Finished'.format(design=design, tag=tag))
                        except subprocess.CalledProcessError as e:
                                error_msg = e.stderr.decode(sys.getfilesystemencoding())
                                log.error('{design} {tag} failed to clean the tmp directory: {error_msg}'.format(design=design, tag=tag, error_msg=error_msg))

                if tarList[0] != "":
                        log.info('{design} {tag} Compressing Run Directory..'.format(design=design, tag=tag))
                        try:
                                if 'all' in tarList:
                                        tarAll_cmd = "tar -cvzf {run_path}../{design_name}_{tag}.tar.gz {run_path}".format(
                                                run_path=run_path,
                                                design_name=design_name,
                                                tag=tag
                                        )
                                        subprocess.check_output(tarAll_cmd.split())
                                else:
                                        tarString = "tar -cvzf {run_path}../{design_name}_{tag}.tar.gz"
                                        for dirc in tarList:
                                                tarString+=  " {run_path}"+dirc
                                        tar_cmd = tarString.format(
                                                run_path=run_path,
                                                design_name=design_name,
                                                tag=tag
                                        )
                                        subprocess.check_output(tar_cmd.split())
                                log.info('{design} {tag} Compressing Run Directory Finished'.format(design=design, tag=tag))
                        except subprocess.CalledProcessError as e:
                                log.info('{design} {tag} Compressing Run Directory Failed'.format(design=design, tag=tag))

                if args.delete:
                        try:
                                log.info('{design} {tag} Deleting Run Directory..'.format(design=design, tag=tag))
                                deleteDirectory = "rm -rf {run_path}".format(
                                        run_path=run_path
                                )
                                subprocess.check_output(deleteDirectory.split())

                                log.info('{design} {tag} Deleting Run Directory Finished..'.format(design=design, tag=tag))
                        except subprocess.CalledProcessError as e:
                                error_msg = e.stderr.decode(sys.getfilesystemencoding())
                                log.error('{design} {tag} failed to delete the run directory: {error_msg}'.format(design=design, tag=tag, error_msg=error_msg))






que = queue.Queue()
total_runs = 0
if regression is not None:
    regression_file = os.path.join(os.getcwd(), regression)
    number_of_configs=0
    for design in designs:
        base_path = utils.get_design_path(design=design)
        if base_path is None:
            log.error("{design} not found, skipping...".format(design=design))
            if print_rem_time is not None:
                if design in rem_designs.keys():
                        rem_designs.pop(design)
            continue
        design_name= utils.get_design_name(design, config)
        if design_name.startswith("[INVALID]:"):
            log.error('{design} will not Run, {reason}'.format(design=design, reason=design_name))
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
        if print_rem_time is not None:
                rem_designs[design] = number_of_configs
        for i in range(number_of_configs):
            config_tag = "config_{tag}_{idx}".format(
                    tag=tag,
                    idx=i
                    )
            config_file = "{base_path}/{config_tag}".format(
                    base_path=base_path,
                    config_tag=config_tag,
                    )
            que.put((design, config_tag, config_tag,design_name))
else:
    for design in designs:
        base_path = utils.get_design_path(design=design)
        if base_path is None:
            log.error("{design} not found, skipping...".format(design=design))
            if print_rem_time is not None:
                if design in rem_designs.keys():
                        rem_designs.pop(design)
            continue
        default_config_tag = "config_{tag}".format(tag=tag)
        design_name= utils.get_design_name(design, config)
        if design_name.startswith("[INVALID]:"):
            log.error('{design} Will not Run, {reason}'.format(design=design, reason=design_name))
            continue
        que.put((design, config, default_config_tag,design_name))


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
        csv2html_result_cmd = "python3 ./scripts/csv2html/csv2html.py -i {input} -o {output}".format(
                input=report_file_name + ".csv",
                output=report_file_name + ".html"
                )
        subprocess.check_output(csv2html_result_cmd.split())

        csv2besthtml_result_cmd = "python3 ./scripts/csv2html/csv2html.py -i {input} -o {output}".format(
                input=report_file_name + "_best.csv",
                output=report_file_name + "_best.html"
                )
        subprocess.check_output(csv2besthtml_result_cmd.split())

utils.addComputedStatistics(report_file_name + ".csv")

utils.addComputedStatistics(report_file_name + "_best.csv")


if args.benchmark is not None:
        log.info("Generating final benchmark results..")
        full_benchmark_comp_cmd = "python3 scripts/compare_regression_reports.py -ur -b {benchmark} -r {this_run} -o {output_report} -x {output_xlsx}".format(
                benchmark=args.benchmark,
                this_run=report_file_name + ".csv",
                output_report=report_file_name + "_benchmark_written_report.rpt",
                output_xlsx=report_file_name + "_benchmark_final_report.xlsx"
        )
        subprocess.check_output(full_benchmark_comp_cmd.split())



log.info("Done")
