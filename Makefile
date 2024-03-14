SHELL=/bin/bash

test:
	@./test

.PHONY: test

.DEFAULT_GOAL := test
