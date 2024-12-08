#!/bin/bash
set -e

rm -rf aflbuild

mkdir -p aflbuild

pushd aflbuild

export ZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so
export ZLIB_INCLUDE_DIR=/usr/include
if command -v ccache >/dev/null 2>&1; then
    export CXX="ccache afl-clang-lto++"
    export CC="ccache afl-clang-lto"
elif command -v afl-clang-lto >/dev/null 2>&1; then
    export CXX="afl-clang-lto++"
    export CC="afl-clang-lto"
else
    echo USING CLANG FAST!!
    sleep 1
    export CXX="afl-clang-fast++"
    export CC="afl-clang-fast"
fi


cp -r ../build ../file .
rm ./file/FileDisk.cpp
cp ../stub/DummyFileDisk.cpp ./file/FileDisk.cpp

cp -r ../filter ../lstm ../model ../text ../zlib ../*.cpp ../*.hpp ../DOC ../packages.config ../CMakeLists.txt .

mv ./paq8px.cpp ./paq8px.cpp.bak
sed -r 's/int main\(/static int old_main\(/g' ./paq8px.cpp.bak > ./paq8px-mainless.cpp
cat ./paq8px-mainless.cpp ./paq8px-persistent.cpp > ./paq8px.cpp

pushd build


export AFL_USE_ASAN=1 AFL_USE_UBSAN=1 AFL_USE_CFISAN=1 CCACHE_NAMESPACE="san"
cmake \
    -DCMAKE_CXX_COMPILER_WORKS=true \
    -DCMAKE_C_COMPILER_WORKS=true \
    -DZLIB_LIBRARY=$ZLIB_LIBRARY \
    -DZLIB_INCLUDE_DIR=$ZLIB_INCLUDE_DIR \
    -DCMAKE_BUILD_TYPE=Debug ..
CCACHE_NAMESPACE="san" make -j 12

mv paq8px ../paq8px-san

make clean
rm -rf CMakeCache.txt CMakeFiles
unset AFL_USE_ASAN AFL_USE_UBSAN AFL_USE_CFISAN


export AFL_LLVM_LAF_ALL=1 CCACHE_NAMESPACE="laf"
cmake \
    -DCMAKE_CXX_COMPILER_WORKS=true \
    -DCMAKE_C_COMPILER_WORKS=true \
    -DZLIB_LIBRARY=$ZLIB_LIBRARY \
    -DZLIB_INCLUDE_DIR=$ZLIB_INCLUDE_DIR \
    -DCMAKE_BUILD_TYPE=Debug ..
make -j 12

mv paq8px ../paq8px-laf

make clean
rm -rf CMakeCache.txt CMakeFiles
unset AFL_LLVM_LAF_ALL


export AFL_LLVM_CMPLOG=1 CCACHE_NAMESPACE="cmplog"
cmake \
    -DCMAKE_CXX_COMPILER_WORKS=true \
    -DCMAKE_C_COMPILER_WORKS=true \
    -DZLIB_LIBRARY=$ZLIB_LIBRARY \
    -DZLIB_INCLUDE_DIR=$ZLIB_INCLUDE_DIR \
    -DCMAKE_BUILD_TYPE=Debug ..
make -j 12

mv paq8px ../paq8px-cmplog
make clean
rm -rf CMakeCache.txt CMakeFiles


export CCACHE_NAMESPACE="afl"
cmake \
    -DCMAKE_CXX_COMPILER_WORKS=true \
    -DCMAKE_C_COMPILER_WORKS=true \
    -DZLIB_LIBRARY=$ZLIB_LIBRARY \
    -DZLIB_INCLUDE_DIR=$ZLIB_INCLUDE_DIR \
    -DCMAKE_BUILD_TYPE=Debug ..
make -j 12

mv paq8px ../paq8px-afl
make clean
rm -rf CMakeCache.txt CMakeFiles

popd

cp ../runarg.sh .
cp ../run6tmux.sh .

popd
