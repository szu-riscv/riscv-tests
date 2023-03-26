SV ?= Sv39

MAKEFLAGS += -j
ARCH = riscv64

define compile_lab

ALL += $$($(1)_sc_tests)

ifdef $(1)_p_tests
Makefiles_$(1)_p = $(addprefix Makefile-$(1)-p-, $($(1)_sc_tests))
endif

ifdef $(1)_v_tests
Makefiles_$(1)_v = $(addprefix Makefile-$(1)-v-, $($(1)_sc_tests))
endif

$$(Makefiles_$(1)_p): Makefile-$(1)-p-%: $(1)/%.S
	@/bin/echo -e "NAME = $(1)-$$*-p\nSRCs = $$<\nEXTRA=p\nLIBs += libc\nCOMMON_FLAGS += -DRVTEST_LAB\nINC_FLAGS += -I$(shell pwd)/../env/p -I$(shell pwd)/macros/scalar\ninclude $${TESTS_HOME}/scripts/app.mk" > $$@
	-@make -s -f $$@ ARCH=$$(ARCH)
	-@rm -f Makefile-$(1)-p-$$* 

$$(Makefiles_$(1)_v): Makefile-$(1)-v-%: $(1)/%.S
	@/bin/echo -e "NAME = $(1)-$$*-v\nSRCs = $$< $(src_dir)/../env/v/entry.S $(src_dir)/../env/v/vm.c $(src_dir)/../env/v/string.c\nEXTRA=v\nLIBs += libc\nINC_FLAGS += -I$(shell pwd)/../env/v \
		-I$(shell pwd)/macros/scalar\nCOMMON_FLAGS += -DRVTEST_LAB -D$(SV) -DENTROPY=0x$$(shell echo \$$@ | md5sum | cut -c 1-7)\ninclude $${TESTS_HOME}/scripts/app.mk" > $$@
	-@make -s -f $$@ ARCH=$$(ARCH)
	-@rm -f Makefile-$(1)-v-$$* 

MakeTargets += $$(Makefiles_$(1)_p) $$(Makefiles_$(1)_v)

endef

Dirs = rv32ui rv32uc rv32um rv32ua rv32uf rv32ud rv32uzfh rv32si rv32mi rv64ui rv64uc rv64um rv64ua rv64uf rv64ud rv64uzfh rv64si rv64ssvnapot rv64mi rv64mzicbo
dir ?= rv64ui

ifeq ($(findstring $(dir), $(Dirs)), "")
$(error Invalid dir, please set correct value such as $(Dirs))
endif

# excute the compile on lab-test
$(eval $(call compile_lab,$(dir)))

lab: $(MakeTargets)
	@echo "Compile programs such as:" $(ALL)

default: lab ;

# clean:
# 	rm -rf Makefile-rv* build/

.PHONY: lab clean $(ALL)