export AFL_AUTORESUME=1 AFL_CMPLOG_ONLY_NEW=1 AFL_IMPORT_FIRST=1 AFL_TESTCACHE_SIZE=100MB
[ "$M" == "a" ] && mkdir -p /mnt/ramdisk/tmp00 && AFL_TMPDIR=/mnt/ramdisk/tmp00 AFL_FINAL_SYNC=1 afl-fuzz -i $1/seeds-paq8px -M sh0 -o $1/out/out-paq8px                           -t 20000 -- ./paq8px-san
[ "$M" == "b" ] && mkdir -p /mnt/ramdisk/tmp01 && AFL_TMPDIR=/mnt/ramdisk/tmp01                  afl-fuzz -i $1/seeds-paq8px -S sh1 -o $1/out/out-paq8px -c ./paq8px-cmplog -l 2AT -t 20000 -- ./paq8px-afl
[ "$M" == "c" ] && mkdir -p /mnt/ramdisk/tmp02 && AFL_TMPDIR=/mnt/ramdisk/tmp02                  afl-fuzz -i $1/seeds-paq8px -S sh2 -o $1/out/out-paq8px -c ./paq8px-cmplog        -t 20000 -- ./paq8px-afl
[ "$M" == "d" ] && mkdir -p /mnt/ramdisk/tmp03 && AFL_TMPDIR=/mnt/ramdisk/tmp03                  afl-fuzz -i $1/seeds-paq8px -S sh3 -o $1/out/out-paq8px                           -t 20000 -- ./paq8px-laf
[ "$M" == "e" ] && mkdir -p /mnt/ramdisk/tmp04 && AFL_TMPDIR=/mnt/ramdisk/tmp04                  afl-fuzz -i $1/seeds-paq8px -S sh4 -o $1/out/out-paq8px                           -t 20000 -- ./paq8px-laf
[ "$M" == "f" ] && mkdir -p /mnt/ramdisk/tmp05 && AFL_TMPDIR=/mnt/ramdisk/tmp05                  afl-fuzz -i $1/seeds-paq8px -S sh5 -o $1/out/out-paq8px                           -t 20000 -- ./paq8px-laf
