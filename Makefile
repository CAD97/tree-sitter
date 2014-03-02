.PHONY: all clean test debug valgrind

### install configuration ###
CXX       ?= clang++
CC        ?= clang
RM        ?= rm -f

### library configuration ###
LIB_NAME     = tree_sitter
DIR          = $(shell pwd)
SOURCES      = $(shell find src -name '*.cpp' -or -name '*.c')
TESTS        = $(shell find spec -name '*.cpp') $(shell find examples -name '*.c')
SRC_OBJECTS  = $(foreach file, $(SOURCES), $(basename $(file)).o)
TEST_OBJECTS = $(foreach file, $(TESTS), $(basename $(file)).o)
LIB_FILE     = lib$(LIB_NAME).a
TEST_BIN     = spec/run.out

### build configuration ###
CFLAGS ?= -Wall -g -m64
CPPFLAGS ?= -Wall -std=c++11 -g -m64

### targets ###
all: $(LIB_FILE)

$(LIB_FILE): $(SRC_OBJECTS)
	ar rcs $@ $^

test: $(TEST_BIN)
	./$<

$(TEST_BIN): $(TEST_OBJECTS) $(LIB_FILE)
	$(CXX) $(CPPFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -Iinclude -Isrc/runtime -c $< -o $@

%.o: %.cpp
	$(CXX) $(CPPFLAGS) -Iinclude -Isrc/compiler -Isrc/runtime -Iexternals/bandit -Ispec -c $< -o $@

debug: $(TEST_BIN)
	gdb $<

valgrind: $(TEST_BIN)
	valgrind --track-origins=yes --dsymutil=yes $(TEST_BIN)

clean:
	$(RM) $(SRC_OBJECTS) $(TEST_OBJECTS) $(LIB_FILE) $(TEST_BIN)
