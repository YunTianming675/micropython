#include <stdio.h>

#include "console.h"
#include "main_thread.h"

#include "SEGGER_RTT/SEGGER_RTT.h"
#include "utils/log.h"

void main_thread_entry(void *pvParameters)
{
	FSP_PARAMETER_NOT_USED(pvParameters);

	LOG_Reset();
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
