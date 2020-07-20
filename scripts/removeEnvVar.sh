#This script removes all occurencies of assignments of a specific environment variable from all default config.tcl of all designs in a directory 
#use: sh removeEnvVar.sh DESIGNS_PATH ENVIRONMENT_VARIABLE_NAME

path=$1
envVar=$2
find ${path}/*/config.tcl | xargs grep "${envVar}" | cut -d ':' -f 1 | xargs sed -i -E "s/^.*${envVar}.*$//g"
