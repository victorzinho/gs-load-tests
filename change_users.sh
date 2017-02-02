#!/bin/bash

USAGE="usage: $0 <users> <files to change>..."

if [ $# -lt 2 ]; then
  echo $USAGE
  exit 1
fi

if ! [[ $1 =~ ^[0-9]+$ ]] ; then
  echo "Invalid number of users: $1"
  echo "$USAGE"
  exit 2
fi

users=$1
shift

for file in $@; do
  echo "${file}..."
  out="`basename -s .jmx ${file}`_${users}.jmx"
  sed "s/\"ThreadGroup.num_threads\">[[:digit:]]\+/\"ThreadGroup.num_threads\">${users}/g" ${file} > ${out}
done
