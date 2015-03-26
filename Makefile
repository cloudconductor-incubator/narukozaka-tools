ODGS  := $(wildcard draw/*.odg)
PNGS  := $(patsubst %.odg,%.png,${ODGS})

all: boxes/build.stamp vmimages/build.stamp

boxes/build.stamp:
	(cd boxes && ./download-boxes.sh)
	touch $@

vmimages/build.stamp:
	(cd vmimages && ./prepare-vmimage.sh kvm x86_64 centos-6.4)
	touch $@

clean:
	rm -f boxes/*.stamp boxes/*.tmp boxes/*.box boxes/*.md5 vmimages/*.stamp
	rm -rf vmimages/guestroot*

test:
	rake

updatefig: ${PNGS}

%.png: %.odg
	unoconv -n -f png -o $@.tmp $< 2> /dev/null   || \
	  unoconv -f png -o $@.tmp $<                 || \
	  unoconv -n -f png -o $@.tmp $< 2> /dev/null || \
	  unoconv -f png -o $@.tmp $<
	convert -resize 800x $@.tmp $@
	rm -f $@.tmp

.PHONY: all updatefig clean
