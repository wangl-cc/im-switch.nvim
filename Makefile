SRCDIR = src
BUILDDIR = build
CC ?= clang

TARGETS = build/im-select

all: $(TARGETS)

ifeq ($(shell uname),Darwin)
$(BUILDDIR)/im-select: $(SRCDIR)/im-select.m
	$(CC) -o $@ $< -framework Foundation -framework Carbon -arch x86_64 -arch arm64
endif

