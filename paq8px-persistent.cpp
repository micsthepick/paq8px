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

int main() {
    #ifdef __AFL_HAVE_MANUAL_CONTROL
    __AFL_INIT();
    #endif

    unsigned char *buf = __AFL_FUZZ_TESTCASE_BUF;

    FMode fMode = FMode::FDECOMPRESS;
    Mode mode = Mode::DECOMPRESS;
    const bool doEncoding = true;

    int simdIset = simdDetect();
    SIMDType simdIChose;

    if (simdIset == 11) {
        simdIChose = SIMDType::SIMD_NEON;
    } else if (simdIset >= 10) {
        simdIChose = SIMDType::SIMD_AVX512;
    } else if (simdIset >= 9) {
        simdIChose = SIMDType::SIMD_AVX2;
    } else if( simdIset >= 3 ) {
        simdIChose = SIMDType::SIMD_SSE2;
    } else {
        simdIChose = SIMDType::SIMD_NONE;
    }
    while (__AFL_LOOP(10000)) {
        uint64_t len = __AFL_FUZZ_TESTCASE_LEN;
        if (len < 8) continue;

        Shared shared;
        shared.reset();
        shared.init((buf[0] % 12) + 1);
        shared.options = buf[1];
        shared.chosenSimd  = simdIChose;

        TransformOptions transformOptions(&shared);

        FileTmp file;

        FileDisk out;

        file.blockWrite(&buf[2], len - 2);

        Encoder en(&shared, doEncoding, mode, &file);

        uint64_t blockLen = Block::DecodeBlockHeader(&en);

        decompressRecursive(&out, len - 2, en, fMode, &transformOptions);
    }

    return 0;
}

