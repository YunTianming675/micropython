# This file is aim to compler CPU1 project
# It should be invoked by the Makefile instead of being used alone for the build process.

# We need some variables provided by this makefile
include ../../py/mkenv.mk

# It will be called by Makefile, so this variable has been determined.
BOARD_DIR = boards/$(BOARD)

include $(BOARD_DIR)/mpconfigboard.mk

BUILD = build-$(BOARD)/CPU1
FIRMWARE_NAME = firmware_cpu1
__FSP_PROJECT_DIR := $(FSP_PROJECT_DIR_CPU1)
__FSP_LD_SCRIPT := $(FSP_LD_SCRIPT_CPU1)

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

# FSP files
SRC_C := $(FSP_SRC_C)
# share folder files
SRC_C += $(BOARD_DIR)/share/console.c
SRC_C += $(BOARD_DIR)/share/utils/log.c
# third folder files
SRC_C += third/SEGGER_RTT/SEGGER_RTT_printf.c
SRC_C += third/SEGGER_RTT/SEGGER_RTT.c

# ---------- Include paths ----------
INC += -I$(BUILD)
INC += -I$(BOARD_DIR)/share
INC += -Ithird
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
CFLAGS += -fdata-sections
CFLAGS += -ffunction-sections
CFLAGS += -flax-vector-conversions
CFLAGS += -fmessage-length=0
CFLAGS += -fno-strict-aliasing
CFLAGS += -fsigned-char
CFLAGS += -std=gnu99
CFLAGS += --param=min-pagesize=0

ifeq ($(MCU_SERIES_CPU1),m33)
CFLAGS += -mcpu=cortex-m33 -mthumb -mfloat-abi=hard -mfpu=fpv5-sp-d16
endif

# Warning flags
CFLAGS += -Wall
CFLAGS += -Wdouble-promotion
CFLAGS += -Wfloat-conversion
CFLAGS += -Wno-double-promotion
CFLAGS += -Wno-format-truncation
CFLAGS += -Wno-stringop-overflow

# Macro
CFLAGS += -D_RENESAS_RA_
CFLAGS += -D_RA_CORE=CPU1
CFLAGS += -D_RA_ORDINAL=2
CFLAGS += -D_RA_PRIMARY_CORE=CPU0
CFLAGS += -DCONSOLE_CFG_USE_RTT=1
CFLAGS += -DCONSOLE_CFG_RTT_INDEX=1
CFLAGS += -DSEGGER_RTT_BUFFER_SECTION=\".bss.rtt_share\"
CFLAGS += -DSEGGER_RTT_SECTION=\".rtt_control_block\"

# Optimization
CFLAGS += -O2 -DNDEBUG
CFLAGS += -g

# Last, plus include path
CFLAGS += $(INC)

# ---------- Linker flags ----------
LDFLAGS += -mcpu=cortex-m33 -mthumb -mfloat-abi=hard -mfpu=fpv5-sp-d16

LD_SEARCH_DIRS = $(sort $(__FSP_PROJECT_DIR)/Debug $(__FSP_PROJECT_DIR)/script)
LDFLAGS += $(addprefix -L,$(LD_SEARCH_DIRS))
LDFLAGS += -T $(__FSP_LD_SCRIPT)
LDFLAGS += -Wl,-Map=$@.map -Wl,--cref -Wl,--gc-sections
LDFLAGS += --specs=nano.specs

# ---------- Object files ----------
PORT_OBJ = $(addprefix $(BUILD)/, $(SRC_C:.c=.o))
OBJ += $(PORT_OBJ)

# Suppress warnings for the FreeRTOS kernel and its Renesas port.
THIRT_SRC_C = $(filter $(__FSP_PROJECT_DIR)/ra/aws/FreeRTOS/% $(__FSP_PROJECT_DIR)/ra/fsp/src/rm_freertos_port/%,$(SRC_C))
THIRT_OBJ = $(addprefix $(BUILD)/,$(THIRT_SRC_C:.c=.o))
$(THIRT_OBJ): CFLAGS += -w

$(BUILD)/%.o: %.c make_cpu1.mk $(BOARD_DIR)/mpconfigboard.mk
	$(ECHO) "CC $<"
	$(Q)$(MKDIR) -p "$(@D)"
	$(Q)$(CC) $(CFLAGS) -MMD -MP -c "$<" -o "$@"

-include $(OBJ:.o=.d)

# ---------- Firmware targets ----------
all: $(BUILD)/$(FIRMWARE_NAME).elf $(BUILD)/$(FIRMWARE_NAME).hex $(BUILD)/$(FIRMWARE_NAME).bin

FSP_LD_INPUTS := $(__FSP_LD_SCRIPT) $(addprefix $(__FSP_PROJECT_DIR)/Debug/,memory_regions.ld fsp_gen.ld)
$(BUILD)/$(FIRMWARE_NAME).elf: $(OBJ) $(FSP_LD_INPUTS)
	$(ECHO) "LINK $@"
	$(file >$@.in,$(LDFLAGS) -o $@ $(OBJ) $(LIBS))
	$(Q)$(CC) @"$@.in"
	$(Q)$(SIZE) $@

# Binary and hex outputs
$(BUILD)/$(FIRMWARE_NAME).bin: $(BUILD)/$(FIRMWARE_NAME).elf
	$(Q)$(OBJCOPY) -O binary $^ $@

$(BUILD)/$(FIRMWARE_NAME).hex: $(BUILD)/$(FIRMWARE_NAME).elf
	$(Q)$(OBJCOPY) -O ihex $^ $@

.PHONY: hex
hex: $(BUILD)/$(FIRMWARE_NAME).hex
