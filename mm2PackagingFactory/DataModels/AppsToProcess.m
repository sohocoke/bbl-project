//
//  AppsToProcess.m
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 22/03/14.
//

#import "AppsToProcess.h"
#import "MDXApp.h"

@implementation AppsToProcess

- (id)init {
    
    if (( self = [super init] ))
    {
        
        self._mdxApps = [[NSMutableArray alloc] init];
    }
    return self;
    
}

@end
