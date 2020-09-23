import sys

if(len(sys.argv) < 3):
    sys.exit("Arguments should be passed: python <script_name>.py <path/lef_name>.lef <path/def_name>.def")
elif(sys.argv[1].find(".lef") == -1 or sys.argv[2].find(".def") == -1):
    sys.exit("Arguments should be passed: python <script_name>.py <path/lef_name>.lef <path/def_name>.def")
else:
    lef_file_name = sys.argv[1]
    def_file_name = sys.argv[2]
