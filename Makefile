MAKE_FLAGS += --always-make

LUACHECK_IMAGE := ghcr.io/lunarmodules/luacheck:master
BUSTED_IMAGE := ghcr.io/lunarmodules/busted:master

LUALS_IMAGE := ghcr.io/bkhl/lsp-images/lua-language-server:latest
LUALS_CACHE := $(HOME)/.cache/lua-language-server

define run
	podman run --rm --interactive --volume $(CURDIR):$(CURDIR):z --workdir $(CURDIR)
endef

lint:
	$(run) $(LUACHECK_IMAGE) --no-color $(CURDIR)

test:
	$(run) $(BUSTED_IMAGE) --pattern=test_ $(CURDIR)

lsp:
	@mkdir -p "$(LUALS_CACHE)"
	@exec podman run --rm -i --init --network=none --pull=never \
		-v "$(CURDIR):$(CURDIR):ro,z" \
		-v "$(LUALS_CACHE):$(LUALS_CACHE):z" \
		-w "$(CURDIR)" \
		$(LUALS_IMAGE) \
		--metapath="$(LUALS_CACHE)/meta" \
		--logpath="$(LUALS_CACHE)/log"
