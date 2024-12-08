#include "FileDisk.hpp"
#include "../SystemDefines.hpp"
#include <sys/mman.h>


FILE* FileDisk::makeTmpFile() { 
    // Define the size of the memory-mapped region (e.g., 1 MB)
    size_t mmap_size = 1024 * 1024;

    // Create an anonymous memory-mapped region
    void* mmap_region = mmap(nullptr, mmap_size, PROT_READ | PROT_WRITE,
                             MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

    memset(mmap_region, 0, mmap_size);
    if (mmap_region == MAP_FAILED) {
        perror("mmap");
        return nullptr;
    }

    // Use `fmemopen` to associate the memory-mapped region with a FILE*
    FILE* file = fmemopen(mmap_region, mmap_size, "w+b");
    if (!file) {
        perror("fmemopen");
        munmap(mmap_region, mmap_size); // Cleanup in case of failure
        return nullptr;
    }

    return file;
}

FileDisk::FileDisk() { file = nullptr; }

FileDisk::~FileDisk() { close(); }

bool FileDisk::open(const char *filename, bool mustSucceed) {
    if (mustSucceed) {
        perror("FILEDISK::OPEN called with musSucceed=true");
    }
    return false; // no opening while fuzzing
 }

void FileDisk::create(const char *filename) {
    assert(file == nullptr);
    //makeDirectories(filename);
    file = makeTmpFile();
    if( file == nullptr ) {
        printf("Unable to create file %s (%s)", filename, strerror(errno));
        quit();
    }
}

void FileDisk::createTmp() {
    assert(file == nullptr);
    file = makeTmpFile();
    if( file == nullptr ) {
        printf("Unable to create temporary file (%s)", strerror(errno));
        quit();
    }
}

void FileDisk::close() {
    if (file != nullptr) {
        // Get the underlying buffer from the FILE* (only valid for fmemopen)
        void* mmap_region = nullptr;
        size_t mmap_size = 0;
        fflush(file); // Flush before querying the buffer
        mmap_region = static_cast<void*>(file->_IO_buf_base); // Access mmap base

        fclose(file); // Close the FILE* stream
        if (mmap_region) {
            munmap(mmap_region, mmap_size); // Unmap the memory region
        }
    }
    file = nullptr;
}

int FileDisk::getchar() { return fgetc(file); }

void FileDisk::putChar(uint8_t c) { fputc(c, file); }

uint64_t FileDisk::blockRead(uint8_t *ptr, uint64_t count) { return fread(ptr, 1, count, file); }

void FileDisk::blockWrite(uint8_t *ptr, uint64_t count) { fwrite(ptr, 1, count, file); }

void FileDisk::setpos(uint64_t newPos) { fseeko(file, newPos, SEEK_SET); }

void FileDisk::setEnd() { fseeko(file, 0, SEEK_END); }

uint64_t FileDisk::curPos() { return ftello(file); }

bool FileDisk::eof() { return feof(file) != 0; }