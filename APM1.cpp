#include "APM1.hpp"
#include "Array.hpp"
#include "UpdateBroadcaster.hpp"
#include "Squash.hpp"
#include "Stretch.hpp"

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
  std::string filename = "apm1_cache_n" + std::to_string(n) + ".bin";
  return getCacheDirectory() / filename;
}

// Load cached data or initialize new data
void APM1::loadOrInitialize() {
  std::filesystem::path filepath = generateCachePath(n);

  if (std::filesystem::exists(filepath)) {
    // Load from file
    std::ifstream infile(filepath, std::ios::binary);
    if (infile) {
      t.resize(n * 33);
      infile.read(reinterpret_cast<char*>(&t[0]), n * 33 * sizeof(uint16_t));
      if (!infile) {
        throw std::runtime_error("Error reading file " + filepath.string());
      }
    } else {
      throw std::runtime_error("Unable to open file " + filepath.string());
    }
  } else {
    // Initialize
    t.resize(n * 33);
    for( int i = 0; i < n; ++i ) {
      for( int j = 0; j < 33; ++j ) {
        if( i == 0 ) {
          t[i * 33 + j] = squash((j - 16) * 128) * 16;
        } else {
          t[i * 33 + j] = t[j];
        }
      }
    }
    // Save to file
    saveToFile(filepath);
  }
}

// Save data to file
void APM1::saveToFile(const std::filesystem::path& filepath) {
    std::ofstream outfile(filepath, std::ios::binary);
    if (outfile) {
        outfile.write(reinterpret_cast<const char*>(&t[0]), n * 33 * sizeof(uint16_t));
        if (!outfile) {
            throw std::runtime_error("Error writing to file " + filepath.string());
        }
    } else {
        throw std::runtime_error("Unable to open file for writing: " + filepath.string());
    }
}


APM1::APM1(const Shared* const sh, const int n, const int r) : shared(sh), index(0), n(n), t(n * 33), rate(r) {
  assert(n > 0 && rate > 0 && rate < 32);
  // maps p, cxt -> p initially
  loadOrInitialize();
}

int APM1::p(int pr, const int cxt) {
  shared->GetUpdateBroadcaster()->subscribe(this);
  assert(pr >= 0 && pr < 4096 && cxt >= 0 && cxt < n);
  pr = stretch(pr);
  const int w = pr & 127; // interpolation weight (33 points)
  index = ((pr + 2048) >> 7) + cxt * 33;
  return (t[index] * (128 - w) + t[index + 1] * w) >> 11;
}

void APM1::update() {
  INJECT_SHARED_y
  const int g = (y << 16) + (y << rate) - y - y;
  t[index] += (g - t[index]) >> rate;
  t[index + 1] += (g - t[index + 1]) >> rate;
}
