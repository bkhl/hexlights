MAKE_FLAGS += --always-make

define run
	podman run --rm --interactive --volume $(CURDIR):$(CURDIR):z --workdir $(CURDIR)
endef

lint:
	$(run) docker.io/pipelinecomponents/luacheck:latest luacheck --no-color $(CURDIR)
