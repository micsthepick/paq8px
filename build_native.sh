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

export CXX_FLAGS="-stdlib=libc++ -flto=full"
export C_FLAGS="-flto=full"

cp -r ../build ../file .
rm ./file/FileDisk.cpp
cp ../stub/DummyFileDisk.cpp ./file/FileDisk.cpp

cp -r ../filter ../lstm ../model ../text ../zlib ../*.cpp ../*.hpp ../DOC ../packages.config ../CMakeLists.txt .

mv ./paq8px.cpp ./paq8px.cpp.bak
sed -r 's/int main\(/static int old_main\(/g' ./paq8px.cpp.bak > ./paq8px-mainless.cpp
cat ./paq8px-mainless.cpp ./paq8px-persistent.cpp > ./paq8px.cpp

pushd build

cmake \
    -DCMAKE_C_COMPILER=/usr/local/bin/afl-clang-lto \
    -DCMAKE_CXX_COMPILER=/usr/local/bin/afl-clang-lto \
    -DCMAKE_LINKER=/usr/local/bin/afl-clang-lto \
    -DCMAKE_C_FLAGS_INIT="$C_FLAGS" \
    -DCMAKE_CXX_FLAGS_INIT="$CXX_FLAGS" \
    ..

AFL_USE_ASAN=1 AFL_USE_UBSAN=1 AFL_USE_CFISAN=1 make -j 12

mv paq8px ../paq8px-san
make clean

export AFL_LLVM_LAF_ALL=1

rm -rf CMakeCache.txt CMakeFiles
cmake \
    -DCMAKE_C_COMPILER=/usr/local/bin/afl-clang-lto \
    -DCMAKE_CXX_COMPILER=/usr/local/bin/afl-clang-lto \
    -DCMAKE_LINKER=/usr/local/bin/afl-ld-lto \
    ..

make -j 12

mv paq8px ../paq8px-laf
make clean

unset AFL_LLVM_LAF_ALL


export AFL_LLVM_CMPLOG=1

rm -rf CMakeCache.txt CMakeFiles
cmake \
    -DCMAKE_C_COMPILER=/usr/local/bin/afl-clang-lto \
    -DCMAKE_CXX_COMPILER=/usr/local/bin/afl-clang-lto \
    -DCMAKE_LINKER=/usr/local/bin/afl-clang-lto \
    ..

make -j 12

mv paq8px ../paq8px-cmplog
make clean

unset AFL_LLVM_CMPLOG

rm -rf CMakeCache.txt CMakeFiles
cmake \
    -DCMAKE_C_COMPILER=/usr/local/bin/afl-clang-lto \
    -DCMAKE_CXX_COMPILER=/usr/local/bin/afl-clang-lto \
    -DCMAKE_LINKER=/usr/local/bin/afl-ld-lto \
    ..

make -j 12

mv paq8px ../paq8px-afl
make clean

popd

cp ../runarg.sh .
cp ../run6tmux.sh .

popd