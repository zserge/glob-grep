#define TEST
#include "glob.cc"
#include <cassert>

int main() {
  assert(glob("", ""));
  assert(glob("hello", "hello"));
  assert(glob("h??lo", "hello"));
  assert(glob("h*o", "hello"));
  assert(glob("h*ello", "hello"));
  assert(glob("*h*o*", "hello world"));
  assert(glob("h*o*", "hello world"));
  assert(glob("*h*d", "hello world"));
  assert(glob("*h*l*w*d", "hello world"));
  assert(glob("*h?l*w*d", "hello world"));

  assert(!glob("hello", "hi"));
  assert(!glob("h?i", "hi"));
  assert(!glob("h*l", "hello"));
  return 0;
}
