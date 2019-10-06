ifeq ($(PACKAGE_SET),dom0)
  RPM_SPEC_FILES := xen-hvm-stubdom-legacy.spec
endif

NO_ARCHIVE := 1

INCLUDED_SOURCES = \
	gui-agent-xen-hvm-stubdom \
	core-vchan-xen \
	stubdom-dhcp \
	gui-common

SOURCE_COPY_IN := $(INCLUDED_SOURCES)

$(INCLUDED_SOURCES): PACKAGE=$@
$(INCLUDED_SOURCES): VERSION=$(shell git -C $(ORIG_SRC)/$(PACKAGE) rev-parse --short HEAD)
$(INCLUDED_SOURCES):
	$(BUILDER_DIR)/scripts/create-archive $(CHROOT_DIR)/$(DIST_SRC)/$(PACKAGE) $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)/
	mv $(CHROOT_DIR)/$(DIST_SRC)/$(PACKAGE)/$(PACKAGE)-$(VERSION).tar.gz $(CHROOT_DIR)/$(DIST_SRC)
	sed -i "s#@$(PACKAGE)@#$(PACKAGE)-$(VERSION).tar.gz#" $(CHROOT_DIR)/$(DIST_SRC)/xen-hvm-stubdom-legacy.spec.in
