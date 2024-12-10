#include "APM.hpp"
#include "Array.hpp"
#include "Squash.hpp"
#include "Stretch.hpp"
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
std::filesystem::path generateCachePath(int n, int s, int limit) {
  std::string filename = "apm_cache_n" + std::to_string(n) +
                          "_s" + std::to_string(s) +
                          "_limit" + std::to_string(limit) + ".bin";
  return getCacheDirectory() / filename;
}

// Load cached data or initialize new data
void APM::loadOrInitialize(int n, int s, int limit) {
    std::filesystem::path filepath = generateCachePath(n, s, limit);

    if (std::filesystem::exists(filepath)) {
        // Load from file
        std::ifstream infile(filepath, std::ios::binary);
        if (infile) {
            t.resize(N);
            infile.read(reinterpret_cast<char*>(&t[0]), N * sizeof(uint32_t));
            if (!infile) {
                throw std::runtime_error("Error reading file " + filepath.string());
            }
        } else {
            throw std::runtime_error("Unable to open file " + filepath.string());
        }
    } else {
        // Initialize
        t.resize(N);
        for (int i = 0; i < N; ++i) {
            int p = ((i % steps * 2 + 1) * 4096) / (steps * 2) - 2048;
            t[i] = (uint32_t(squash(p)) << 20) + 6; // initial count: 6
        }
        // Save to file
        saveToFile(filepath);
    }
}

// Save data to file
void APM::saveToFile(const std::filesystem::path& filepath) {
    std::ofstream outfile(filepath, std::ios::binary);
    if (outfile) {
        outfile.write(reinterpret_cast<const char*>(&t[0]), N * sizeof(uint32_t));
        if (!outfile) {
            throw std::runtime_error("Error writing to file " + filepath.string());
        }
    } else {
        throw std::runtime_error("Unable to open file for writing: " + filepath.string());
    }
}

APM::APM(const Shared* const sh, const int n, const int s, const int limit) : AdaptiveMap(sh, n * s), N(n * s), steps(s), cxt(0), limit(limit) {
  assert(s > 4); // number of steps - must be a positive integer bigger than 4
  loadOrInitialize(n, s, limit);
}

void APM::update() {
  assert(cxt >= 0 && cxt < N);
  AdaptiveMap::update(&t[cxt], limit);
}

int APM::p(int pr, int cx) {
  shared->GetUpdateBroadcaster()->subscribe(this);
  assert(pr >= 0 && pr < 4096);
  assert(cx >= 0 && cx < N / steps);
  pr = (stretch(pr) + 2048) * (steps - 1);
  int wt = pr & 0x0fff; // interpolation weight (0..4095)
  cx = cx * steps + (pr >> 12);
  assert(cx >= 0 && cx < N - 1);
  cxt = cx + (wt >> 11);
  pr = ((t[cx] >> 13) * (4096 - wt) + (t[cx + 1] >> 13) * wt) >> 19;
  return pr;
}
