.PHONY: all_checks hardcode_string_check missing_translation_check missing_locale_key_check test test-ci local

all_checks: hardcode_string_check missing_translation_check missing_locale_key_check

# Variables
ROCKSBIN := $(HOME)/.luarocks/bin

# Target for running the hardcoded string checker
hardcode_string_check:
	@poetry run python .scripts/hardcode_string_check.py

# Target for running the missing translation checker
missing_translation_check:
	@poetry run python .scripts/missing_translation_check.py

missing_locale_key_check:
	@poetry run python .scripts/check_for_missing_locale_keys.py

test:
	@rm -rf luacov-html && rm -rf luacov.*out && $(ROCKSBIN)/busted --coverage && $(ROCKSBIN)/luacov

test-ci:
	@rm -rf luacov-html && rm -rf luacov.*out && $(ROCKSBIN)/busted --coverage -o=TAP && $(ROCKSBIN)/luacov

lua_deps:
	@luarocks install busted --local
	@luarocks install luacov --local
	@luarocks install luacov-html --local

local:
	@.release/local.sh -D
