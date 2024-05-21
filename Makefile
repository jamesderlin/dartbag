ifndef VERBOSE
.SILENT:
endif

.PHONY: clean
clean:
	rm -rf .dart_tool coverage doc

.PHONY: docs
docs:
	dart doc --validate-links

.PHONY: coverage
coverage:
	# Reference: <https://pub.dev/packages/coverage>
	dart pub global run coverage:test_with_coverage \
	  --function-coverage --branch-coverage
	genhtml coverage/lcov.info -o coverage/html

.PHONY: publish
publish:
	# Don't publish untracked/ignored files.
	git ls-files --others --directory > .pubignore
	dart pub publish
