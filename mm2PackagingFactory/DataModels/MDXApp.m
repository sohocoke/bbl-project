//
//  MDXApp.m
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 22/03/14.
//

#import "MDXApp.h"


@implementation MDXApp

- (id)initWithName:(NSString *)name displayName:(NSString *)displayName  {
    
    if ((self = [super init])) {
        self._name = name;
        self._displayName = displayName;
    }
    return self;
    
}

@end
