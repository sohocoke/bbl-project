//
//  NSURL+CtxLoggerExtension.h
//  CtxLogger
//
//  Created by Aakash M D on 05/05/14.
//  Copyright (c) 2014 Citrix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (CtxLoggerExtension)

- (NSString *) ctxStringByObfuscatingQueryParameters;

@end
