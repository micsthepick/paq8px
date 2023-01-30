#pragma once

#if defined(__i386__) || defined(__x86_64__) || defined(_M_X64)
#include <immintrin.h>
#elif defined(__ARM_FEATURE_SIMD32) || defined(__ARM_NEON)
#include <arm_neon.h>
#endif



