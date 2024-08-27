.PHONY: all_checks venv_up hardcode_string_check missing_translation_check test test-ci

all_checks: venv_up hardcode_string_check missing_translation_check

# Variables
PYTHON := python3
ROCKSBIN := $(HOME)/.luarocks/bin

# Target for running the hardcoded string checker
hardcode_string_check:
	@.venv/bin/python .scripts/hardcode_string_check.py

# Target for running the missing translation checker
missing_translation_check:
	@.venv/bin/python .scripts/missing_translation_check.py

venv_up:
	@if [ ! -d ".venv" ]; then $(PYTHON) -m venv ./.venv; fi

test:
	@rm -rf luacov-html && rm -rf luacov.*out && $(ROCKSBIN)/busted --coverage && $(ROCKSBIN)/luacov 

test-ci:
	@rm -rf luacov-html && rm -rf luacov.*out && $(ROCKSBIN)/busted --coverage -o=TAP && $(ROCKSBIN)/luacov
