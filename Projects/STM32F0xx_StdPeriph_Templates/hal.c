#include "stm32f0xx.h"
#include "hal.h"

#define  TICK_INT_PRIORITY            ((uint32_t)0)    /*!< tick interrupt priority (lowest by default)  */

__IO uint32_t g_uwTick;
static uint32_t g_us_multiplier;

void HAL_Init(void)
{
  g_uwTick = 0;
  g_us_multiplier = SystemCoreClock / 1000000;

  SysTick_Config(SystemCoreClock / 1000);

   /* SysTick_IRQn interrupt configuration */
  NVIC_SetPriority(SysTick_IRQn, TICK_INT_PRIORITY);
}

void HAL_IncTick(void)
{
  g_uwTick++;
}

void HAL_SuspendTick(void)
{
  /* Disable SysTick Interrupt */
  SysTick->CTRL &= ~SysTick_CTRL_TICKINT_Msk;
}

void HAL_ResumeTick(void)
{
  /* Enable SysTick Interrupt */
  SysTick->CTRL |= SysTick_CTRL_TICKINT_Msk;
}

uint32_t HAL_GetTick(void)
{
  return g_uwTick;
}

void delay_ms(uint32_t ms)
{
  uint32_t tickstart = 0;

  if (ms < 11) 
  {
    delay_us(ms * 1000 - 1);
    return;
  }
  else
  {
    tickstart = HAL_GetTick();
    while((HAL_GetTick() - tickstart) < ms);
  }
}

void delay_us(uint16_t us)
{
  register uint32_t r0 __asm("r0");
  uint32_t micros = 0;
 
  if (us < 2) return;

  micros = (us - 1) * g_us_multiplier / 4; // 4 cycles per loop

#pragma push
#pragma O0
  while (micros-- > 0);
#pragma pop
}

void soft_timer_init(SoftTimer *p_timer)
{
  p_timer->msTicks = HAL_GetTick();
  p_timer->syst_val = SysTick->VAL;
}

uint32_t soft_timer_us_elapse(SoftTimer *p_timer)
{
  uint32_t curr_msTicks = HAL_GetTick();
  uint32_t curr_val = SysTick->VAL;

  return (curr_msTicks - p_timer->msTicks) * 1000 + (p_timer->syst_val - curr_val) / g_us_multiplier;
}

uint32_t soft_timer_ms_elapse(SoftTimer *p_timer)
{
  return (HAL_GetTick() - p_timer->msTicks);
}

int32_t soft_timer_diff(SoftTimer *p_tm1, SoftTimer *p_tm2)
{
  return (p_tm1->msTicks - p_tm2->msTicks) * 1000 + (p_tm2->syst_val - p_tm1->syst_val) / g_us_multiplier;
}
