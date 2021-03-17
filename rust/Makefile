all:
	rustc -C target-feature=+crt-static glob.rs -o glob

test:
	rustc --test glob.rs -o glob_test
	./glob_test

clean:
	rm -f glob_test glob
