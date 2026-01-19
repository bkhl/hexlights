MAKE_FLAGS += --always-make

LUACHECK_IMAGE := ghcr.io/lunarmodules/luacheck:master
BUSTED_IMAGE := ghcr.io/lunarmodules/busted:master

define run
	podman run --rm --interactive --volume $(CURDIR):$(CURDIR):z --workdir $(CURDIR)
endef

lint:
	$(run) $(LUACHECK_IMAGE) --no-color $(CURDIR)

test:
	$(run) $(BUSTED_IMAGE) --pattern=test_ $(CURDIR)
