//
//  XMLHandler.h
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 30/03/14.
//

#import <Foundation/Foundation.h>

@interface XMLHandler : NSObject
{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    NSError *errorPointer;
}

+ (NSDictionary *)dictionaryFromXMLData:(NSData *)data error:(NSError *)errorPointer;
+ (NSDictionary *)dictionaryFromXMLString:(NSString *)string error:(NSError *)errorPointer;

@end
