#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>

static int glob(const std::string &pattern, const std::string &text) {
  int p = 0;
  int t = 0;
  int np = 0;
  int nt = 0;
  while (p < pattern.length() or t < text.length()) {
    if (p < pattern.length()) {
      switch (pattern[p]) {
      case '*':
        np = p;
        nt = t + 1;
        p++;
        continue;
      case '?':
        if (nt < text.length()) {
          p++;
          t++;
          continue;
        }
        break;
      default:
        if (t < text.length() and text[t] == pattern[p]) {
          p++;
          t++;
          continue;
        }
      }
    }
    if (nt > 0 and nt <= text.length()) {
      p = np;
      t = nt;
      continue;
    }
    return 0;
  }
  return 1;
}

static int walk(const std::filesystem::path &dir, const std::string &pattern) {
  for (auto &p : std::filesystem::directory_iterator(dir)) {
    if (p.is_directory()) {
      walk(p.path(), pattern);
      continue;
    }
    std::ifstream file(p.path());
    std::string line;
    int lineno = 0;
    while (std::getline(file, line)) {
      lineno++;
      if (line.find('\0') != std::string::npos) {
        break;
      }
      if (glob(pattern, line)) {
        std::cout << p.path() << ":" << lineno << "\t" << line << std::endl;
      }
    }
  }
  return 0;
}

#ifndef TEST
int main(int argc, char *argv[]) {
  if (argc != 2) {
    std::cout << "USAGE: " << argv[0] << "<pattern>" << std::endl;
    return 1;
  }
  return walk(".", argv[1]);
}
#endif
