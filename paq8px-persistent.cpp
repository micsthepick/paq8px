#ifndef __AFL_FUZZ_TESTCASE_LEN
  ssize_t fuzz_len;
  #define __AFL_FUZZ_TESTCASE_LEN fuzz_len
  unsigned char fuzz_buf[1024000];
  #define __AFL_FUZZ_TESTCASE_BUF fuzz_buf
  #define __AFL_FUZZ_INIT() void sync(void);
  #define __AFL_LOOP(x) ((fuzz_len = read(0, fuzz_buf, sizeof(fuzz_buf))) > 0 ? 1 : 0)
  #define __AFL_INIT() sync()
#endif

__AFL_FUZZ_INIT();


#pragma clang optimize off
#pragma GCC optimize("O0")

int main() {
    #ifdef __AFL_HAVE_MANUAL_CONTROL
    __AFL_INIT();
    #endif

    unsigned char *buf = __AFL_FUZZ_TESTCASE_BUF;

    while (__AFL_LOOP(10000)) {

        FMode fMode = FMode::FDECOMPRESS;
        Mode mode = Mode::DECOMPRESS;
        const bool doEncoding = true;

        Shared shared;
        
        TransformOptions transformOptions(&shared);

        FileTmp file;

        int len = __AFL_FUZZ_TESTCASE_LEN;  // don't use the macro directly in a
                                            // call!

        if (len < 8) continue;  // check for a required/useful minimum input length

        file.blockWrite(__AFL_FUZZ_TESTCASE_BUF, len);

        Encoder en(&shared, doEncoding, mode, &file);
        len = Block::DecodeBlockHeader(&en);

        decompressRecursive(&file, len, en, fMode, &transformOptions);

        /* Reset state. e.g. libtarget_free(tmp) */
        file.close();
    }

    return 0;
}

