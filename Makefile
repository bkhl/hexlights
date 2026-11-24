DEV_IMAGE := localhost/hexlights-dev:latest

LOVE_VERSION := 11.5
FENNEL_VERSION := 1.6.1

LUALS_IMAGE := ghcr.io/bkhl/tool-images/lua-language-server:latest
LUALS_CACHE := $(or $(XDG_RUNTIME_DIR),$(TMPDIR),/tmp)/lua-language-server/$(notdir $(CURDIR))

define run
	podman run --rm --interactive $(if $(MAKE_TERMOUT),--tty,) \
	--network=none \
	--volume="$(CURDIR):$(CURDIR):ro,z" \
	--workdir "$(CURDIR)"
endef

dev_image:
	podman build --file Containerfile --tag $(DEV_IMAGE) $(shell mktemp -d)

LOVE_APPIMAGE := lib/love-$(LOVE_VERSION)-x86_64.AppImage
$(LOVE_APPIMAGE):
	curl -sSL https://github.com/love2d/love/releases/download/$(LOVE_VERSION)/love-$(LOVE_VERSION)-x86_64.AppImage -o $@
	chmod +x $@

LOVE := lib/love-$(LOVE_VERSION)/AppRun
LIB += $(LOVE)
$(LOVE): $(LOVE_APPIMAGE)
	cd lib && ./$(notdir $<) --appimage-extract
	rm -rf lib/love-$(LOVE_VERSION) && mv lib/squashfs-root lib/love-$(LOVE_VERSION)
	touch $@

LIB += lib/fennel.lua
lib/fennel.lua:
	curl -sSL https://fennel-lang.org/downloads/fennel-$(FENNEL_VERSION).lua -o $@

.PHONY: run
run: $(LIB)
	$(LOVE) $(CURDIR)

.PHONY: fennel-ls
fennel-ls:
	@exec $(run) $(DEV_IMAGE) fennel-ls

.PHONY: fnlfmt
fnlfmt:
	@exec $(run) $(DEV_IMAGE) fnlfmt /dev/stdin

LUALS_CACHE_ARGS := --env=LUALS_CACHE="$(LUALS_CACHE)" --volume="$(LUALS_CACHE):$(LUALS_CACHE):z"
.PHONY: lua-language-server
lua-language-server: $(LUALS_CACHE)
	@exec $(run) $(LUALS_CACHE_ARGS) $(LUALS_IMAGE) --metapath="$(LUALS_CACHE)/meta" --logpath="$(LUALS_CACHE)/log"
