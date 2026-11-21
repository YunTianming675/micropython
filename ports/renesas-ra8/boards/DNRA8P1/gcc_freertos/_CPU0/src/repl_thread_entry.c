#include "console.h"
#include "repl_thread.h"

void repl_thread_entry(void *pvParameters)
{
	FSP_PARAMETER_NOT_USED(pvParameters);

	CONSOLE_Init();

	while (1) {
		vTaskDelay(1);
	}
}
