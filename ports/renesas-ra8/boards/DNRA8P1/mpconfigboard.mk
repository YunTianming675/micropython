# DNRA8P1 board configuration for MicroPython

# MCU identification
CMSIS_MCU = RA8P1
MCU_SERIES_CPU0 = m85
MCU_SERIES_CPU1 = m33

# e2studio/FSP project
FSP_IS_DUAL_CORE_PROJECT = true
FSP_PROJECT_DIR = boards/DNRA8P1/gcc_freertos
FSP_PROJECT_DIR_CPU0 = boards/DNRA8P1/gcc_freertos/_CPU0
FSP_PROJECT_DIR_CPU1 = boards/DNRA8P1/gcc_freertos/_CPU1
FSP_LD_SCRIPT = boards/DNRA8P1/gcc_freertos/_CPU0/script/fsp.ld
FSP_LD_SCRIPT_CPU0 = boards/DNRA8P1/gcc_freertos/_CPU0/script/fsp.ld
FSP_LD_SCRIPT_CPU1 = boards/DNRA8P1/gcc_freertos/_CPU1/script/fsp.ld