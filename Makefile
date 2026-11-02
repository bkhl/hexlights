BUSTED_IMAGE := ghcr.io/lunarmodules/busted:master

LUALS_IMAGE := ghcr.io/bkhl/tool-images/lua-language-server:latest
LUALS_CACHE := $(or $(XDG_RUNTIME_DIR),$(TMPDIR),/tmp)/lua-language-server/$(notdir $(CURDIR))

define run
	podman run --rm --interactive \
	--network=none \
	--volume="$(CURDIR):$(CURDIR):ro,z" \
	--workdir "$(CURDIR)"
endef

LUALS_CACHE_ARGS := --env=LUALS_CACHE="$(LUALS_CACHE)" --volume="$(LUALS_CACHE):$(LUALS_CACHE):z"

$(LUALS_CACHE):
	@mkdir -p "$(LUALS_CACHE)"

.PHONY: lint
lint: $(LUALS_CACHE)
	$(run) $(LUALS_CACHE_ARGS) $(if $(MAKE_TERMOUT),--tty) $(LUALS_IMAGE) --check="$(CURDIR)" --checklevel=Warning

test:
	$(run) $(BUSTED_IMAGE) --pattern=test_ $(CURDIR)

.PHONY: lsp
lsp: $(LUALS_CACHE)
	@exec $(run) $(LUALS_CACHE_ARGS) $(LUALS_IMAGE) --metapath="$(LUALS_CACHE)/meta" --logpath="$(LUALS_CACHE)/log"
