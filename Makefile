MAKE_FLAGS += --always-make

define run
	podman run --rm --interactive --tty --volume $(CURDIR):$(CURDIR):z --workdir $(CURDIR)
endef

lint:
	$(run) docker.io/pipelinecomponents/luacheck:latest hexlights.lua
