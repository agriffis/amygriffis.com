SHELL = /bin/bash
JEKYLL_ARGS ?=
COMPASS_ARGS ?= --sass-dir site/css --css-dir public/css --images-dir img --javascripts-dir js --relative-assets
WATCH_EVENTS = create delete modify move
WATCH_DIRS = site
THUMBS_BASE = 280
THUMBS_MULTIPLIERS = 1 2 3
# use the desired extension on THUMBS rather than the source extension,
# in other words .png even if the source is .jpg
THUMBS = \
    amygriffis-book-keller-sq.jpg \
    amygriffis-info-email-sq.png \
    amygriffis-poster-oop-sq.jpg \
    pattern-photo-wax.jpg \
    pattern-photo-wire.jpg \
    pattern-photo-wood.jpg \
    amygriffis-icons-delonghi-sq.png \
    amygriffis-vector-sage-sq.png

all:
	$(MAKE) thumbs  # do this first
	$(MAKE) jekyll
	$(MAKE) sass
	date > .sync

# This uses separate invocations of $(MAKE) rather than dependencies for
# the production target, to avoid make -j running clean/all in parallel.
# COMPASS_ARGS is augmented and exported to override the ?= assignment when the
# submake runs.
production: export COMPASS_ARGS += -e production
production: export JEKYLL_ENV = production
production:
	$(MAKE) clean
	$(MAKE) all
#	./post-process.bash

jekyll:
	jekyll build $(JEKYLL_ARGS)

sass:
	compass compile $(COMPASS_ARGS)

watch:
	trap exit 2; \
	while true; do \
	    $(MAKE) all; \
	    inotifywait $(WATCH_EVENTS:%=-e %) --exclude '/\.' -r $(WATCH_DIRS); \
	done

serve:
#	jekyll serve --no-watch --skip-initial-build --host 0 --port 8000
	cd public && \
	browser-sync start -s --port 8000 --files ../.sync --no-notify --no-open --no-ui

sync_serve:
	while [[ ! -e .sync ]]; do sleep 0.1; done
	$(MAKE) serve

draft: export JEKYLL_ARGS += --drafts
draft dev:
	rm -f .sync
	$(MAKE) -j2 watch sync_serve

dream:
	rsync -az --exclude=.git --delete-before public/. amygriffis@amygriffis.com:amygriffis.com/

publish: production
	$(MAKE) dream

# This doesn't work with graphicsmagick, which only supports ico as read-only
# rather than read-write. See http://www.graphicsmagick.org/formats.html
favicon: site/favicon.ico
site/favicon.ico: site/img/logo/wave-32.png site/img/logo/wave-16.png
	convert $^ $@

thumbs:
	@cd site/gallery && \
	mkdir -p $(THUMBS_MULTIPLIERS:%=thumbs/%x) && \
	for t in $(THUMBS); do \
	    for x in $(THUMBS_MULTIPLIERS); do \
	        orig=$$(echo $${t%.*}.*); \
	        dest=thumbs/$${x}x/$$t; \
	        [[ -e $$dest && ! $$dest -ot $$orig ]] && continue; \
	        (set -x; convert -geometry "$$(($(THUMBS_BASE) * x))x>" \
                           "$$orig" "$$dest") || exit; \
	    done; \
	done

clean:
	rm -rf public && mkdir public
#	mv public public.old && mkdir public && mv public.old/.git public && rm -rf public.old

.FAKE: all production jekyll sass watch serve sync_serve draft dev dream publish favicon thumbs clean
