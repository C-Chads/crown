/*
 * Copyright (c) 2012-2023 Daniele Bartolini et al.
 * SPDX-License-Identifier: MIT
 */

#include "core/error/error.inl"
#include "core/platform.h"
#include "core/thread/condition_variable.h"
#include "core/thread/mutex.h"
#include <new>

#if CROWN_PLATFORM_WINDOWS
	#ifndef WIN32_LEAN_AND_MEAN
		#define WIN32_LEAN_AND_MEAN
	#endif
	#include <windows.h>
#else
	#include <pthread.h>
#endif

namespace crown
{
struct Private
{
#if CROWN_PLATFORM_WINDOWS
	CONDITION_VARIABLE cv;
#else
	pthread_cond_t cond;
#endif
};

ConditionVariable::ConditionVariable()
{
	CE_STATIC_ASSERT(sizeof(_data) >= sizeof(*_priv));
	_priv = new (_data) Private();

#if CROWN_PLATFORM_WINDOWS
	InitializeConditionVariable(&_priv->cv);
#else
	int err = pthread_cond_init(&_priv->cond, NULL);
	CE_ASSERT(err == 0, "pthread_cond_init: errno = %d", err);
	CE_UNUSED(err);
#endif
}

ConditionVariable::~ConditionVariable()
{
#if CROWN_PLATFORM_WINDOWS
	// Do nothing
#else
	int err = pthread_cond_destroy(&_priv->cond);
	CE_ASSERT(err == 0, "pthread_cond_destroy: errno = %d", err);
	CE_UNUSED(err);
#endif
	_priv->~Private();
}

void ConditionVariable::wait(Mutex &mutex)
{
#if CROWN_PLATFORM_WINDOWS
	SleepConditionVariableCS(&_priv->cv, (CRITICAL_SECTION *)mutex.native_handle(), INFINITE);
#else
	int err = pthread_cond_wait(&_priv->cond, (pthread_mutex_t *)mutex.native_handle());
	CE_ASSERT(err == 0, "pthread_cond_wait: errno = %d", err);
	CE_UNUSED(err);
#endif
}

void ConditionVariable::signal()
{
#if CROWN_PLATFORM_WINDOWS
	WakeConditionVariable(&_priv->cv);
#else
	int err = pthread_cond_signal(&_priv->cond);
	CE_ASSERT(err == 0, "pthread_cond_signal: errno = %d", err);
	CE_UNUSED(err);
#endif
}

} // namespace crown
