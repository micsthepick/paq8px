#include "APMPost.hpp"
#include "ArithmeticEncoder.hpp"
#include "UpdateBroadcaster.hpp"

// Get the cache directory path
std::filesystem::path getCacheDirectory() {
  const char* home = std::getenv("HOME"); // Get the HOME environment variable
  if (!home) {
    home = std::getenv("USERPROFILE");
    if (!home) {
      throw std::runtime_error("HOME or USERPROFILE environment variable is not set.");
    }
  }

  std::filesystem::path cacheDir = std::filesystem::path(home) / ".cache/paq8px";
  if (!std::filesystem::exists(cacheDir)) {
    std::filesystem::create_directories(cacheDir); // Create the directory if it doesn't exist
  }
  return cacheDir;
}

// Generate the full cache file path based on parameters
std::filesystem::path generateCachePath(int n) {
  std::string filename = "apmpost_cache_n" + std::to_string(n) + ".bin";
  return getCacheDirectory() / filename;
}

// Load cached data or initialize new data
void APMPost::loadOrInitialize() {
  std::filesystem::path filepath = generateCachePath(n);

  if (std::filesystem::exists(filepath)) {
    // Load from file
    std::ifstream infile(filepath, std::ios::binary);
    if (infile) {
      t.resize(n * 4096);
      infile.read(reinterpret_cast<char*>(&t[0]), n * 4096 * sizeof(uint64_t));
      if (!infile) {
        throw std::runtime_error("Error reading file " + filepath.string());
      }
    } else {
      throw std::runtime_error("Unable to open file " + filepath.string());
    }
  } else {
    // Initialize
    t.resize(n * 4096);
    for(size_t i = 0; i < n; ++i ) {
      for(uint64_t j = 0; j < 4096; ++j ) {
        t[i * 4096 + j] = ((4096 - j) >> 1) << 32 | (j >> 1);
      }
    }
    // Save to file
    saveToFile(filepath);
  }
}

// Save data to file
void APMPost::saveToFile(const std::filesystem::path& filepath) {
    std::ofstream outfile(filepath, std::ios::binary);
    if (outfile) {
        outfile.write(reinterpret_cast<const char*>(&t[0]), n * 4096 * sizeof(uint64_t));
        if (!outfile) {
            throw std::runtime_error("Error writing to file " + filepath.string());
        }
    } else {
        throw std::runtime_error("Unable to open file for writing: " + filepath.string());
    }
}

APMPost::APMPost(const Shared* const sh, const uint32_t n) : shared(sh), index(0), n(n), t(n* UINT64_C(4096)) {
  assert(n > 0);
  loadOrInitialize();
}

uint32_t APMPost::p(const uint32_t pr, const uint32_t cxt) {
  shared->GetUpdateBroadcaster()->subscribe(this);
  assert(pr < 4096 && cxt < n);
  index = cxt * 4096 + pr;
  uint64_t n0 = t[index] >> 32;
  uint64_t n1 = t[index] &0xffffffff;
  n0 = n0 * 2 + 1;
  n1 = n1 * 2 + 1;
  constexpr int PRECISION = ArithmeticEncoder::PRECISION;
  return static_cast<uint32_t>((n1 << PRECISION) / (n0+n1));
}

void APMPost::update() {
  INJECT_SHARED_y
  uint64_t n0, n1, value;
  value = t[index];
  n0 = value >> 32;
  n1 = value & 0xffffffff;

  n0 += 1 - y;
  n1 += y;
  int shift = (n0 | n1) >> 32; // shift: 0 or 1
  n0 >>= shift;
  n1 >>= shift;

  t[index] = n0 << 32 | n1;
}
