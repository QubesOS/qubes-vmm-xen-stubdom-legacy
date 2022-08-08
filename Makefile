DIST_DOM0 ?= fc32
DISTFILES_MIRROR ?= https://ftp.qubes-os.org/distfiles/
version := $(or $(file <version),$(error Cannot determine version))

FETCH_CMD ?= curl --proto '=https' --proto-redir '=https' --tlsv1.2 --http1.1 -sSfL -o

all: help

UNTRUSTED_SUFF := .UNTRUSTED

# All the URLs we need to fetch. URLS ending in .sig result in fetching the
# signature file _and_ the file it signs for (assumed to be the basename).
URLS := \
    https://downloads.xenproject.org/release/xen/${version}/xen-${version}.tar.gz.sig \
    https://alpha.gnu.org/gnu/grub/grub-0.97.tar.gz.sig \
    https://download.savannah.gnu.org/releases/lwip/older_versions/lwip-1.3.0.tar.gz.sig \
    $(DISTFILES_MIRROR)/newlib-1.16.0.tar.gz \
    https://www.kernel.org/pub/software/utils/pciutils/pciutils-2.2.9.tar.bz2 \
    https://downloads.sourceforge.net/project/libpng/zlib/1.2.3/zlib-1.2.3.tar.gz \
    https://caml.inria.fr/pub/distrib/ocaml-3.11/ocaml-3.11.0.tar.gz \
    https://xenbits.xensource.com/xen-extfiles/gc.tar.gz \
    https://sourceforge.net/projects/tpm-emulator.berlios/files/tpm_emulator-0.7.4.tar.gz \
    https://ftp.gnu.org/gnu/gmp/gmp-4.3.2.tar.bz2.sig \
    $(DISTFILES_MIRROR)/polarssl-1.1.4-gpl.tgz \
    https://xenbits.xensource.com/xen-extfiles/tboot-20090330.tar.gz

ALL_FILES := $(notdir $(URLS:%.sig=%)) $(notdir $(filter %.sig, $(URLS)))
ALL_URLS := $(URLS:%.sig=%) $(filter %.sig, $(URLS))

ifneq ($(DISTFILES_MIRROR),)
ALL_URLS := $(addprefix $(DISTFILES_MIRROR),$(ALL_FILES))
endif

get-sources: $(ALL_FILES)
	git submodule update --init --recursive

keyring := vmm-xen-trustedkeys.gpg
keyring-file := $(if $(GNUPGHOME), $(GNUPGHOME)/, $(HOME)/.gnupg/)$(keyring)
keyring-import := gpg -q --no-auto-check-trustdb --no-default-keyring --import

$(keyring-file): $(wildcard *.asc)
	@rm -f $(keyring-file) && $(keyring-import) --keyring $(keyring) $^

# get-sources already handle verification and remove the file(s) when it fails.
# Keep verify-sources target present for compatibility with qubes-builder API.
verify-sources:
	@true

$(filter %.sig, $(ALL_FILES)): %:
	@$(FETCH_CMD) $@ $(filter %$@,$(ALL_URLS))

%: %.sig $(keyring-file)
	@$(FETCH_CMD) $@$(UNTRUSTED_SUFF) $(filter %$@,$(ALL_URLS))
	@gpgv --keyring vmm-xen-trustedkeys.gpg $< $@$(UNTRUSTED_SUFF) 2>/dev/null || \
		{ echo "Wrong signature on $@$(UNTRUSTED_SUFF)!"; exit 1; }
	@mv $@$(UNTRUSTED_SUFF) $@

%: %.sha256
	@$(FETCH_CMD) $@$(UNTRUSTED_SUFF) $(filter %$@,$(ALL_URLS))
	@sha256sum --status -c <(printf "$$(cat $<)  -\n") <$@$(UNTRUSTED_SUFF) || \
		{ echo "Wrong SHA256 checksum on $@$(UNTRUSTED_SUFF)!"; exit 1; }
	@mv $@$(UNTRUSTED_SUFF) $@

.PHONY: clean-sources
clean-sources:
	rm -f $(ALL_FILES) *$(UNTRUSTED_SUFF)

help:
	@echo "Usage: make <target>"
	@echo
	@echo "get-sources      Download kernel sources from kernel.org"
	@echo "verify-sources"
