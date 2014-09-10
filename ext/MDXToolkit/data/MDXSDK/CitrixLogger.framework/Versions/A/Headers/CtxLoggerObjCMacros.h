//
//  CtxLoggerObjCMacros.h
//  Citrix Logger Framework
//
//  Created by Aakash M D on 29/07/13.
//  Copyright (c) 2013 Citrix Systems, Inc. All rights reserved.
//

/*
 * This file contains all the macro definitions required for 
 * logging Objective C-style message
 *
 */

#import "CtxLogManager.h"
#import "CtxLoggerConstants.h"

#pragma mark - Activity logging
//
// Standard application activity logging functions
//
#define CTXLOG_CriticalError(source,fmt,...) \
CTXLOG_logMessage(source, CTXLOG_MSG_CRITICAL, CTXLOG_LOG_TYPE_ACTIVITY, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#define CTXLOG_Error(source,fmt,...) \
CTXLOG_logMessage(source, CTXLOG_MSG_ERROR, CTXLOG_LOG_TYPE_ACTIVITY, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#define CTXLOG_Warn(source,fmt,...) \
CTXLOG_logMessage(source, CTXLOG_MSG_WARNING, CTXLOG_LOG_TYPE_ACTIVITY, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#define CTXLOG_Info(source,fmt,...) \
CTXLOG_logMessage(source, CTXLOG_MSG_INFO, CTXLOG_LOG_TYPE_ACTIVITY, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#define CTXLOG_Detail(source,fmt,...) \
CTXLOG_logMessage(source, CTXLOG_MSG_DETAIL, CTXLOG_LOG_TYPE_ACTIVITY, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#pragma mark - Diagnostic logging
//
// Diagnostic tracing functions
//   - requires CTXLOG_DEFAULT_MODULE to be defined (trace module/component name) in compiler flags
//
#define CTXLOG_Diag(level,fmt,...) \
CTXLOG_logMessage(CTXLOG_DEFAULT_MODULE, level, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

// Diagnostic tracing variants
#define CTXLOG_Diag1(fmt,...) \
CTXLOG_logMessage(CTXLOG_DEFAULT_MODULE, CTXLOG_LVL_DEBUG1, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag2(fmt,...) \
CTXLOG_logMessage(CTXLOG_DEFAULT_MODULE, CTXLOG_LVL_DEBUG2, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag3(fmt,...) \
CTXLOG_logMessage(CTXLOG_DEFAULT_MODULE, CTXLOG_LVL_DEBUG3, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag4(fmt,...) \
CTXLOG_logMessage(CTXLOG_DEFAULT_MODULE, CTXLOG_LVL_DEBUG4, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag5(fmt,...) \
CTXLOG_logMessage(CTXLOG_DEFAULT_MODULE, CTXLOG_LVL_DEBUG5, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag6(fmt,...) \
CTXLOG_logMessage(CTXLOG_DEFAULT_MODULE, CTXLOG_LVL_DEBUG6, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag7(fmt,...) \
CTXLOG_logMessage(CTXLOG_DEFAULT_MODULE, CTXLOG_LVL_DEBUG7, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag8(fmt,...) \
CTXLOG_logMessage(CTXLOG_DEFAULT_MODULE, CTXLOG_LVL_DEBUG8, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag9(fmt,...) \
CTXLOG_logMessage(CTXLOG_DEFAULT_MODULE, CTXLOG_LVL_DEBUG9, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag10(fmt,...) \
CTXLOG_logMessage(CTXLOG_DEFAULT_MODULE, CTXLOG_LVL_DEBUG10, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);


//
// Diag log variant where trace module/component is defined explicitly inline
//
// NOTE: We should prefer to use variants above since it makes code less verbose and more portable
//
#define CTXLOG_Diag_ForModule(module, level, fmt, ...) \
CTXLOG_logMessage(module, level, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#pragma mark - Secure logging

#if defined(DEBUG) || defined(_DEBUG) || defined(ENABLE_CTXLOG_Secure)

// Diagnostic logging of potentially sensitive info.  Same as CTXLOG_Diag(),
// but only enabled if DEBUG, _DEBUG, or ENABLE_CTXLOG_Secure is defined
#define CTXLOG_Secure(level,fmt,...) \
CTXLOG_logMessage(CTXLOG_DEFAULT_MODULE, level, CTXLOG_LOG_TYPE_SECURE, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

// Secure log variants where trace module/component is defined explicitly inline
#define CTXLOG_Secure_ForModule(module, level, fmt,...) \
CTXLOG_logMessage(module, level, CTXLOG_LOG_TYPE_SECURE, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#else

#define CTXLOG_Secure(level,fmt,...)
#define CTXLOG_Secure_ForModule(module, level, fmt,...)

#endif

#pragma mark - Performance logging
//
// Performance event logging
//
// module   - Module name
// level    - Logging level

// name     - Event name
// type     - Event type (start, stop, timestamp)
// context  - Context or transaction ID (64 bit int/address)
// fmt, ... - Printf style message payload
//
#define CTXLOG_PerfLogInit(level) \
CtxPerfLoggerInitializeWithLevel(level)

#define CTXLOG_PerfEvent(module,level,name,type,context) \
CTXLOG_logPerfEvent(module, level, name, type, context, __FILE__, __FUNCTION__, __LINE__)

#define CTXLOG_PerfEventWithMsg(module, level, name, type, context, fmt, ...) \
CTXLOG_logPerfEventWithMsg(module, level, name, type, context, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__)
