ifndef VERBOSE
.SILENT:
endif

.PHONY: docs coverage

docs:
	dart doc --validate-links

coverage:
	# Reference: https://pub.dev/packages/coverage
	dart pub global run coverage:test_with_coverage \
	  --function-coverage --branch-coverage
	genhtml coverage/lcov.info -o coverage/html
