#ifndef __AFL_FUZZ_TESTCASE_LEN
    ssize_t fuzz_len;
    #define __AFL_FUZZ_TESTCASE_LEN fuzz_len
    unsigned char fuzz_buf[1024000];
    #define __AFL_FUZZ_TESTCASE_BUF fuzz_buf
    #define __AFL_FUZZ_INIT() void sync(void);
    #define __AFL_LOOP(x) ((fuzz_len = read(0, fuzz_buf, sizeof(fuzz_buf))) > 0 ? 1 : 0)
    #define __AFL_INIT() sync()
    #define __AFL_COVERAGE() void
    #define __AFL_COVERAGE_ON() void
    #define __AFL_COVERAGE_OFF() void
#endif

#include "filter/Filters.hpp"

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

    while (__AFL_LOOP(10000)) {
        uint64_t len = __AFL_FUZZ_TESTCASE_LEN;
        if (len < 8) continue;

        Shared shared;
        shared.reset();
        shared.chosenSimd = SIMDType::SIMD_AVX2;
        TransformOptions transformOptions(&shared);

        FileTmp file;

        FileDisk out;


        file.blockWrite(__AFL_FUZZ_TESTCASE_BUF, len);

        Encoder en(&shared, doEncoding, mode, &file);

        uint64_t blockLen = Block::DecodeBlockHeader(&en);

        decompressRecursive(&out, len, en, fMode, &transformOptions);


        /* Reset state. e.g. libtarget_free(tmp) */
    }

    return 0;
}

