//
//  Configuration.m
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 30/03/14.
//

#import "Configuration.h"

@implementation Configuration

@synthesize pathToAppcList;
@synthesize pathToMM2AppList;
@synthesize pathToControlList;

#pragma mark Singleton Methods

+ (id)getInstance {
    static Configuration *sharedConfiguration= nil;
    @synchronized(self) {
        if (sharedConfiguration == nil)
            sharedConfiguration = [[self alloc] init];
    }
    return sharedConfiguration;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)setPathToAppcList : (NSString*) str {
    pathToAppcList = str;
    NSLog(@"The path to the AppController List is %@",str);
}

- (void)setPathToMM2AppList : (NSString*) str {
    pathToMM2AppList = str;
    NSLog(@"The path to the MM2App List is %@",str);
}

- (void)setPathToControlList : (NSString*) str {
    pathToControlList = str;
    NSLog(@"The path to the Control List is %@",str);
}


@end
