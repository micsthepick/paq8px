rm -rf noaflbuild

mkdir -p noaflbuild

pushd noaflbuild

export ZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so
export ZLIB_INCLUDE_DIR=/usr/include

cp -r ../build ../file .
rm ./file/FileDisk.cpp
cp ../stub/DummyFileDisk.cpp ./file/FileDisk.cpp

cp -r ../filter ../lstm ../model ../text ../zlib ../*.cpp ../*.hpp ../DOC ../packages.config ../CMakeLists.txt .

mv ./paq8px.cpp ./paq8px.cpp.bak
sed -r 's/int main\(/static int old_main\(/g' ./paq8px.cpp.bak > ./paq8px-mainless.cpp
cat ./paq8px-mainless.cpp ./paq8px-persistent.cpp > ./paq8px.cpp

pushd build

cmake \
    -DZLIB_LIBRARY=$ZLIB_LIBRARY \
    -DZLIB_INCLUDE_DIR=$ZLIB_INCLUDE_DIR \
    -DCMAKE_BUILD_TYPE=Debug ..

make -j 12
