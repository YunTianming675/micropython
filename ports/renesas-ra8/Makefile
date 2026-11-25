# Before include mkenv.mk, we need set CROSS_COMPILE
# We recommend using GCC that comes with e2studio installation. Or just don't want to set arm-none-eabi-gcc to your system path. So you can set variable via:
# 	1. Command line: make BOARD=... FSP_GCC=/path/to/gcc
#	2. Environment:
#		Linux  : export FSP_GCC=/path/to/gcc
#		Windows: $env:FSP_GCC=/path/to/gcc
#	3. local.mk: create a file named local.mk and place in this folder, then set FSP_GCC?=/path/to/gcc
# If you didn't set this variable, will use default arm-none-eabi-gcc
-include local.mk

ifeq ($(FSP_GCC),)
CROSS_COMPILE = arm-none-eabi-
else
CROSS_COMPILE = $(FSP_GCC)/bin/arm-none-eabi-
endif

include ../../py/mkenv.mk

# ---------- Board selection ----------
# Before include board specific build settings, we need comfirm which board will be build
BOARD ?= DNRA8P1
BOARD_DIR = boards/$(BOARD)
include $(BOARD_DIR)/mpconfigboard.mk

ifeq ($(FSP_IS_DUAL_CORE_PROJECT),true)
BUILD = build-$(BOARD)_CPU0
else
BUILD = build-$(BOARD)
endif

# This makefile only make CPU0 project if it's dual core project, because only CPU0 running MicroPython
ifeq ($(FSP_IS_DUAL_CORE_PROJECT),true)
__FSP_PROJECT_DIR = $(FSP_PROJECT_DIR_CPU0)
__FSP_LD_SCRIPT = $(FSP_LD_SCRIPT_CPU0)
else
__FSP_PROJECT_DIR = $(FSP_PROJECT_DIR)
__FSP_LD_SCRIPT = $(FSP_LD_SCRIPT)
endif

# qstr definitions, we decide let it depends on each board, rather than this port
# QSTR_DEFS = $(__FSP_PROJECT_DIR)/src/qstrdefsport.h

# Enable the core definitions when integrating MicroPython.
# include $(TOP)/py/py.mk

# ---------- Source files ----------
FSP_SRC_DIRS := $(__FSP_PROJECT_DIR)/ra $(__FSP_PROJECT_DIR)/ra_cfg $(__FSP_PROJECT_DIR)/ra_gen $(__FSP_PROJECT_DIR)/src

ifeq ($(OS),Windows_NT)
__COMMA := ,
__EMPTY :=
__SPACE := $(__EMPTY) $(__EMPTY)
__FSP_SRC_DIRS := $(subst $(__SPACE),$(__COMMA),$(FSP_SRC_DIRS))
FSP_SRC_C := $(shell powershell -NoProfile -Command "Get-ChildItem -Path $(__FSP_SRC_DIRS) -Recurse -Filter *.c -ErrorAction SilentlyContinue | Resolve-Path -Relative | ForEach-Object { \$$_ -replace '^\\.\\\\' -replace '\\\\','/' }")
else
FSP_SRC_C := $(shell find $(FSP_SRC_DIRS) -type f -name '*.c' 2>/dev/null)
endif

SRC_C := $(FSP_SRC_C)
SRC_C += $(BOARD_DIR)/share/console.c
# drivers source files

# MicroPython source files

# ---------- Include paths ----------
INC += -I$(TOP)
INC += -I$(BUILD)
INC += -I$(BOARD_DIR)/share
INC += -I$(__FSP_PROJECT_DIR)/Debug
INC += -I$(__FSP_PROJECT_DIR)/ra/arm/CMSIS_6/CMSIS/Core/Include
INC += -I$(__FSP_PROJECT_DIR)/ra/aws/FreeRTOS/FreeRTOS/Source/include
INC += -I$(__FSP_PROJECT_DIR)/ra_cfg/aws
INC += -I$(__FSP_PROJECT_DIR)/ra_cfg/driver
INC += -I$(__FSP_PROJECT_DIR)/ra_cfg/fsp_cfg
INC += -I$(__FSP_PROJECT_DIR)/ra_cfg/fsp_cfg/bsp
INC += -I$(__FSP_PROJECT_DIR)/ra/fsp/inc
INC += -I$(__FSP_PROJECT_DIR)/ra/fsp/inc/api
INC += -I$(__FSP_PROJECT_DIR)/ra/fsp/inc/instances
INC += -I$(__FSP_PROJECT_DIR)/ra/fsp/src/bsp/cmsis/Device/RENESAS/Include
INC += -I$(__FSP_PROJECT_DIR)/ra/fsp/src/bsp/mcu/all
INC += -I$(__FSP_PROJECT_DIR)/ra/fsp/src/bsp/mcu/ra8p1
INC += -I$(__FSP_PROJECT_DIR)/ra/fsp/src/rm_freertos_port
INC += -I$(__FSP_PROJECT_DIR)/ra_gen
INC += -I$(__FSP_PROJECT_DIR)/src

# ---------- Compiler flags ----------
CFLAGS += -std=gnu99
CFLAGS += -fdata-sections
CFLAGS += -ffunction-sections
CFLAGS += -flax-vector-conversions
CFLAGS += -fmessage-length=0
CFLAGS += -fno-strict-aliasing
CFLAGS += -fsigned-char
CFLAGS += --param=min-pagesize=0

# Special flags depends on platform
ifeq ($(MCU_SERIES_CPU0),m85)
CFLAGS += -mthumb -mfloat-abi=hard -mcpu=cortex-m85+nopacbti
endif

# Warning flags
CFLAGS += -Wall
CFLAGS += -Wdouble-promotion
CFLAGS += -Wfloat-conversion
CFLAGS += -Wno-double-promotion
CFLAGS += -Wno-format-truncation
CFLAGS += -Wno-stringop-overflow

# Macro
CFLAGS += -D_RA_CORE=CPU0
CFLAGS += -D_RA_ORDINAL=1
CFLAGS += -D_RENESAS_RA_
CFLAGS += -DCONSOLE_CFG_USE_UART=1

# Optimization
CFLAGS += -O2 -DNDEBUG
CFLAGS += -g

# Last, plus include path
CFLAGS += $(INC)

# ---------- Linker flags ----------
ifeq ($(MCU_SERIES_CPU0),m85)
LDFLAGS += -mthumb -mfloat-abi=hard -mcpu=cortex-m85+nopacbti
endif

LD_SEARCH_DIRS = $(sort $(__FSP_PROJECT_DIR)/Debug $(__FSP_PROJECT_DIR)/script)
LDFLAGS += $(addprefix -L,$(LD_SEARCH_DIRS))
LDFLAGS += -T $(__FSP_LD_SCRIPT)
LDFLAGS += -Wl,-Map=$@.map -Wl,--cref -Wl,--gc-sections
LDFLAGS += --specs=nano.specs

# ---------- Object files ----------
PORT_OBJ = $(addprefix $(BUILD)/, $(SRC_C:.c=.o))
# OBJ = $(PY_CORE_O)
OBJ += $(PORT_OBJ)
# OBJ += $(addprefix $(BUILD)/, $(SRC_O))

# Suppress warnings for the FreeRTOS kernel and its Renesas port.
THIRT_SRC_C = $(filter $(__FSP_PROJECT_DIR)/ra/aws/FreeRTOS/% $(__FSP_PROJECT_DIR)/ra/fsp/src/rm_freertos_port/%,$(SRC_C))
THIRT_OBJ = $(addprefix $(BUILD)/,$(THIRT_SRC_C:.c=.o))
$(THIRT_OBJ): CFLAGS += -w

$(BUILD)/%.o: %.c Makefile $(BOARD_DIR)/mpconfigboard.mk $(wildcard local.mk)
	$(ECHO) "CC $<"
	$(Q)$(MKDIR) -p "$(@D)"
	$(Q)$(CC) $(CFLAGS) -MMD -MP -c "$<" -o "$@"

-include $(OBJ:.o=.d)

# ---------- Firmware targets ----------

all: $(BUILD)/firmware.elf $(BUILD)/firmware.hex $(BUILD)/firmware.bin

FSP_LD_INPUTS := $(__FSP_LD_SCRIPT) $(addprefix $(__FSP_PROJECT_DIR)/Debug/,memory_regions.ld fsp_gen.ld)
$(BUILD)/firmware.elf: $(OBJ) $(FSP_LD_INPUTS)
	$(ECHO) "LINK $@"
	$(file >$@.in,$(LDFLAGS) -o $@ $(OBJ) $(LIBS))
	$(Q)$(CC) @"$@.in"
	$(Q)$(SIZE) $@

# Binary and hex outputs
$(BUILD)/firmware.bin: $(BUILD)/firmware.elf
	$(Q)$(OBJCOPY) -O binary $^ $@

$(BUILD)/firmware.hex: $(BUILD)/firmware.elf
	$(Q)$(OBJCOPY) -O ihex $^ $@

.PHONY: hex
hex: $(BUILD)/firmware.hex
