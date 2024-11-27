export AFL_AUTORESUME=1 AFL_CMPLOG_ONLY_NEW=1 AFL_IMPORT_FIRST=1 AFL_TESTCACHE_SIZE=100MB
[ "$M" == "a" ] && mkdir -p /ramdisk/tmp00 && AFL_TMPDIR=/ramdisk/tmp00 AFL_FINAL_SYNC=1 afl-fuzz -i /outs/seeds-paq8px -M sh0 -o out-paq8px                         -- ./paq8px-san
[ "$M" == "b" ] && mkdir -p /ramdisk/tmp01 && AFL_TMPDIR=/ramdisk/tmp01                  afl-fuzz -i /outs/seeds-paq8px -S sh1 -o out-paq8px -c ./paq8px-cmplog -l 2AT -- ./paq8px-afl
[ "$M" == "c" ] && mkdir -p /ramdisk/tmp02 && AFL_TMPDIR=/ramdisk/tmp02                  afl-fuzz -i /outs/seeds-paq8px -S sh2 -o out-paq8px -c ./paq8px-cmplog        -- ./paq8px-afl
[ "$M" == "d" ] && mkdir -p /ramdisk/tmp03 && AFL_TMPDIR=/ramdisk/tmp03                  afl-fuzz -i /outs/seeds-paq8px -S sh3 -o out-paq8px                         -- ./paq8px-laf
[ "$M" == "e" ] && mkdir -p /ramdisk/tmp04 && AFL_TMPDIR=/ramdisk/tmp04                  afl-fuzz -i /outs/seeds-paq8px -S sh4 -o out-paq8px                         -- ./paq8px-laf
[ "$M" == "f" ] && mkdir -p /ramdisk/tmp05 && AFL_TMPDIR=/ramdisk/tmp05                  afl-fuzz -i /outs/seeds-paq8px -S sh5 -o out-paq8px                         -- ./paq8px-laf
[ "$M" == "g" ] && mkdir -p /ramdisk/tmp06 && AFL_TMPDIR=/ramdisk/tmp06 AFL_FINAL_SYNC=1 afl-fuzz -i /outs/seeds-paq8px -M fn0 -o out-paq8px                         -- ./paq8px-san
[ "$M" == "h" ] && mkdir -p /ramdisk/tmp07 && AFL_TMPDIR=/ramdisk/tmp07                  afl-fuzz -i /outs/seeds-paq8px -S fn1 -o out-paq8px -c ./paq8px-cmplog -l 2AT -- ./paq8px-afl
[ "$M" == "i" ] && mkdir -p /ramdisk/tmp08 && AFL_TMPDIR=/ramdisk/tmp08                  afl-fuzz -i /outs/seeds-paq8px -S fn2 -o out-paq8px -c ./paq8px-cmplog        -- ./paq8px-afl
[ "$M" == "j" ] && mkdir -p /ramdisk/tmp09 && AFL_TMPDIR=/ramdisk/tmp09                  afl-fuzz -i /outs/seeds-paq8px -S fn3 -o out-paq8px                         -- ./paq8px-laf
[ "$M" == "k" ] && mkdir -p /ramdisk/tmp10 && AFL_TMPDIR=/ramdisk/tmp10                  afl-fuzz -i /outs/seeds-paq8px -S fn4 -o out-paq8px                         -- ./paq8px-laf
[ "$M" == "l" ] && mkdir -p /ramdisk/tmp11 && AFL_TMPDIR=/ramdisk/tmp11                  afl-fuzz -i /outs/seeds-paq8px -S fn5 -o out-paq8px                         -- ./paq8px-laf
