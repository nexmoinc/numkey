# MAKEFILE
#
# @author      Nicola Asuni <nicola.asuni@vonage.com>
# @link        https://github.com/nexmoinc/numkey
# ------------------------------------------------------------------------------

# --- MAKE TARGETS ---

# Display general help about this command
.PHONY: help
help:
	@echo ""
	@echo "NumKey Javascript Makefile."
	@echo "Requires: node-js and uglify-js."
	@echo "The following commands are available:"
	@echo ""
	@echo "    make build   : Build and test a minified version of the library"
	@echo "    make clean   : Remove any build artifact"
	@echo "    make format  : Format the source code"
	@echo "    make test    : Run the unit tests against source code"
	@echo ""

all: clean format test build

# Build a minified version of the library
.PHONY: build
build:
	@mkdir -p target/build
	uglifyjs --compress --keep-fnames --comments --output target/build/numkey.js src/numkey.js 
	cd test && node test_numkey.js '../target/build/numkey.js'

# Remove any build artifact
.PHONY: clean
clean:
	rm -rf target

# Format the source code
.PHONY: format
format:
	js-beautify --replace src/numkey.js
	js-beautify --replace test/test_numkey.js

# Run the unit tests
.PHONY: test
test:
	cd test && node test_numkey.js '../src/numkey.js'
