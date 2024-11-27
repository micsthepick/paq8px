FROM aflplusplus/aflplusplus:dev AS fuzzpaq

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    gettext autopoint tmux parallel

RUN git clone https://github.com/micsthepick/paq8px.git

WORKDIR /AFLplusplus/paq8px/build

RUN mv /AFLplusplus/paq8px/paq8px.cpp /AFLplusplus/paq8px/paq8px.cpp.bak
RUN sed -r 's/int main\(/static int old_main\(/g' /AFLplusplus/paq8px/paq8px.cpp.bak > /AFLplusplus/paq8px/paq8px-mainless.cpp
ADD paq8px-persistent.cpp /AFLplusplus/paq8px/paq8x-persistent.cpp
RUN cat /AFLplusplus/paq8px/paq8px-mainless.cpp /AFLplusplus/paq8px/paq8x-persistent.cpp > /AFLplusplus/paq8px/paq8px.cpp

ENV CC=afl-clang-fast
ENV CXX=afl-clang-fast

RUN cmake \
    -DCMAKE_C_COMPILER=afl-clang-fast \
    -DCMAKE_CXX_COMPILER=afl-clang-fast \
    -DCMAKE_AR=llvm-ar \
    -DCMAKE_RANLIB=llvm-ranlib \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    ..
RUN AFL_USE_ASAN=1 AFL_USE_UBSAN=1 AFL_USE_CFISAN=1 make

RUN mv paq8px ../paq8px-san
RUN make clean

RUN export AFL_LLVM_LAF_ALL=1

RUN make

RUN mv paq8px ../paq8px-san
RUN make clean

RUN unset AFL_LLVM_LAF_ALL


RUN export AFL_LLVM_CMPLOG=1

RUN make

RUN mv paq8px ../paq8px-cmplog
RUN make clean

RUN unset AFL_LLVM_CMPLOG


RUN make

RUN mv paq8px ../paq8px-afl
RUN make clean

ADD runarg.sh /AFLplusplus/paq8px/runarg.sh
ADD run12tmux.sh /AFLplusplus/paq8px/run12tmux.sh
