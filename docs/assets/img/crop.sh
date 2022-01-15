#!/usr/bin/env bash

idx=0
for i in *.png
do
  convert -crop 1890x1000+1930+30 ${i} image_${idx}.png
  idx=$(( idx + 1 ))
done

