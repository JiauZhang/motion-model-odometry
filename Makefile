NAME = FiBot
VERSION = 0
PATCHLEVEL = 1
EXTRAVERSION = -rc1

srctree := $(CURDIR)
objtree := $(CURDIR)

export srctree objtree

# Beautify output
include $(srctree)/kmake/Kmake.basic

# That's our default target when none is given on the command line
PHONY := _all
_all:

# Cancel implicit rules on top Makefile
$(CURDIR)/Makefile Makefile: ;

ARCH = arm
CPU = cortex-m3
BOARD = bluepill
CROSS_COMPILE = arm-none-eabi-

export ARCH CPU BOARD CROSS_COMPILE

include $(srctree)/kmake/Kbuild.include
include $(srctree)/kmake/subarch.include

# configure compile tools and flags
CROSS_COMPILE := arm-none-eabi-
include $(srctree)/kmake/Kmake.compiler
NOSTDINC_FLAGS :=

KBUILD_AFLAGS := -mcpu=$(CPU) -mthumb -c
KBUILD_AFLAGS += -Wall -fdata-sections -ffunction-sections

KBUILD_CFLAGS := -mcpu=$(CPU) -mthumb -c
KBUILD_CFLAGS += -Wall -fdata-sections -ffunction-sections
KBUILD_CFLAGS += -DSTM32F103xB -DUSE_HAL_DRIVER
KBUILD_CFLAGS += -Iinclude -Iyard/include -I/yard/drivers/hwcrypto
KBUILD_CFLAGS += -Ilib/HAL_Drivers -Ilib/STM32F1xx_HAL/config
KBUILD_CFLAGS += -Ilib/STM32F1xx_HAL/STM32F1xx_HAL_Driver/Inc -Ilib/STM32F1xx_HAL/STM32F1xx_HAL_Driver/CMSIS/Include
KBUILD_CFLAGS += -Ilib/STM32F1xx_HAL/CMSIS/Device/ST/STM32F1xx/Include

LDSCRIPT = STM32F103C8Tx_FLASH.ld
LIBS = -lc -lm -lnosys 
LIBDIR =
KBUILD_LDFLAGS := -mcpu=$(CPU) -mthumb -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,--gc-sections

PROJECT ?= default
export PROJECT

include projects/Makefile

include $(srctree)/kmake/Kmake.cfg

_all: help

# core-y := init/ common/ projects/$(PROJECT)/ drivers/
# core-y += yard/
libs-y := lib/

# head-y core-y drivers-y libs-y
include $(srctree)/kmake/Kmake.build

FiBot: $(build-objs)
	$(info $(build-objs))
	@echo "  CC      $@"
	$(Q)$(CC) -o $@ $(KBUILD_LDFLAGS) -Wl,--whole-archive $(build-objs) -Wl,--no-whole-archive

rm-files += include/config include/generated \
	.config .config.old kmake-example

# [rm-files] specify the files or generated directories you want to delete
# [clean-dirs] specify the directories you want to clean and
# you can use [clean-files] to specify special files you want to delete in subdir.
include $(srctree)/kmake/Kmake.clean

help:
	@echo "\033[31mStep 1\033[0m: include YOUR projects' Makefile in projects.include"
	@echo "\033[31mStep 2\033[0m: execute \"make [targets]\" to build your projects"

PHONY += help FORCE
FORCE:

# Declare the contents of the .PHONY variable as phony.  We keep that
# information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)