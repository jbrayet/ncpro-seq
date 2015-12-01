#!/bin/bash

for i in $(ls *.gff)
do
sort -k 1,1 -k 4,4n ${i} > ${i}.tmp
rm -f ${i}
mv ${i}.tmp ${i}
done
