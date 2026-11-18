#include "repl_thread.h"

void repl_thread_entry(void *pvParameters)
{
	FSP_PARAMETER_NOT_USED(pvParameters);

	while (1) {
		vTaskDelay(1);
	}
}
