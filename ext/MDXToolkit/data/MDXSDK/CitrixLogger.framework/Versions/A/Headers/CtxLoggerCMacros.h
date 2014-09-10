//
//  CtxLoggerCMacros.h
//  Citrix Logger Framework
//
//  Created by Aakash M D on 29/07/13.
//  Copyright (c) 2013 Citrix Systems, Inc. All rights reserved.
//

/*
 * This file contains all the macro definitions required 
 * for logging C-style message
 *
 */

#import "CtxLoggerConstants.h"
#import "CtxLogManager.h"

#pragma mark - Activity logging (C variants)
//
// Standard application activity logging functions - C variants
//
#define CTXLOG_CriticalError_C(source,fmt,...) \
CTXLOG_logMessage_C(source, CTXLOG_MSG_CRITICAL, CTXLOG_LOG_TYPE_ACTIVITY, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#define CTXLOG_Error_C(source,fmt,...) \
CTXLOG_logMessage_C(source, CTXLOG_MSG_ERROR, CTXLOG_LOG_TYPE_ACTIVITY, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#define CTXLOG_Warn_C(source,fmt,...) \
CTXLOG_logMessage_C(source, CTXLOG_MSG_WARNING, CTXLOG_LOG_TYPE_ACTIVITY, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#define CTXLOG_Info_C(source,fmt,...) \
CTXLOG_logMessage_C(source, CTXLOG_MSG_INFO, CTXLOG_LOG_TYPE_ACTIVITY, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#define CTXLOG_Detail_C(source,fmt,...) \
CTXLOG_logMessage_C(source, CTXLOG_MSG_DETAIL, CTXLOG_LOG_TYPE_ACTIVITY, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#pragma mark - Diagnostic logging

//
// Diagnostic tracing functions - C variants
//   - requires CTXLOG_DEFAULT_MODULE_C to be defined (trace module/component name)
//
#define CTXLOG_Diag_C(level,fmt,...) \
CTXLOG_logMessage_C(CTXLOG_DEFAULT_MODULE_C, level, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

//Variants
#define CTXLOG_Diag1_C(fmt,...) \
CTXLOG_logMessage_C(CTXLOG_DEFAULT_MODULE_C, CTXLOG_LVL_DEBUG1, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag2_C(fmt,...) \
CTXLOG_logMessage_C(CTXLOG_DEFAULT_MODULE_C, CTXLOG_LVL_DEBUG2, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag3_C(fmt,...) \
CTXLOG_logMessage_C(CTXLOG_DEFAULT_MODULE_C, CTXLOG_LVL_DEBUG3, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag4_C(fmt,...) \
CTXLOG_logMessage_C(CTXLOG_DEFAULT_MODULE_C, CTXLOG_LVL_DEBUG4, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag5_C(fmt,...) \
CTXLOG_logMessage_C(CTXLOG_DEFAULT_MODULE_C, CTXLOG_LVL_DEBUG5, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag6_C(fmt,...) \
CTXLOG_logMessage_C(CTXLOG_DEFAULT_MODULE_C, CTXLOG_LVL_DEBUG6, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag7_C(fmt,...) \
CTXLOG_logMessage_C(CTXLOG_DEFAULT_MODULE_C, CTXLOG_LVL_DEBUG7, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag8_C(fmt,...) \
CTXLOG_logMessage_C(CTXLOG_DEFAULT_MODULE_C, CTXLOG_LVL_DEBUG8, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag9_C(fmt,...) \
CTXLOG_logMessage_C(CTXLOG_DEFAULT_MODULE_C, CTXLOG_LVL_DEBUG9, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define CTXLOG_Diag10_C(fmt,...) \
CTXLOG_logMessage_C(CTXLOG_DEFAULT_MODULE_C, CTXLOG_LVL_DEBUG10, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

// Diag log variants where trace module/component is defined explicitly inline - C variants
#define CTXLOG_Diag_ForModule_C(module,level,fmt,...) \
CTXLOG_logMessage_C(module, level, CTXLOG_LOG_TYPE_DIAGNOSTIC, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#pragma mark - Secure logging

#if defined(DEBUG) || defined(_DEBUG) || defined(ENABLE_CTXLOG_Secure)

//
// Diagnostic logging of potentially sensitive info.  Same as CTXLOG_Diag(),
// but only enabled if DEBUG, _DEBUG, or ENABLE_CTXLOG_Secure is defined.
// C variants
//
#define CTXLOG_Secure_C(level,fmt,...) \
CTXLOG_logMessage_C(CTXLOG_DEFAULT_MODULE_C, level, CTXLOG_LOG_TYPE_SECURE, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

//
// Secure log variants where trace module/component is defined explicitly inline.
// C variants
//
#define CTXLOG_Secure_ForModule_C(module,level,fmt,...) \
CTXLOG_logMessage_C(module, level, CTXLOG_LOG_TYPE_SECURE, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

#else

#define CTXLOG_Secure_C(level,fmt,...)
#define CTXLOG_Secure_ForModule_C(module,level,fmt,...)

#endif

#pragma mark - Performance logging (C variants)
//
// Performance event logging - C variants
//
// module   - Module name
// level    - Logging level

// name     - Event name
// type     - Event type (start, stop, timestamp)
// context  - Context or transaction ID (64 bit int/address)
// fmt, ... - Printf style message payload
//
#define CTXLOG_PerfEvent_C(module,level,name,type,context) \
CTXLOG_logPerfEvent_C(module, level, name, type, context, __FILE__, __FUNCTION__, __LINE__)

#define CTXLOG_PerfEventWithMsg_C(module,level,name,type,context,fmt,...) \
CTXLOG_logPerfEventWithMsg_C(module, level, name, type, context, __FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__)
