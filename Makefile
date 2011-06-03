VER=0.0.3
# Semantic Versioning (http://semver.org/) compliant tag name
TAGNAME=v$(VER)

all: dist

test:

dist: test
	mkdir cronwrap-$(VER)
	git archive $(TAGNAME) | tar -x -C cronwrap-$(VER)
	tar czf cronwrap-$(VER).tar.gz cronwrap-$(VER)
	rm -rf cronwrap-$(VER)
	openssl md5 cronwrap-$(VER).tar.gz > cronwrap-$(VER).tar.gz.md5
	openssl sha1 cronwrap-$(VER).tar.gz > cronwrap-$(VER).tar.gz.sha1
	gpg --detach --armor cronwrap-$(VER).tar.gz

tag:
	git tag $(TAGNAME)

tpkg:
	mkdir tpkgwork
	sed 's/%VERSION%/$(VER)/' tpkg.yml > tpkgwork/tpkg.yml
	mkdir -p tpkgwork/reloc/bin
	cp -p cronwrap tpkgwork/reloc/bin
	mkdir -p tpkgwork/reloc/share/doc/cronwrap-$(VER)
	cp -p README TODO tpkgwork/reloc/share/doc/cronwrap-$(VER)
	tpkg --make tpkgwork
	rm -rf tpkgwork

clean:
	rm cronwrap-*.tar.gz* cronwrap-*.tpkg

