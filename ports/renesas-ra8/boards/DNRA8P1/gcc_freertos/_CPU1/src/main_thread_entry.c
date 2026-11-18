#include "main_thread.h"

void main_thread_entry(void *pvParameters)
{
	FSP_PARAMETER_NOT_USED(pvParameters);

	while (1) {
		vTaskDelay(1);
	}
}
