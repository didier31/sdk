// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef BIN_THREAD_POOL_MACOS_H_
#define BIN_THREAD_POOL_MACOS_H_

#include <pthread.h>

#include "platform/globals.h"


class ThreadPoolData {
 private:
  ThreadPoolData() {}
  ~ThreadPoolData() {}

  pthread_t* threads() { return threads_; }
  void set_threads(pthread_t* threads) { threads_ = threads; }

  pthread_t* threads_;

  friend class ThreadPool;

  DISALLOW_ALLOCATION();
  DISALLOW_COPY_AND_ASSIGN(ThreadPoolData);
};

#endif  // BIN_THREAD_POOL_MACOS_H_
