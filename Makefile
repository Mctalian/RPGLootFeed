.PHONY: all_checks venv_up hardcode_string_check missing_translation_check

all_checks: venv_up hardcode_string_check missing_translation_check

# Variables
PYTHON := python3

# Target for running the hardcoded string checker
hardcode_string_check:
	@.venv/bin/python .scripts/hardcode_string_check.py

# Target for running the missing translation checker
missing_translation_check:
	@.venv/bin/python .scripts/missing_translation_check.py

venv_up:
	@if [ ! -d ".venv" ]; then $(PYTHON) -m venv ./.venv; fi
