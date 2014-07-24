//
//  NSString+NSStringAdditions.h
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 29/03/14.
//  Copyright (c) 2014 jeremy brookfield. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringAdditions)

+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;

@end
