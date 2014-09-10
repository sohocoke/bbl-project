//
//  WorxAPI.h
//
//  Dated: 02/04/2013
//  Copyright (c) 2013 Citrix Systems Inc. All rights reserved.
//


@interface MdxManager : NSObject

///// Get policies values provided by the MDX framework. If MDX framework is not active and app is running with demo policies, return demo policy values
+(NSString*) getValueOfPolicy:(NSString*)policyName error:(NSError **) error;


////// Check if MDX-Manager(Receiver or AccessManager) is installed //////
+(BOOL) isMDXAccessManagerInstalled: (NSError **) error;


////// Check if this app is managed by MDX //////
+(BOOL) isAppManaged;


////// Initiate MDX Logon request with WorxHome //////
+(BOOL) logonMdxWithFlag:(BOOL)force error:(NSError**) error;

// Check if the host application was launched from WorxHome
+(BOOL) isAppLaunchedByWorxHome;
    
@end
