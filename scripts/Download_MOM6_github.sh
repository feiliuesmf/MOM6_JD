#!/bin/bash

git_path=https://github.com/jiandewang
PWD=`pwd`
target_dir=$PWD/MOM6-test

mkdir -p $target_dir/src
cd $target_dir/src

for component in MOM6 FMS SIS2 coupler land_null icebergs mkmf atmos_null ice_ocean_extras 
do
echo "cloning $component ..."
git clone --recursive ${git_path}/${component}.git
done

