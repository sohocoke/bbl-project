//
//  NSData+NSDataAdditions.h
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 29/03/14.
//

#import <Foundation/Foundation.h>
@class NSString;
@interface NSData (NSDataAdditions)

 + (NSData *) base64DataFromString:(NSString *)string;

@end
