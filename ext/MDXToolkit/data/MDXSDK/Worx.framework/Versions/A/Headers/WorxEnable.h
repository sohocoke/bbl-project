//
//  FunctionRename.h
//
//  Copyright (c) 2012 Citrix Systems Inc. All rights reserved.
//

/* This file needs to be included in the .pch file of the app for Replacing Function*/

#define  SCNetworkReachabilityCreateWithAddress             SCNetworkReachabilityCreateWithAddrHK
#define  SCNetworkReachabilityCreateWithAddressPair         SCNetworkReachabilityCreateWithAddressPHK 
#define  SCNetworkReachabilityCreateWithName                SCNetworkReachabilityCreateWithNHK 
#define  SCNetworkReachabilityGetFlags                      SCNetworkReachabilityGetFlHK 
#define  SCNetworkReachabilityScheduleWithRunLoop           SCNetworkReachabilityScheduleWithRunLHK 
#define  SCNetworkReachabilityUnscheduleWithRunLoop         SCNetworkReachabilityUnscheduleFromRunLHK
#define  SCNetworkReachabilitySetCallback                   SCNetworkReachabilitySetCallbHK

#define  connect            connHK
#define  bind               bHK 
#define  gethostbyname      gethostbynHK 
#define  sendto             senHK 
#define  recvfrom           recvfHK 
#define  res_query          res_quHK 
#define  gethostbyaddr      gethostbyaHK 

#define  CFHostCreateWithAddress             CFHostCreateWithAddrHK 
#define  CFHostCreateWithName                CFHostCreateWithNHK  
#define  CFHostStartInfoResolution           CFHostStartInfoResolutHK   
#define  CFHostScheduleWithRunLoop           CFHostScheduleWithRunLHK   

#define  CFHostSetClient                     CFHostSetCliHK 
#define  CFHostGetAddressing                 CFHostGetAddressHK    
#define  CFHostUnscheduleFromRunLoop         CFHostUnscheduleFromRunLHK
#define  CFHostCancelInfoResolution          CFHostCancelInfoResolutHK 

#define  CFStreamCreatePairWithSocket               CFStreamCreatePairWithSocHK    
#define  CFStreamCreatePairWithSocketToHost         CFStreamCreatePairWithSocketToHHK  
#define  CFStreamCreatePairWithSocketToCFHost       CFStreamCreatePairWithSocketToCFHHK
#define  CFStreamCreatePairWithPeerSocketSignature  CFStreamCreatePairWithPeerSocketSignatHK


#define  CFReadStreamSetProperty                    CFReadStreamSetPropeHK  
#define  CFWriteStreamSetProperty                   CFWriteStreamSetPropeHK  
#define  CFReadStreamCreateForHTTPRequest           CFReadStreamCreateForHTTPRequHK  
#define  CFReadStreamCreateForStreamedHTTPRequest   CFReadStreamCreateForStreamedHTTPRequHK  

#define CFWriteStreamGetError  CFWriteStreamGetErHK
#define CFWriteStreamCopyError CFWriteStreamCopyErHK

#define CFReadStreamGetError    CFReadStreamGetErHK
#define CFReadStreamCopyError   CFReadStreamCopyErHK

#define  CFNetworkCopySystemProxySettings    CFNetworkCopySystemProxySettiHK
#define  CFWriteStreamOpen                   CFWriteStreamOHK 
#define  CFReadStreamOpen                    CFReadStreamOHK 
#define  CFSocketCreate                      CFSocketCreHK    
#define  CFSocketConnectToAddress            CFSocketConnectToAddrHK    
#define  CFSocketSendData                    CFSocketSendDHK    //used for UDP interception only
#define  CFSocketCreateRunLoopSource         CFSocketCreateRunLoopSouHK    
#define  CFSocketInvalidate                  CFSocketInvalidHK   

#define CFReadStreamCreateWithFTPURL    CFReadStreamCreateWithFTPHK
#define CFWriteStreamCreateWithFTPURL   CFWriteStreamCreateWithFTPHK

    // Contentment
#define AudioUnitSetProperty            AudioUnitSetPropeHK
#define AudioUnitRender                 AudioUnitRenHK

SCNetworkReachabilityRef SCNetworkReachabilityCreateWithAddrHK (
                                                                CFAllocatorRef allocator,
                                                                const struct sockaddr *address
                                                                );
SCNetworkReachabilityRef SCNetworkReachabilityCreateWithAddressPHK (
                                                                    CFAllocatorRef allocator,
                                                                    const struct sockaddr *localAddress,
                                                                    const struct sockaddr *remoteAddress
                                                                    );

Boolean SCNetworkReachabilityUnscheduleFromRunLHK (
                                                   SCNetworkReachabilityRef target,
                                                   CFRunLoopRef runLoop,
                                                   CFStringRef runLoopMode
                                                   );
    
SCNetworkReachabilityRef SCNetworkReachabilityCreateWithNHK (
                                                             CFAllocatorRef allocator,
                                                             const char *nodename
                                                             );

Boolean SCNetworkReachabilityGetFlHK (
                                      SCNetworkReachabilityRef target,
                                      SCNetworkReachabilityFlags *flags
                                      );

Boolean SCNetworkReachabilityScheduleWithRunLHK (
                                                 SCNetworkReachabilityRef target,
                                                 CFRunLoopRef runLoop,
                                                 CFStringRef runLoopMode
                                                 );

Boolean SCNetworkReachabilitySetCallbHK (
                                         SCNetworkReachabilityRef target,
                                         SCNetworkReachabilityCallBack callout,
                                         SCNetworkReachabilityContext *context
                                         );

int connHK (
            int sockfd,
            const struct sockaddr *serv_addr,
            socklen_t addrlen);
int bHK (
         int sockfd,
         const struct sockaddr *my_addr,
         socklen_t addrlen
         );

struct hostent *gethostbynHK(
                             const char *name
                             );

struct hostent *gethostbyaHK(
                             const void *addr,
                             socklen_t len,
                             int type
                             );
ssize_t senHK(
              int socket,
              const void *message,
              size_t length,
              int flags,
              const struct sockaddr *dest_addr,
              socklen_t dest_len
              );

ssize_t recvfHK(
                int socket,
                void *buffer,
                size_t length,
                int flags,
                struct sockaddr *address,
                socklen_t *address_len
                );
int res_quHK(
             const char *dname,
             int class_,
             int type,
             unsigned char *answer,
             int anslen
             );

CFHostRef CFHostCreateWithNHK (
                               CFAllocatorRef allocator,
                               CFStringRef hostname
                               );

CFHostRef CFHostCreateWithAddrHK (
                                  CFAllocatorRef allocator,
                                  CFDataRef addr
                                  );


Boolean CFHostSetCliHK(
                       CFHostRef theHost,
                       CFHostClientCallBack   clientCB,
                       CFHostClientContext *  clientContext
                       );

void CFHostScheduleWithRunLHK(
                              CFHostRef theHost,
                              CFRunLoopRef   runLoop,
                              CFStringRef	runLoopMode
                              );

Boolean CFHostStartInfoResolutHK(
                                 CFHostRef	theHost,
                                 CFHostInfoType   info,
                                 CFStreamError *  error
                                 );

CFArrayRef CFHostGetAddressHK(
                              CFHostRef   theHost,
                              Boolean *   hasBeenResolved
                              );

void CFHostUnscheduleFromRunLHK(
                                CFHostRef	 theHost,
                                CFRunLoopRef   runLoop,
                                CFStringRef	runLoopMode
                                );

void CFHostCancelInfoResolutHK(
                               CFHostRef theHost,
                               CFHostInfoType info
                               );

void CFStreamCreatePairWithSocHK (
                                  CFAllocatorRef alloc,
                                  CFSocketNativeHandle sock,
                                  CFReadStreamRef *readStream,
                                  CFWriteStreamRef *writeStream
                                  );

void CFStreamCreatePairWithSocketToHHK (
                                        CFAllocatorRef alloc,
                                        CFStringRef host,
                                        UInt32 port,
                                        CFReadStreamRef *readStream,
                                        CFWriteStreamRef *writeStream
                                        );

void CFStreamCreatePairWithSocketToCFHHK (
                                          CFAllocatorRef alloc,
                                          CFHostRef host,
                                          SInt32 port,
                                          CFReadStreamRef *readStream,
                                          CFWriteStreamRef *writeStream
                                          );

void CFStreamCreatePairWithPeerSocketSignatHK(CFAllocatorRef alloc,
                                              const CFSocketSignature *signature,
                                              CFReadStreamRef *readStream,
                                              CFWriteStreamRef *writeStream);


Boolean CFReadStreamSetPropeHK (
                                CFReadStreamRef stream,
                                CFStringRef propertyName,
                                CFTypeRef propertyValue
                                );

Boolean CFWriteStreamSetPropeHK (
                                 CFWriteStreamRef stream,
                                 CFStringRef propertyName,
                                 CFTypeRef propertyValue
                                 );



Boolean CFReadStreamOHK (
                         CFReadStreamRef stream
                         );

Boolean CFWriteStreamOHK (
                          CFWriteStreamRef stream
                          );

CFErrorRef CFReadStreamCopyErHK (
                                 CFReadStreamRef stream
                                 );


CFStreamError CFReadStreamGetErHK (
                                   CFReadStreamRef stream
                                   );

CFStreamError CFWriteStreamGetErHK (
                                    CFWriteStreamRef stream
                                    );

CFErrorRef CFWriteStreamCopyErHK (
                                  CFWriteStreamRef stream
                                  );

CFDictionaryRef CFNetworkCopySystemProxySettiHK ( void );

CFReadStreamRef CFReadStreamCreateWithFTPHK(
                                            CFAllocatorRef   alloc,
                                            CFURLRef	ftpURL
                                            );

CFWriteStreamRef CFWriteStreamCreateWithFTPHK(
                                              CFAllocatorRef   alloc,
                                              CFURLRef	 ftpURL
                                              );



OSStatus AudioUnitSetPropeHK( AudioUnit            inUnit,
                             AudioUnitPropertyID  inID,
                             AudioUnitScope       inScope,
                             AudioUnitElement     inElement,
                             const void           *inData,
                             UInt32               inDataSize );

OSStatus AudioUnitRenHK(AudioUnit                   inUnit,
                        AudioUnitRenderActionFlags  *ioActionFlags,
                        const AudioTimeStamp        *inTimeStamp,
                        UInt32                      inOutputBusNumber,
                        UInt32                      inNumberFrames,
                        AudioBufferList             *ioData);



CFSocketRef CFSocketCreHK (
                           CFAllocatorRef allocator,
                           SInt32 protocolFamily,
                           SInt32 socketType,
                           SInt32 protocol,
                           CFOptionFlags callBackTypes,
                           CFSocketCallBack callout,
                           const CFSocketContext *context
                           );

CFSocketError CFSocketConnectToAddrHK (
                                       CFSocketRef s,
                                       CFDataRef address,
                                       CFTimeInterval timeout
                                       );

CFSocketError CFSocketSendDHK (
                               CFSocketRef s,
                               CFDataRef address,
                               CFDataRef data,
                               CFTimeInterval timeout
                               );


CFRunLoopSourceRef CFSocketCreateRunLoopSouHK (
                                               CFAllocatorRef allocator,
                                               CFSocketRef s,
                                               CFIndex order
                                               );
void CFSocketInvalidHK (
                        CFSocketRef s
                        );


CFReadStreamRef CFReadStreamCreateForHTTPRequHK (
                                                 CFAllocatorRef alloc,
                                                 CFHTTPMessageRef request
                                                 );

CFReadStreamRef CFReadStreamCreateForStreamedHTTPRequHK (
                                                         CFAllocatorRef alloc,
                                                         CFHTTPMessageRef requestHeaders,
                                                         CFReadStreamRef requestBody
                                                         );