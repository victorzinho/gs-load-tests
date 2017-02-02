#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE="${DIR}/gs-load-template.jmx"

# We use 18 tiles per user. Browsers limit to 6 per domain; assuming
# 3 different domains for a single GeoServer instance
N_TILES=18

USAGE="usage: $0 [-h] [-l] [-d scales_dir] <users>..."
HELP="""
${USAGE}

Options:
  - h              Shows this help. 
  - l              Generate tests with loop (executed until stopped).
                   Default is false.
  - d <scales_dir> Directory containing the scales to generate.
                   Default is 'scales'.
  - <users>        List of user amounts to use; numbers separated by spaces.
                   Note that each user will perform 18 requests at the same 
                   time (browsers limit to 6 per domain; assuming 3 different
                   domains for a single GeoServer instance).

Example:
  $ $0 -d ./my_scales_dir 1 2 3 5
"""

scales_dir="scales"
loop="false"

while getopts ":hld:" opt; do
  case $opt in
    h)
      echo "$HELP"
      exit 0
      ;;
    d)
      scales_dir="$OPTARG"
      ;;
    l)
      loop="true"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

if [ ! -d ${scales_dir} ]; then 
  echo "ERROR: Scales directory does not exist: ${scales_dir}"
  echo "$USAGE"
  exit 1
fi

users=${@:$OPTIND}
if [ -z "${users}" ]; then
  echo "ERROR: Missing users"
  echo "$USAGE"
  exit 1
fi

for user in ${users}; do
  if ! [[ ${user} =~ ^[0-9]+$ ]] ; then
   echo "ERROR: Invalid number of users: ${user}"
   exit 2
  fi
done

for scale in `ls ${scales_dir}`; do
#  echo ${scale}
  for i in `seq ${N_TILES}`; do
    xmlstarlet edit -u "/jmeterTestPlan/hashTree/hashTree/hashTree[`expr $i + 1`]/HTTPSamplerProxy/elementProp/collectionProp/elementProp[@name='BBOX']/stringProp[@name='Argument.value']" -v `sed "${i}q;d" ${scales_dir}/${scale}` ${TEMPLATE} > gs-scale-${scale}.jmx
  done
done

files=`ls gs-scale-*.jmx`
for file in ${files}; do
  for u in ${users}; do
    out="`basename -s .jmx ${file}`_${u}.jmx"
    sed "s/\"ThreadGroup.num_threads\">[[:digit:]]\+/\"ThreadGroup.num_threads\">${u}/g" ${file} > ${out}
  done
  rm ${file}
done

if [ ${loop} == "true" ]; then
  files=`ls gs-scale-*.jmx`
  for file in ${files}; do
    out="`basename -s .jmx ${file}`_loop.jmx"
    sed -r "s/\"LoopController.loops\">-?[[:digit:]]*/\"LoopController.loops\">-1/g" ${file} > ${out}
  done
fi

