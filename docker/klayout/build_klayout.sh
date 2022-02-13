#!/bin/bash
set -e
set -x

bininstdir="./tmp/bin" 
builddir="./tmp/build" 

# destination folders
bindir="/build/bin"
libdir="/build/lib/klayout"

distpackdir="/build/lib/python3/dist-packages"
pylibdir="$distpackdir/klayout"

# clean bin directory
rm -rf $bininstdir

# do the actual build
./build.sh -j$(nproc) \
           -bin $bininstdir \
           -build $builddir \
           -rpath $libdir 

echo "Copying files .."

mkdir -p ${libdir}/db_plugins
mkdir -p ${libdir}/lay_plugins
mkdir -p ${pylibdir}
mkdir -p ${bindir}

cp -pd $bininstdir/strm* ${bindir}
cp -pd $bininstdir/klayout ${bindir}
cp -pd $bininstdir/lib*so* ${libdir}
cp -pd $bininstdir/db_plugins/lib*so* ${libdir}/db_plugins
cp -pd $bininstdir/lay_plugins/lib*so* ${libdir}/lay_plugins
cp -pd $bininstdir/pymod/klayout/*so ${pylibdir}
cp -pd $bininstdir/pymod/klayout/*py ${pylibdir}
for d in db tl rdb lib; do
  mkdir -p ${pylibdir}/$d
  cp -pd $bininstdir/pymod/klayout/$d/*py ${pylibdir}/$d
done

echo "Stripping..."
strip ${bindir}/*
strip ${pylibdir}/*.so
strip ${libdir}/db_plugins/*.so*
strip ${libdir}/lay_plugins/*.so*