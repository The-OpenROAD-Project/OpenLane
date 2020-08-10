import subprocess

parser = argparse.ArgumentParser(
        description="Regression test on designs")
parser.add_argument('--config_tag', '-c', action='store', default='config',
                help="config file")


run_designs_cmd = "python3 ./scripts/csv2html/csv2html.py -i {input} -o {output}".format(
        input=report_file_name + "_best.csv",
        output=report_file_name + "_best.html"
        )