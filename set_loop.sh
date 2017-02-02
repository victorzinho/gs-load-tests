#!/bin/bash

USAGE="usage: $0 <files to change>..."

if [ $# -lt 1 ]; then
  echo $USAGE
  exit 1
fi

for file in $@; do
  echo "${file}..."
  out="`basename -s .jmx ${file}`_loop.jmx"
  sed -r "s/\"LoopController.loops\">-?[[:digit:]]*/\"LoopController.loops\">-1/g" ${file} > ${out}
done
