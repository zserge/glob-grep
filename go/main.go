package main

import (
	"bufio"
	"fmt"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"strings"
)

func Glob(pattern, text string) bool {
	p, t := 0, 0
	np, nt := 0, 0
	plen, tlen := len(pattern), len(text)
	for p < plen || t < tlen {
		if p < plen {
			switch c := pattern[p]; c {
			case '*':
				np, nt = p, t+1
				p++
				continue
			case '?':
				if nt < tlen {
					p++
					t++
					continue
				}
			default:
				if t < tlen && c == text[t] {
					p++
					t++
					continue
				}
			}
		}
		if nt > 0 && nt <= tlen {
			p, t = np, nt
			continue
		}
		return false
	}
	return true
}

func main() {
	if len(os.Args) != 2 {
		log.Fatalf("USAGE: %s <pattern>", os.Args[0])
	}
	pattern := os.Args[1]
	if err := filepath.Walk(".", func(path string, fi os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if fi.Mode()&fs.ModeType != 0 {
			return nil
		}
		f, err := os.Open(path)
		if err != nil {
			return err
		}
		defer f.Close()
		scanner := bufio.NewScanner(f)
		lineno := 0
		for scanner.Scan() {
			lineno++
			line := scanner.Text()
			if strings.Contains(line, "\x00") {
				return nil
			}
			if Glob(pattern, line) {
				fmt.Printf("%s:%d\t%s\n", path, lineno, line)
			}
		}
		return scanner.Err()
	}); err != nil {
		log.Fatal(err)
	}
}
