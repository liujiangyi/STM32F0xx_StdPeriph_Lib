/******************************************************************************
 * hal.h
 * Liang Guan Chao <lianggc@gmail.com>
 * 2016/12/20 15:07:05
 *****************************************************************************/

#ifndef _HAL_H
#define _HAL_H

#pragma once

void HAL_Init(void);
void HAL_IncTick(void);
void HAL_SuspendTick(void);
void HAL_ResumeTick(void);
uint32_t HAL_GetTick(void);

void delay_ms(uint32_t ms);
void delay_us(uint16_t us);

typedef struct
{
  uint32_t msTicks;
  uint32_t syst_val;
} SoftTimer;

void soft_timer_init(SoftTimer *p_timer);
uint32_t soft_timer_us_elapse(SoftTimer *p_timer);
uint32_t soft_timer_ms_elapse(SoftTimer *p_timer);
int32_t soft_timer_diff(SoftTimer *p_tm1, SoftTimer *p_tm2);

#endif // _HAL_H

