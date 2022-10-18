#!/bin/bash 
large_csv="${1}/large_dataset.csv"
huge_csv="${1}/huge_dataset.csv" 
for i in {0..7}
  do
    if [[ $i -eq 0 ]] ; then
      head -1 $large_csv > $huge_csv
    fi
    tail -n +2 $large_csv >> $huge_csv
  done
