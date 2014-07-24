//
//  PListHandler.m
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 28/03/14.
//

#import "PListHandler.h"

@implementation PListHandler


- (instancetype)init

{
    if ((self = [super init])) {
        //initialization logic goes here
        NSLog(@"PlistHandler : init");
	}
	return self;
}

-(NSData* ) readAndUpdate {
    
    NSLog(@"PlistHandler : read");
    
    NSString *file = @"/Users/jeremybrookfield/Work/test/Info.plist";
    
    NSMutableDictionary *infoPlist = [[NSMutableDictionary alloc] initWithContentsOfFile: file];
    
    for (NSString* key in infoPlist) {
        __unused id value = [infoPlist objectForKey:key];
        //NSLog(@"Key : %@  , value : %@" ,key, value);
    }

    NSString*  cfBundleDisplayName = [infoPlist objectForKey:@"CFBundleDisplayName"];
    NSLog(@"Bundle Display Name : %@",cfBundleDisplayName);
    
    NSString*  cfBundleIdentifier = [infoPlist objectForKey:@"CFBundleIdentifier"];
    NSLog(@"Bundle Identifier : %@",cfBundleIdentifier);
    
    //[infoPlist setObject:[NSNumber numberWithInt:value] forKey:@”value”];
    [infoPlist setObject:@"com.creditsuisse.ctxmail" forKey:@"CFBundleIdentifier"];
    [infoPlist writeToFile: @"/Users/jeremybrookfield/Work/test/Info.plist" atomically:YES];
    
    return nil;
    
}


@end
