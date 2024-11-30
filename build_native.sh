#!/bin/bash
set -e

rm -rf aflbuild

mkdir -p aflbuild

pushd aflbuild

# mkdir -p zlib

# pushd zlib

# curl -O https://zlib.net/zlib-1.3.1.tar.gz && \
#     tar -xvzf zlib-1.3.1.tar.gz && \
#     rm zlib-1.3.1.tar.gz

# popd

export ZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so
export ZLIB_INCLUDE_DIR=/usr/include
export CXX=/usr/local/bin/afl-clang-lto++
export CC=/usr/local/bin/afl-clang-lto

cp -r ../build ../file .
rm ./file/FileDisk.cpp
cp ../stub/DummyFileDisk.cpp ./file/FileDisk.cpp

cp -r ../filter ../lstm ../model ../text ../zlib ../*.cpp ../*.hpp ../DOC ../packages.config ../CMakeLists.txt .

mv ./paq8px.cpp ./paq8px.cpp.bak
sed -r 's/int main\(/static int old_main\(/g' ./paq8px.cpp.bak > ./paq8px-mainless.cpp
cat ./paq8px-mainless.cpp ./paq8px-persistent.cpp > ./paq8px.cpp

pushd build

export AFL_USE_ASAN=1 AFL_USE_UBSAN=1 AFL_USE_CFISAN=1

cmake \
    -DCMAKE_CXX_COMPILER_WORKS=true \
    -DZLIB_LIBRARY=$ZLIB_LIBRARY \
    -DZLIB_INCLUDE_DIR=$ZLIB_INCLUDE_DIR \
    -DCMAKE_BUILD_TYPE=Debug .. --trace

make -j 12 VERBOSE=1

mv paq8px ../paq8px-san
make clean

unset AFL_USE_ASAN AFL_USE_UBSAN AFL_USE_CFISAN

export AFL_LLVM_LAF_ALL=1

rm -rf CMakeCache.txt CMakeFiles
cmake \
    -DCMAKE_CXX_COMPILER_WORKS=true \
    -DZLIB_LIBRARY=$ZLIB_LIBRARY \
    -DZLIB_INCLUDE_DIR=$ZLIB_INCLUDE_DIR \
    -DCMAKE_BUILD_TYPE=Debug ..

make -j 12

mv paq8px ../paq8px-laf
make clean

unset AFL_LLVM_LAF_ALL


export AFL_LLVM_CMPLOG=1

rm -rf CMakeCache.txt CMakeFiles
cmake \
    -DCMAKE_C_COMPILER_WORKS=true \
    -DCMAKE_CXX_COMPILER_WORKS=true \
    -DZLIB_LIBRARY=$ZLIB_LIBRARY \
    -DZLIB_INCLUDE_DIR=$ZLIB_INCLUDE_DIR \
    -DCMAKE_BUILD_TYPE=Debug ..

make -j 12

mv paq8px ../paq8px-cmplog
make clean

unset AFL_LLVM_CMPLOG

rm -rf CMakeCache.txt CMakeFiles
cmake \
    -DCMAKE_CXX_COMPILER_WORKS=true \
    -DZLIB_LIBRARY=$ZLIB_LIBRARY \
    -DZLIB_INCLUDE_DIR=$ZLIB_INCLUDE_DIR \
    -DCMAKE_BUILD_TYPE=Debug ..

make -j 12

mv paq8px ../paq8px-afl
make clean

popd

cp ../runarg.sh .
cp ../run6tmux.sh .

popd