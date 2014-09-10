#ifndef __CLOGGER_SDK_INCLUDE__
#define __CLOGGER_SDK_INCLUDE__


#include "CFnTable.h"
#ifdef __cplusplus 
extern "C" {
#endif

    extern int CTXLOG_enterLogging();
    extern int CTXLOG_exitLogging();

#ifndef CTXMODULE_NAME
#define CTXMODULE_NAME "CtxModulePlaceHolder"
#endif //CTXMODULE_NAME


extern LogSDKFunctions GetLoggerFnTbl ();


#define  CTXLOG_ClearLogs() \
	GetLoggerFnTbl().Ptr_clearLogs ()

#define  CTXLOG_Debug(source,level,file ,func, line,fmt,...)	\
	GetLoggerFnTbl().Ptr_logMessage (source, level, file, func, line, fmt, ##__VA_ARGS__); 

#define CTXLOG_Critical(source,fmt,...) \
	CTXLOG_Debug(source,CTXLOG_MSG_CRITICAL,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Error(source,fmt,...) \
	CTXLOG_Debug(source,CTXLOG_MSG_ERROR,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Warning(source,fmt,...) \
	CTXLOG_Debug(source,CTXLOG_MSG_WARNING,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Info(source,fmt,...) \
	CTXLOG_Debug(source,CTXLOG_MSG_INFO,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Detail(source,fmt,...) \
	CTXLOG_Debug(source,CTXLOG_MSG_DETAIL,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Debug1(source,fmt,...)	\
	CTXLOG_Debug(source,CTXLOG_LVL_DEBUG1,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Debug2(source,fmt,...)	\
	CTXLOG_Debug(source,CTXLOG_LVL_DEBUG2,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Debug3(source,fmt,...)	\
	CTXLOG_Debug(source,CTXLOG_LVL_DEBUG3,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Debug4(source,fmt,...)	\
	CTXLOG_Debug(source,CTXLOG_LVL_DEBUG4,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Debug5(source,fmt,...)	\
	CTXLOG_Debug(source,CTXLOG_LVL_DEBUG5,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Debug6(source,fmt,...)	\
	CTXLOG_Debug(source,CTXLOG_LVL_DEBUG6,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Debug7(source,fmt,...)	\
	CTXLOG_Debug(source,CTXLOG_LVL_DEBUG7,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Debug8(source,fmt,...)	\
	CTXLOG_Debug(source,CTXLOG_LVL_DEBUG8,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Debug9(source,fmt,...)	\
	CTXLOG_Debug(source,CTXLOG_LVL_DEBUG9,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Debug10(source,fmt,...)	\
	CTXLOG_Debug(source,CTXLOG_LVL_DEBUG10,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)

#define CTXLOG_Jni_Debug(source,level,msg)	\
   	GetLoggerFnTbl().Ptr_logMessage2 (source,level,msg) 

#define CTXLOG_PerfLoggerInit(level)	\
		GetLoggerFnTbl().Ptr_perfLoggerInit (level)

#define CTXLOG_PerfEvent(source, level, name, type, context) \
		GetLoggerFnTbl().Ptr_perfEventWithMsg (source, level, name, type, context,NULL) 
#define CTXLOG_PerfEventWithMsg(source, level, name, type, context,msg) \
		GetLoggerFnTbl().Ptr_perfEventWithMsg (source, level, name, type, context,msg,__FILE__, __FUNCTION__, __LINE__) 

#define CTXLOG_Jni_PerfEvent(source, level, name, type, context) \
		GetLoggerFnTbl().Ptr_perfEventWithMsg (source, level, name, type, context,NULL," ", " ", 0) 
#define CTXLOG_Jni_PerfEventWithMsg(source, level, name, type, context,msg) \
		GetLoggerFnTbl().Ptr_perfEventWithMsg (source, level, name, type, context,msg, " ", " ", 0 ) 

#if defined (_DEBUG) || defined (DEBUG) || defined (ENABLE_CTXLOG_Secure)

#define CTXLOG_Secure(source, level, file, func, line, fmt,...) \
		GetLoggerFnTbl().Ptr_logMessage  (source, level, file, func, line, fmt, ##__VA_ARGS__)
#define CTXLOG_Jni_Secure(source, level, msg) \
		GetLoggerFnTbl().Ptr_logMessage2 (source,level,msg) 
#else

#define CTXLOG_Secure(source, level, file, func, line, fmt,...)
#define CTXLOG_Jni_Secure(source, level, msg)

#endif 


#define CTXLOG_Secure1(source,fmt,...)	\
	CTXLOG_Secure(source,CTXLOG_LVL_DEBUG1,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)
#define CTXLOG_Secure2(source,fmt,...)	\
	CTXLOG_Secure(source,CTXLOG_LVL_DEBUG2,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)
#define CTXLOG_Secure3(source,fmt,...)	\
	CTXLOG_Secure(source,CTXLOG_LVL_DEBUG3,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)
#define CTXLOG_Secure4(source,fmt,...)	\
	CTXLOG_Secure(source,CTXLOG_LVL_DEBUG4,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)
#define CTXLOG_Secure5(source,fmt,...)	\
	CTXLOG_Secure(source,CTXLOG_LVL_DEBUG5,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)
#define CTXLOG_Secure6(source,fmt,...)	\
	CTXLOG_Secure(source,CTXLOG_LVL_DEBUG6,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)
#define CTXLOG_Secure7(source,fmt,...)	\
	CTXLOG_Secure(source,CTXLOG_LVL_DEBUG7,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)
#define CTXLOG_Secure8(source,fmt,...)	\
	CTXLOG_Secure(source,CTXLOG_LVL_DEBUG8,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)
#define CTXLOG_Secure9(source,fmt,...)	\
	CTXLOG_Secure(source,CTXLOG_LVL_DEBUG9,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)
#define CTXLOG_Secure10(source,fmt,...)	\
	CTXLOG_Secure(source,CTXLOG_LVL_DEBUG10,__FILE__,__FUNCTION__,__LINE__,fmt,##__VA_ARGS__)


#define CTXLOG_enable(value)	\
		GetLoggerFnTbl().Ptr_enable(value)

#define CTXLOG_setAttribute(key,value)	\
		GetLoggerFnTbl().Ptr_setAttribute(key,value)

#define CTXLOG_setLevel(value)	\
		CTXLOG_Debug(CTXLOG_DEFAULT_MODULE,CTXLOG_MSG_INFO," ", " ", 0,"New log level :%d", value); \
		GetLoggerFnTbl().Ptr_setLevel(value)

#define CTXLOG_setTargets(value)	\
		CTXLOG_Debug(CTXLOG_DEFAULT_MODULE,CTXLOG_MSG_INFO," ", " ",0 ,"New log targets are :%s, %s, %s, %s", (value & CTXLOG_TARGET_FILE) ? "file" : " ", (value & CTXLOG_TARGET_CONSOLE) ? "console" : " ", (value & CTXLOG_TARGET_REMOTE_NET) ? "network" : " ", (value & CTXLOG_TARGET_REMOTE_SYSLOG ? "remote syslog" : "")); \
		GetLoggerFnTbl().Ptr_setTargets(value)

#define CTXLOG_setMaxFileSize(value)	\
		CTXLOG_Debug(CTXLOG_DEFAULT_MODULE,CTXLOG_MSG_INFO," ", " ", 0,"New max log file size is %dMB",value); \
	 	GetLoggerFnTbl().Ptr_setMaxFileSize(value)

#define CTXLOG_setMaxFileCount(value)	\
		CTXLOG_Debug(CTXLOG_DEFAULT_MODULE,CTXLOG_MSG_INFO," ", " ", 0,"New max log backup index : %d",value); \
	    GetLoggerFnTbl().Ptr_setMaxFileCount(value)

#define CTXLOG_setLogFilePattern(value)	\
		CTXLOG_Debug(CTXLOG_DEFAULT_MODULE,CTXLOG_MSG_INFO," ", " ", 0,"New log pattern : %s",value); \
	    GetLoggerFnTbl().Ptr_setLogPattern(value)

#define CTXLOG_getLogFilePattern()	\
	    GetLoggerFnTbl().Ptr_getLogPattern(value)

#define CTXLOG_getMaxFileCount()	\
	    GetLoggerFnTbl().Ptr_getMaxFileCount()

#define CTXLOG_getMaxFileSize()	\
	    GetLoggerFnTbl().Ptr_getMaxFileSize()

#define CTXLOG_isEnabled()	\
		GetLoggerFnTbl().Ptr_isEnabled()

#define CTXLOG_getLoggingDir()	\
	    GetLoggerFnTbl().Ptr_getLoggingDir()

#define CTXLOG_getLevel()	\
	    GetLoggerFnTbl().Ptr_getLevel()

#define CTXLOG_getTargets()	\
	    GetLoggerFnTbl().Ptr_getTargets()

#define CTXLOG_initialize(packagename, logDir) \
	GetLoggerFnTbl().Ptr_initialize(packagename, logDir)

#ifdef __cplusplus 
}
#endif

#endif //__CLOGGER_SDK_INCLUDE__
