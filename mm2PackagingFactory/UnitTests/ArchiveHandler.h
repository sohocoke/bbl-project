//
//  ArchiveHandle.h
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 23/03/14.
//  Copyright (c) 2014 jeremy brookfield. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArchiveHandler : NSObject

-(NSData * ) open;
-(NSData * ) compress;

@end
