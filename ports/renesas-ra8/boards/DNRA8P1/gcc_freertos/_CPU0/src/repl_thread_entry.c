#include <stdio.h>

#include "common.h"
#include "console.h"
#include "repl_thread.h"

#include "SEGGER_RTT/SEGGER_RTT.h"
#include "utils/log.h"

static uint8_t s_cpu1_up_buffer[SEGGER_UP_BUFFER_1_SIZE] __attribute__((section(".rtt_share")));

void repl_thread_entry(void *pvParameters)
{
	FSP_PARAMETER_NOT_USED(pvParameters);

	SEGGER_RTT_Init();
	SEGGER_RTT_ConfigUpBuffer(1, "CPU1", s_cpu1_up_buffer, SEGGER_UP_BUFFER_1_SIZE, SEGGER_RTT_MODE_NO_BLOCK_SKIP);
	R_BSP_SecondaryCoreStart();

	CONSOLE_Init();

	puts("\x1b[2J\x1b[H");
    puts("\x1B[0m");
	printf("FSP Version: %s\r\n", FSP_VERSION_STRING);

	while (1) {
		vTaskDelay(1);
	}
}

#if LOG_CFG_EN_TIMESTAMP
void LOG_GetTime(uint32_t *s, uint32_t *ms)
{
	TickType_t tick;

	if (__get_IPSR() == 0) {
		tick = xTaskGetTickCount();
	}
	else {
		tick = xTaskGetTickCountFromISR();
	}

	*s = tick / 1000;
	*ms = tick % 1000;
}
#endif
