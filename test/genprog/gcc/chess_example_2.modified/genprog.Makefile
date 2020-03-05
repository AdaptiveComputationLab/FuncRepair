seed?=0
CWD = $(shell pwd)


all: clean_all

clean:
	rm -rf temp.s gcd.cache a.out repair.c testruns.txt
	rm -f coverage coverage.c coverage.path.neg coverage.path.pos

clean_all: clean
	rm -rf *repair* *testbed*
	rm -rf *sanity* *debug* 00*
	rm -f  00*
	rm -f  n1 p1 p2 p3 p4 p5
	rm -f *cache
	rm -f repair.*
	rm -f coverage.*
	rm -f *.ast
	rm -f *.ht
	rm -f *.path
	rm -f *-coverage.c
	rm -f *-baseline.c
