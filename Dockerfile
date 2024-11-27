FROM aflplusplus/aflplusplus:dev as fuzzpaq

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    gettext autopoint tmux parallel

RUN git clone https://github.com/micsthepick/paq8px.git
WORKDIR /AFLplusplus/paq8px

RUN cmake -DCMAKE_C_COMPILER=afl-cc -DCMAKE_CXX_COMPILER=afl-c++ -DAR=llvm-ar -DRANLIB=llvm-ranlib -DAS=llvm-as ..
RUN AFL_USE_ASAN=1 AFL_USE_UBSAN=1 AFL_USE_CFISAN=1 make

RUN mv paq8px paq8px-san
RUN make clean

RUN export AFL_LLVM_LAF_ALL=1 

RUN make
RUN make clean

RUN unset AFL_LLVM_LAF_ALL


RUN export AFL_LLVM_CMPLOG=1

RUN make

RUN mv paq8px paq8px-cmplog
RUN make clean

RUN unset AFL_LLVM_CMPLOG


RUN make

RUN mv paq8px paq8px-afl
RUN make clean

ADD runarg.sh /AFLplusplus/util-linux/runarg.sh
ADD run12tmux.sh /AFLplusplus/util-linux/run12tmux.sh
