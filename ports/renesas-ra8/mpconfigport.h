/**
 * @file    mpconfigport.h
 * @brief   MicroPython port renesas-ra8 configuration files
 * @note	All configurations are wrapped with conditional compilation macros.
 * 			The preferred configuration file location is mpconfigboard.h
 * 			Sort macro in alphabetical order, unless they have strong relevance or are part of a secondary configuration.
 */
#ifndef __MPCONFIGPORT_H
#define __MPCONFIGPORT_H

#include "mpconfigboard.h"

#ifndef MP_STATE_PORT
#define MP_STATE_PORT 						MP_STATE_VM
#endif

typedef long mp_off_t;

#endif /* #if __MPCONFIGPORT_H */
