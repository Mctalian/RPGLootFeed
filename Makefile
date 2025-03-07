.PHONY: all_checks hardcode_string_check missing_translation_check missing_locale_key_check test test-ci local check_untracked_files

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
	@rm -rf luacov-html && rm -rf luacov.*out && $(ROCKSBIN)/busted --coverage RPGLootFeed_spec && $(ROCKSBIN)/luacov && echo "\nCoverage report generated at luacov-html/index.html"

test-only:
	@$(ROCKSBIN)/busted --tags=only RPGLootFeed_spec

test-ci:
	@rm -rf luacov-html && rm -rf luacov.*out && $(ROCKSBIN)/busted --coverage -o=TAP RPGLootFeed_spec && $(ROCKSBIN)/luacov

lua_deps:
	@luarocks install busted --local
	@luarocks install luacov --local
	@luarocks install luacov-html --local

check_untracked_files:
	@if [ -n "$$(git ls-files --others --exclude-standard)" ]; then \
		echo "You have untracked files:"; \
		git ls-files --others --exclude-standard; \
		echo ""; \
		echo "This may cause errors in game. Please stage or remove them."; \
		exit 1; \
	else \
		echo "No untracked files."; \
	fi

watch: missing_locale_key_check check_untracked_files
	@../wow-build-tools/dist/wow-build-tools watch -t RPGLootFeed -r ./.release

build: missing_locale_key_check check_untracked_files
	@../wow-build-tools/dist/wow-build-tools build -d -t RPGLootFeed -r ./.release
