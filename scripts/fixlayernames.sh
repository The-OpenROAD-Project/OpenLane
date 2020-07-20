#!/bin/sh
cp $1 ${1}_old
sed -i -e "s/LI1/li1/g" -e "s/MET1/met1/g" -e "s/MET2/met2/g" -e "s/MET3/met3/g" -e "s/MET4/met4/g" -e "s/MET5/met5/g" $1
