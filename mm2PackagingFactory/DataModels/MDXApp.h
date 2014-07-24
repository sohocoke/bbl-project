//
//  MDXApp.h
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 22/03/14.
//

#import <Foundation/Foundation.h>

@interface MDXApp : NSObject {
}
@property (nonatomic, copy) NSString * _name;
@property (nonatomic, copy) NSString * _displayName;

- (instancetype)initWithName:(NSString *)name displayName:(NSString *)displayName;

@end
