#!/bin/bash

: '

- Algorithm

 1. User edits the configure file (*.cfg).

 2. User runs this script with configure file.
    
    > sh 0_Configure_Setting.sh this_config_file.cfg

 3. Read config file and store TOOL_ID, TOOL_PATH in variables.
 
 4. Initialize by removing existing pipeline scripts (*_ps_*.sh), and
    re-generate by decompress the 0_INITIALIZE.

 [@] If any new scripts were added to pipeline, you should generate a new 0_INITIALIZE by tar command.
 
 5. [Check point] Check configure file and whether some settings are empty.

 6. Calculate the number of TOOL_ID and TOOL_PATH

 7. Loop N times; N = number of TOOL_ID and TOOL_PATH:

    -> 7.1 Search TOOL_ID amoung pipeline scripts (*_ps_*.sh) by grep command.

    -> 7.2 In every scripts identified by grep command, replace the "TOOL_ID" by "TOOL_PATH" by sed command.
 
 8. Complete!   
'

# replacement function
replacePath(){
 id_target=$1
 id_path=$2
 process_file=$3
 adj_path=${id_path//\//\\/}
 sed -i "s/$id_target/$adj_path/g" $process_file
}

# Input configure file
configure=$1

# Check configure file
if [ -z "$configure" ]; then
 echo -e "\033[0;31m Please specify a configure file! \033[0m"
 exit 1
fi

# Get Target
target=$(cat $configure | egrep -v "^#|^$" | awk -F : '{printf "%s,",$1}')

# Get tool path
path=$(cat $configure | egrep -v "^#|^$" | awk -F : '{printf "%s,",$2}')

# Get the number of tool and their path
IFS=',' read -ra TARGET <<< "$target"
IFS=',' read -ra TPATH <<< "$path"

# Check the configure file.
for idx in $(seq 0 $((${#TARGET[@]}-1)))
do
 if [ -z ${TARGET[$idx]} ] || [ -z ${TPATH[$idx]} ]; then
  echo -e "\033[0;31m Some tools and their paths are empty! Check the Configure file. \033[0m"
  exit 1
 fi
done

# Initialize the scripts
rm *_ps_*.sh
tar -zxf 0_INITIALIZE

# Replace the path
for idx in $(seq 0 $((${#TARGET[@]}-1)))
do
 files=$(grep ${TARGET[$idx]} ./*.sh | awk -F : '{printf "%s,",$1}')
 # Split multiple files into an array
 IFS=',' read -ra FILES <<< "$files"
 for f in ${FILES[@]}
 do
  replacePath ${TARGET[$idx]} ${TPATH[$idx]} $f
 done
done

