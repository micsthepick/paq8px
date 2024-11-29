FROM aflplusplus/aflplusplus:dev AS fuzzpaq

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    gettext autopoint tmux parallel \
    curl

WORKDIR /AFLplusplus
RUN curl -O -L https://github.com/Kitware/CMake/releases/download/v3.31.1/cmake-3.31.1-linux-x86_64.tar.gz \
    && tar -zxvf cmake-3.31.1-linux-x86_64.tar.gz \
    && mv cmake-3.31.1-linux-x86_64 /opt/cmake \
    && ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake \
    && rm cmake-3.31.1-linux-x86_64.tar.gz

WORKDIR /AFLplusplus/zlib
RUN curl -O https://zlib.net/zlib-1.3.1.tar.gz && \
    tar -xvzf zlib-1.3.1.tar.gz && \
    rm zlib-1.3.1.tar.gz

# Set the compiler environment
WORKDIR /AFLplusplus/zlib/zlib-1.3.1

# Configure and compile zlib
RUN ./configure --prefix=/usr/local/zlib && \
    make && \
    make install

COPY build /AFLplusplus/paq8px/build
COPY file /AFLplusplus/paq8px/file

RUN rm /AFLplusplus/paq8px/file/FileDisk.cpp
COPY stub/DummyFileDisk.cpp /AFLplusplus/paq8px/file/FileDisk.cpp

COPY filter /AFLplusplus/paq8px/filter
COPY lstm /AFLplusplus/paq8px/lstm
COPY model /AFLplusplus/paq8px/model
COPY text /AFLplusplus/paq8px/text
COPY zlib /AFLplusplus/paq8px/zlib
COPY *.cpp /AFLplusplus/paq8px/
COPY *.hpp /AFLplusplus/paq8px/
COPY DOC /AFLplusplus/paq8px/
COPY packages.config /AFLplusplus/paq8px/
COPY CMakeLists.txt /AFLplusplus/paq8px/

WORKDIR /AFLplusplus/paq8px/build

RUN mv /AFLplusplus/paq8px/paq8px.cpp /AFLplusplus/paq8px/paq8px.cpp.bak
RUN sed -r 's/int main\(/static int old_main\(/g' /AFLplusplus/paq8px/paq8px.cpp.bak > /AFLplusplus/paq8px/paq8px-mainless.cpp
ADD paq8px-persistent.cpp /AFLplusplus/paq8px/paq8px-persistent.cpp
RUN cat /AFLplusplus/paq8px/paq8px-mainless.cpp /AFLplusplus/paq8px/paq8px-persistent.cpp > /AFLplusplus/paq8px/paq8px.cpp

ENV CXX=/usr/local/bin/afl-clang-lto++
ENV CC=/usr/local/bin/afl-clang-lto

RUN cmake \
    -DCMAKE_CXX_COMPILER_WORKS=true \
    .. --trace

RUN AFL_USE_ASAN=1 AFL_USE_UBSAN=1 AFL_USE_CFISAN=1 make VERBOSE=1 -j 12

RUN mv paq8px ../paq8px-san
RUN make clean

RUN export AFL_LLVM_LAF_ALL=1

RUN rm -rf CMakeCache.txt CMakeFiles
RUN cmake \
    -DCMAKE_CXX_COMPILER_WORKS=true \
    -DCMAKE_LINKER=/usr/local/bin/afl-ld-lto \
    .. --trace

RUN make VERBOSE=1 -j 12

RUN mv paq8px ../paq8px-laf
RUN make clean

RUN unset AFL_LLVM_LAF_ALL


RUN export AFL_LLVM_CMPLOG=1

RUN rm -rf CMakeCache.txt CMakeFiles
RUN cmake \
    -DCMAKE_CXX_COMPILER_WORKS=true \
    .. --trace

RUN make VERBOSE=1 -j 12

RUN mv paq8px ../paq8px-cmplog
RUN make clean

RUN unset AFL_LLVM_CMPLOG

RUN rm -rf CMakeCache.txt CMakeFiles
RUN cmake \
    -DCMAKE_CXX_COMPILER_WORKS=true \
    -DCMAKE_LINKER=/usr/local/bin/afl-ld-lto \
    .. --trace

RUN make VERBOSE=1 -j 12

RUN mv paq8px ../paq8px-afl
RUN make clean

ADD runarg.sh /AFLplusplus/paq8px/runarg.sh
ADD run6tmux.sh /AFLplusplus/paq8px/run6tmux.sh

WORKDIR /AFLplusplus/paq8px