__AFL_FUZZ_INIT();


#pragma clang optimize off
#pragma GCC optimize("O0")

int main() {
    #ifdef __AFL_HAVE_MANUAL_CONTROL
    __AFL_INIT();
    #endif

    unsigned char *buf = __AFL_FUZZ_TESTCASE_BUF;

    while (__AFL_LOOP(10000)) {

        int len = __AFL_FUZZ_TESTCASE_LEN;  // don't use the macro directly in a
                                            // call!

        if (len < 8) continue;  // check for a required/useful minimum input length

        //FMode fMode = whattodo == DoExtract ? FMode::FDECOMPRESS : FMode::FCOMPARE;
        FMode fMode = FMode::FDECOMPRESS;

        Shared shared;

        FileTmp file;

        file.blockWrite(__AFL_FUZZ_TESTCASE_BUF, len);

        Encoder en(&file, doEncoding, mode, &archive);

        TransformOptions transformOptions(shared);

        //decompressFile(&shared, fName, fMode, en);
        // decompressRecursive(&f, fileSize, en, fMode, &transformOptions);
        decompressRecursive(&file, len, en, fMode, &transformOptions);

        /* Reset state. e.g. libtarget_free(tmp) */
        file.forgetContentInRam();
    }

    return 0;
}

