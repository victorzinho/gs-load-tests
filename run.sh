#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROPS="${DIR}/jmeter.properties"

USAGE="usage: $0 [-t <timeout>] [-s <sleep>] <files>..."
HELP="""
${USAGE}

Options:
  -h              Shows this help
  -t <timeout>    Tests are killed after this amount of time. Useful for
                  tests with loops. Default is no killing.
  -s <sleep>      Sleep time between tests, in seconds. Default is no sleep.
"""

while getopts ":ht:s:" opt; do
  case $opt in
    h)
      echo "$HELP"
      exit 0
      ;;
    t)
      timeout="$OPTARG"
      ;;
    s)
      sleep="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Check jmeter in path
if [ -z "`which jmeter`" ]; then 
  echo "jmeter not in path!"
  exit 1
fi

# Check numbers
if [ -n "${timeout}" ]; then
  if ! [[ ${timeout} =~ ^[0-9]+$ ]] ; then
   echo "ERROR: Invalid timeout: ${timeout}"
   exit 2
  fi
fi

if [ -n "${sleep}" ]; then
  if ! [[ ${sleep} =~ ^[0-9]+$ ]] ; then
   echo "ERROR: Invalid sleep time: ${sleep}"
   exit 2
  fi
fi

# Run
for file in ${@:$OPTIND}; do
  echo $file
  if [ -n "${timeout}" ]; then
    timeout --foreground -k ${timeout} ${timeout} jmeter -n -p ${PROPS} -t ${file}
  else
    jmeter -n -p ${PROPS} -t ${file}
  fi
  echo
  echo

  if [ -n "${sleep}" ]; then
    sleep ${sleep}
  fi
done

