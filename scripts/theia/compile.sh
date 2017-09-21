#!/bin/csh -f

# download MOM6 code
# git clone --recursive https://github.com/NOAA-GFDL/MOM6-examples.git MOM6-examples
#
set argv=(`getopt -u -o h -l platform:  --  $*`)
while ("$argv[1]" != "--")
    switch ($argv[1])
        case --platform:
                set platform = $argv[2]; shift argv; breaksw
    endsw
    shift argv
end
shift argv

set BASEDIR=`pwd`
set MACHINE_ID=${platform}  
set COMPILE_OPTION=${MACHINE_ID}-intel.mk

set compile_FMS=1
set compile_ocean_only=1
set compile_MOM6_SIS2=1
###############################
if ( ${compile_FMS} == 1 ) then 
 echo "compile FMS library ..."
 cd $BASEDIR
 mkdir -p build/intel/shared/repro
 cd build/intel/shared/repro
 if ( -f path_names ) then
  rm -f path_names
 endif  

 echo "generating file_paths ..."
 ../../../../src/mkmf/bin/list_paths ../../../../src/FMS

 echo "generating makefile ..."
 ../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/${COMPILE_OPTION} -p libfms.a -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names

 echo "compiling FMS library..."
 make NETCDF=4 REPRO=1 libfms.a -j
 set result=$?
 if ( $result != 0 ) then
  echo "compiling FMS failed"
  exit 8
 else
  echo "compiling FMS library successful"
 endif 

 cp libfms.a lib_FMS.a

endif 

echo "====================================================="

###############################################
 if ( ${compile_ocean_only} == 1 ) then
 echo "compile ocean only ..."
 cd $BASEDIR
 mkdir -p build/intel/ocean_only/repro
 cd build/intel/ocean_only/repro
 if ( -f path_names ) then
  rm -f path_names
 endif 

 echo "generating file_paths ..."
 ../../../../src/mkmf/bin/list_paths ./ ../../../../src/MOM6/{config_src/dynamic,pkg/CVMix-src/src/shared,config_src/solo_driver,src/{*,*/*}}

 echo "generating makefile ..."
 ../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/${COMPILE_OPTION} -o '-I../../shared/repro' -p 'MOM6 -L../../shared/repro  -lfms' -c "-Duse_libMPI -Duse_netcdf -DSPMD" path_names

 echo "compiling MOM6 ocean only ..."
 make NETCDF=4 REPRO=1 MOM6 -j
 set result=$?
 if ( $result != 0 ) then
  echo "compiling Ocean_only exectuable failed"
  exit 8
 else
  echo "compiling Ocean_only exectuable successful"
 endif

# echo "generating libocean.a"
# ar rv libocean.a *o

endif 
echo "=================================================="

#######################################
 if ( ${compile_MOM6_SIS2} == 1 ) then
 echo "compiling MOM6-SIS2 ..."
 cd $BASEDIR
 mkdir -p build/intel/ice_ocean_SIS2/repro
 cd build/intel/ice_ocean_SIS2/repro
 if ( -f path_names ) then 
  rm -f path_names
 endif 

 echo "generating file_paths ..."
 ../../../../src/mkmf/bin/list_paths ./ ../../../../src/MOM6/config_src/{dynamic,coupled_driver} ../../../../src/MOM6/src/{*,*/*}/ ../../../../src/{atmos_null,coupler,land_null,ice_ocean_extras,icebergs,SIS2,FMS/coupler,FMS/include}

 echo "generating makefile ..."
 ../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/${COMPILE_OPTION} -o '-I../../shared/repro' -p MOM6 -l '-L../../shared/repro  -lfms' -c '-Duse_libMPI -Duse_netcdf -DSPMD -DUSE_LOG_DIAG_FIELD_INFO -Duse_AM3_physics' path_names

 echo "compiling MOM6 ocean only ..."
 make NETCDF=4 REPRO=1 MOM6 -j
 set result=$?
 if ( $result != 0 ) then
  echo "compiling MOM6-SIS2 exectuable/lib failed"
  exit 8
 else
  echo "compiling MOM6-SIS2 exectuable/lib successful"
 endif 

 echo "generating lib_ocean.a"
 rm repro
 ar rv lib_ocean.a *o

 echo "compiling MOM6-SIS2 done"

 # Install library and module files for NEMSAppbuilder
 cd $BASEDIR
 mkdir -p exec/${MACHINE_ID}/
 # link to the library and module files
 rm -rf exec/${MACHINE_ID}/lib_FMS exec/${MACHINE_ID}/lib_ocean
 ln -s ${BASEDIR}/build/intel/shared/repro exec/${MACHINE_ID}/lib_FMS
 ln -s ${BASEDIR}/build/intel/ice_ocean_SIS2/repro exec/${MACHINE_ID}/lib_ocean

endif 
