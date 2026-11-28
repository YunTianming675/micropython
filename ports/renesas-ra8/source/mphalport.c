#include "mphalport.h"

int g_mp_interrupt_char = -1;

void mp_hal_set_interrupt_char(char c)
{
	g_mp_interrupt_char = c;
}
