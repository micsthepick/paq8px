#pragma once

#include "UpdateBroadcaster.hpp"
#include "BitCount.hpp"
#include "Ilog.hpp"
#include "Mixer.hpp"
#include "Squash.hpp"
#include "SIMDType.hpp"

template<SIMDType simd>
class SIMDMixer : public Mixer {
private:
  SIMDMixer *mp; /**< points to a Mixer to combine results */
  constexpr int simdWidth() const;
public:
  SIMDMixer(const Shared* const sh, const int n, const int m, const int s, const int promoted);
  ~SIMDMixer() override;
  void setScaleFactor(const int sf0, const int sf1) override;
  void promote(int x) override;
  void update() override;
  int p() override;
};


template class SIMDMixer<SIMDType::SIMD_NONE>;
template class SIMDMixer<SIMDType::SIMD_SSE2>;
template class SIMDMixer<SIMDType::SIMD_AVX2>;
template class SIMDMixer<SIMDType::SIMD_AVX512>;
template class SIMDMixer<SIMDType::SIMD_NEON>;
