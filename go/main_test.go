package main

import "testing"

func TestGlob(t *testing.T) {
	for _, test := range []struct {
		Pattern string
		Text    string
		Match   bool
	}{
		{"", "", true},
		{"hello", "hello", true},
		{"h??lo", "hello", true},
		{"h*o", "hello", true},
		{"h*ello", "hello", true},
		{"*h*o*", "hello world", true},
		{"h*o*", "hello world", true},
		{"*h*d", "hello world", true},
		{"*h*l*w*d", "hello world", true},
		{"*h?l*w*d", "hello world", true},
		{"hello", "hi", false},
		{"h?i", "hi", false},
		{"h*l", "hello", false},
	} {
		if Glob(test.Pattern, test.Text) != test.Match {
			t.Error(test.Pattern, test.Text, test.Match)
		}
	}
}
