#! /bin/bash
COMP=MOM6
COMP_SRCDIR=/scratch4/NCEPDEV/ocean/noscrub/Fei.Liu/MOM6_JD
MACHINE_ID=theia
COMP_BINDIR=INSTALL

source /etc/profile
module use /scratch4/NCEPDEV/nems/save/Gerhard.Theurich/Modulefiles
module load intel impi/5.1.1.109 netcdf esmf/7.1.0bs07-g-IMPI5.1.1.109

echo "Building $COMP..."
cd $COMP_SRCDIR
cp scripts/${MACHINE_ID}/compile.sh .
./compile.sh --platform $MACHINE_ID
cd ../MOM_CAP
echo "make -f makefile.nuopc VERSION=mom6 USER_CFLAGS=-DMOM6_CAP NEMSMOMDIR=$COMP_SRCDIR/exec/$MACHINE_ID INSTALLDIR=$COMP_BINDIR install"
make -f makefile.nuopc VERSION=mom6 USER_CFLAGS=-DMOM6_CAP NEMSMOMDIR=$COMP_SRCDIR/exec/$MACHINE_ID INSTALLDIR=$COMP_BINDIR install
if ([ ! -d $COMP_BINDIR ]); then
  echo "...failed building $COMP."
else
  echo "...done building $COMP."
fi

