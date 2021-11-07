import re
import argparse
import os

parser = argparse.ArgumentParser(
    description='Converts a 23-spef_extraction_multi_corner_sta.min.rpt file to a eco insert buffer tcl file.')

parser.add_argument('--input_file', '-i', required=True,
                    help='input 23-spef_extraction_multi_corner_sta.min.rpt')

parser.add_argument('--output_file', '-o', required=True,
                    help='output eco_fix.tcl')

args = parser.parse_args()
input_file = args.input_file
output_file = args.output_file

splitLine = "\n\n\n"
printArr = []

# iteration to find minus slack
# create insert_buffer command
# Converting Magic DRC
if os.path.exists(input_file):
    drcFileOpener = open(input_file)
    if drcFileOpener.mode == 'r':
        drcContent = drcFileOpener.read()
    drcFileOpener.close()

    # design name
    # violation message
    # list of violations
    # Total Count:
    vio_count = 0
    if drcContent is not None:
        drcSections = drcContent.split(splitLine)
        # if (len(drcSections) > 2):
        for i in range(0, len(drcSections)):
            vio_name = drcSections[i].strip()
            minus_time_str = re.search(
                '(-[0-9]+\.[0-9]+) +slack', vio_name)
            if (minus_time_str != None):
                vio_count += 1
                start_point_str = re.search('Startpoint: (.*?)[ \n]', vio_name)
                if (start_point_str != None):
                    start_point = start_point_str.group(1)
                    start_pin = re.search(start_point+'/Q', vio_name)
                    insert_buffer_line = "insert_buffer " \
                        + start_point+'/Q' \
                        + " " \
                        + "sky130_fd_sc_hd__dlygate4sd3_1" \
                        + " net_HOLD_NET_" +str(vio_count) \
                        + " U_HOLD_FIX_BUF" +str(vio_count)
                    printArr.append(insert_buffer_line)
                    print(insert_buffer_line)
        if vio_count == 0:
            insert_buffer_line = "No violations found"
            printArr.append(insert_buffer_line)
else:
    printArr.append("Source not found.")

# write into file
outputFileOpener = open(output_file, "w")
outputFileOpener.write("\n".join(printArr))
outputFileOpener.close()


