__AFL_FUZZ_INIT();


#pragma clang optimize off
#pragma GCC optimize("O0")

int main() {
    #ifdef __AFL_HAVE_MANUAL_CONTROL
    __AFL_INIT();
    #endif

    unsigned char *buf = __AFL_FUZZ_TESTCASE_BUF;

    FMode fMode = FMode::FDECOMPRESS;
    Mode mode = Mode::DECOMPRESS;
    const bool doEncoding = true;

    Shared shared;
    
    FileTmp file;
    
    TransformOptions transformOptions(&shared);

    while (__AFL_LOOP(10000)) {

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

