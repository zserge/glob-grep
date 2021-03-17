all:
	$(CXX) -static glob.cc -std=c++17 -o glob

test:
	$(CXX) glob_test.cc -std=c++17 -o glob_test
	./glob_test

clean:
	rm -f glob_test glob
