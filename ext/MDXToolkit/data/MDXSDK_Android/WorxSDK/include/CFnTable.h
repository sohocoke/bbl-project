#ifndef __LOGGER_SDK_FUNCTIONS__
#define __LOGGER_SDK_FUNCTIONS__

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

#include <stdio.h>
#include <android/log.h>

#ifndef CTXLOG_DEFAULT_MODULE
#define  CTXLOG_DEFAULT_MODULE    "CITRIX_CTXLOG"
#endif //CTXLOG_DEFAULT_MODULE


	enum LoggingType 
	{
		CTXLOG_TARGET_FILE    =   1,
		CTXLOG_TARGET_CONSOLE =  (1 << 1),
		CTXLOG_TARGET_REMOTE_NET   = (1 << 2),
		CTXLOG_TARGET_REMOTE_SYSLOG   = (1 << 3)
	};

	enum CtxLevel 
	{
		CTXLOG_MSG_NOTHING = 0,
		/** Log level for critical errors/events */
		CTXLOG_MSG_CRITICAL,
		/** Log level for errors */
		CTXLOG_MSG_ERROR,
		/** Log level for warnings */
		CTXLOG_MSG_WARNING,
		/** Log level for informative statements, also the default logging level */
		CTXLOG_MSG_INFO,
		/** Log level for detailed tracing */
		CTXLOG_MSG_DETAIL,
		/** base diagnostic logging level */
		CTXLOG_LVL_DEBUG1,
		CTXLOG_LVL_DEBUG2,
		CTXLOG_LVL_DEBUG3,
		CTXLOG_LVL_DEBUG4,
		CTXLOG_LVL_DEBUG5,
		CTXLOG_LVL_DEBUG6,
		CTXLOG_LVL_DEBUG7,
		CTXLOG_LVL_DEBUG8,
		CTXLOG_LVL_DEBUG9,
		CTXLOG_LVL_DEBUG10
	};

#define false 0
#define true 1
#define PERF_EVENT_TYPE_START "Start"
#define PERF_EVENT_TYPE_STOP "Stop"
#define PERF_EVENT_TYPE_TIMESTAMP "Timestamp"
	typedef  int BOOL;

	typedef int  (*initialize)(const char* packageName, const char *logDir);
	typedef void  (*enable)(BOOL value);
	typedef void  (*setLevel) (unsigned int value);
	typedef void  (*setAttribute) (const char* key,const char* value);
	typedef void  (*setTargets)(int value);
	typedef void  (*setMaxFileSize)(int value);
	typedef void  (*setMaxFileCount)(int value);
	typedef void  (*setLogPattern) (const char* pattern);
	typedef const char*  (*getLogPattern) (void);

	typedef BOOL  (*isEnabled) ();
	typedef const char* (*getLoggingDir)();
	typedef unsigned int   (*getLevel)();
	typedef int   (*getTargets)();
	typedef int   (*getMaxFileSize)();
	typedef int   (*getMaxFileCount)();
	typedef void (*perfEventWithMsg)(const  char* csource,int lvl,const char* name,const char* type,int context, const char* msg, const char* file, const char* func, int line);
	typedef void (*logMessage)(const  char* csource,int lvl,const char* file,const char* func,int line, const char* fmt, ...);
	typedef void (*logMessage2) (const char* csource, int level,const char* msg);
	typedef void (*perfLoggerInit)(int lvl);
	typedef void (*clearLogs)();
	typedef void (*refreshFileLogger)();

	typedef struct  LogSDKFunctions
	{
		initialize Ptr_initialize;
		enable	   Ptr_enable;
		setLevel   Ptr_setLevel;
		setAttribute   Ptr_setAttribute;
		setTargets Ptr_setTargets;
		setMaxFileSize Ptr_setMaxFileSize;
		setMaxFileCount Ptr_setMaxFileCount;
		isEnabled Ptr_isEnabled;
		getLoggingDir Ptr_getLoggingDir;
		getLevel Ptr_getLevel;
		getTargets Ptr_getTargets;
		getMaxFileSize Ptr_getMaxFileSize;
		getMaxFileCount Ptr_getMaxFileCount;
		perfEventWithMsg Ptr_perfEventWithMsg;
		perfLoggerInit Ptr_perfLoggerInit;
		logMessage Ptr_logMessage;
		logMessage2 Ptr_logMessage2;
		clearLogs  Ptr_clearLogs;
		refreshFileLogger Ptr_refreshFileLogger;
		setLogPattern Ptr_setLogPattern;
		getLogPattern Ptr_getLogPattern;

	} LogSDKFunctions;

#ifdef __cplusplus
}
#endif //__cplusplus

#endif //__LOGGER_SDK_FUNCTIONS__
