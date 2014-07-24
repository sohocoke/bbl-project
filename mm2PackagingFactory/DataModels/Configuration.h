//
//  Configuration.h
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 30/03/14.
//

#import <Foundation/Foundation.h>

@interface Configuration : NSObject {
    NSString* pathToAppcList;
    NSString* pathToMM2AppList;
    NSString* pathToControlList;
}


@property (nonatomic,retain) NSString* pathToAppcList;
@property (nonatomic,retain) NSString* pathToMM2AppList;
@property (nonatomic,retain) NSString* pathToControlList;

+ (id) getInstance;

@end
