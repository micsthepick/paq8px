#include "FileDisk.hpp"
#include "../SystemDefines.hpp"

FILE* FileDisk::makeTmpFile() { return nullptr; }

FileDisk::FileDisk() { file = nullptr; }

FileDisk::~FileDisk() { close(); }

bool FileDisk::open(const char *filename, bool mustSucceed) { return true; }

void FileDisk::create(const char *filename) {}

void FileDisk::createTmp() {}

void FileDisk::close() {}

int FileDisk::getchar() { return 0; }

void FileDisk::putChar(uint8_t c) { }

uint64_t FileDisk::blockRead(uint8_t *ptr, uint64_t count) { return 0; }

void FileDisk::blockWrite(uint8_t *ptr, uint64_t count) { }

void FileDisk::setpos(uint64_t newPos) { }

void FileDisk::setEnd() { }

uint64_t FileDisk::curPos() { return 0; }

bool FileDisk::eof() { return true; }