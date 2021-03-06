# MAKEFILE
#
# @author      Nicola Asuni <nicola.asuni@vonage.com>
# @link        https://github.com/nexmoinc/numkey
# ------------------------------------------------------------------------------

# CVS path (path to the parent dir containing the project)
CVSPATH=github.com/nexmoinc

# Project vendor
VENDOR=nexmoinc

# Project name
PROJECT=numkey

# Current directory
CURRENTDIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

# Target directory
TARGETDIR=$(CURRENTDIR)target

# --- MAKE TARGETS ---

# Display general help about this command
.PHONY: help
help:
	@echo ""
	@echo "NumKey Makefile."
	@echo "The following commands are available:"
	@echo ""
	@echo "    make c            : Build and test the C version"
	@echo "    make cgo          : Build and test the GO C-wrapper version"
	@echo "    make go           : Build and test the GO version"
	@echo "    make javascript   : Build and test the Javascript version"
	@echo "    make python       : Build and test the Python version"
	@echo "    make java         : Build and test the Java version"
	@echo "    make clean        : Remove any build artifact"
	@echo "    make dbuild       : Build everything inside a Docker container"
	@echo ""

all: clean c cgo go javascript python

# Build and test the C version
.PHONY: c
c:
	cd c && make all

# Build and test the CGO version
.PHONY: cgo
cgo:
	cd cgo && make all

# Build and test the GO version
.PHONY: go
go:
	cd go && make all

# Build and test the Javascript version
.PHONY: javascript
javascript:
	cd javascript && make all

# Build and test the Python version
.PHONY: python
python:
	cd python && make all

# Build and test the Java version
.PHONY: java
java:
	cd java && make all

# Remove any build artifact
.PHONY: clean
clean:
	rm -rf target
	cd c && make clean
	cd cgo && make clean
	cd go && make clean
	cd javascript && make clean
	cd python && make clean
	cd java && make clean

# Build everything inside a Docker container
.PHONY: dbuild
dbuild:
	@mkdir -p $(TARGETDIR)
	@rm -rf $(TARGETDIR)/*
	@echo 0 > $(TARGETDIR)/make.exit
	CVSPATH=$(CVSPATH) VENDOR=$(VENDOR) PROJECT=$(PROJECT) MAKETARGET='$(MAKETARGET)' $(CURRENTDIR)/dockerbuild.sh
	@exit `cat $(TARGETDIR)/make.exit`

# Publish Documentation in GitHub (requires writing permissions)
.PHONY: pubdocs
pubdocs:
	rm -rf ./target/DOCS
	rm -rf ./target/gh-pages
	mkdir -p ./target/DOCS/c
	cp -r ./c/target/build/doc/html/* ./target/DOCS/c/
	mkdir -p ./target/DOCS/cgo
	cp -r ./cgo/target/docs/* ./target/DOCS/cgo/
	mkdir -p ./target/DOCS/go
	cp -r ./go/target/docs/* ./target/DOCS/go/
	mkdir -p ./target/DOCS/python
	cp -r ./python/target/doc/numkey.html ./target/DOCS/python/
	cp ./resources/doc/index.html ./target/DOCS/
	git clone git@github.com:nexmoinc/numkey.git ./target/gh-pages
	cd target/gh-pages && git checkout gh-pages
	mv -f ./target/gh-pages/.git ./target/DOCS/
	rm -rf ./target/gh-pages
	cd ./target/DOCS/ && \
	git add . -A && \
	git commit -m 'Update documentation' && \
	git push origin gh-pages --force
