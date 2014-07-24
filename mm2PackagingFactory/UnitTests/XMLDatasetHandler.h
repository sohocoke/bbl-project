//
//  XMLDatasetHandler.h
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 22/03/14.
//

#import <Foundation/Foundation.h>

@interface XMLDatasetHandler : NSObject


-(NSData * ) readAndUpdate;
-(NSData * ) write;
-(NSData * ) dictionaryFromXML;

@end
