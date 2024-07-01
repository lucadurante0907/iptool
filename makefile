UNAME := $(shell uname)
UNAME_M := $(shell uname -m)

ifeq ($(UNAME), Linux)
# do something Linux
BISON_OPTIONS = --report-file=debug.txt
# BISON_OPTIONS = --report-file=debug.txt -Wcounterexamples
CLEAN_OS_DEP = rm debug.txt
LINK_OPTIONS =
# LINK_OPTIONS = -lfl
endif
ifeq ($(UNAME), Darwin)
# do something Darwin
BISON_OPTIONS = 
LINK_OPTIONS = 
# CLEAN_OS_DEP = rm lang_bison.output
ifeq ($(UNAME_M), x86_64)
MARCH = -march=native
endif
ifeq ($(UNAME_M), arm64)
MARCH =
endif
endif

CC = gcc
# COMPILE_OPTIONS = -ggdb 
# COMPILE_OPTIONS = -Ofast -Wall -Wstrict-prototypes -std=c99 -march=native 
COMPILE_OPTIONS = -Ofast -pedantic -Wall -Wstrict-prototypes -std=c99 $(MARCH)
# DEF = -D_POSIX_C_SOURCE
# DEF = -D_POSIX_C_SOURCE -DMEMERROR
# DEF = -D_POSIX_C_SOURCE -DMEMSTAT
DEF = -D_POSIX_C_SOURCE -DMEMSTAT -DMEMFILE

tool: lang_bison.o lang_flex.o main.o memstat.o list.o hash.o
	$(CC) -o tool lang_bison.o lang_flex.o main.o memstat.o list.o hash.o $(LINK_OPTIONS)

lang_bison.o: lang_bison.c memstat.h parse_tree.h 
	$(CC) $(COMPILE_OPTIONS) $(DEF) -D__STEP_1__ -c lang_bison.c

lang_flex.o: lang_flex.c parse_tree.h memstat.h lang_bison.h
	$(CC) $(COMPILE_OPTIONS) $(DEF) -D__STEP_1__ -c lang_flex.c

main.o: main.c memstat.h parse_tree.h
	$(CC) $(COMPILE_OPTIONS) $(DEF) -D__STEP_1__ -c main.c

memstat.o: memstat.c
	$(CC) $(COMPILE_OPTIONS) $(DEF) -c memstat.c

lang_bison.c: lang.y memstat.h parse_tree.h 
	bison -d $(BISON_OPTIONS) -olang_bison.c lang.y
#	bison -t -v -d $(BISON_OPTIONS) -olang_bison.c lang.y

lang_flex.c: lang.fl parse_tree.h memstat.h lang_bison.h
	flex -olang_flex.c -CFa lang.fl

list.o: list.c list.h memstat.h
	$(CC) $(COMPILE_OPTIONS) $(DEF) -c list.c

hash.o: hash.c list.h hash.h memstat.h
	$(CC) $(COMPILE_OPTIONS) $(DEF) -c hash.c

clean :
	rm -f lang_*.*
	rm -f *.o
	rm -f tool
	rm -f *~
	rm -f debug.txt
	rm -f *.output
	rm -f memstat.dat

