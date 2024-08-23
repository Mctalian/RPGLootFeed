.PHONY: all_checks

all_checks: hardcode_string_check missing_translation_check

# Variables
PYTHON := python3

# Target for running the hardcoded string checker
hardcode_string_check:
	@$(PYTHON) .scripts/hardcode_string_check.py

# Target for running the missing translation checker
missing_translation_check:
	@$(PYTHON) .scripts/missing_translation_check.py