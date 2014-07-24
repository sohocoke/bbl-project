//
//  XMLDatasetHandler.m
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 22/03/14.

//

#import "XMLDatasetHandler.h"
#import "../DataModels/AppsToProcess.h"
#import "../DataModels/MDXApp.h"
#import "XMLHandler.h"



//See https://developer.apple.com/library/mac/documentation/cocoa/Conceptual/NSXML_Concepts/NSXML.html
/*
 
 Sample XML File
 
 <AppsToProcess>
 <MDXApp>
 <Name>com.citrix.ctxmail</Name>
 <DisplayName>Worxmail</DisplayName>
 <Class>x</Class>
 </MDXApp>
 <MDXApp>
 <Name>com.citrix.worxweb</Name>
 <DisplayName>Worxweb</DisplayName>
 <Class>y</Class>
 </MDXApp>
 <MDXApp>
 <Name>com.creditsuisse.icp</Name>
 <DisplayName>ICP</DisplayName>
 <Class>z</Class>
 </MDXApp>
 </AppsToProcess>
*/

@implementation XMLDatasetHandler

- (instancetype)init

{
    if ((self = [super init])) {
        //initialization logic goes here
        NSLog(@"XMLDatasetHandler : init");
	}
	return self;
}

-(NSData* ) dictionaryFromXML{
    NSLog(@"XMLDatasetHandler : readAndUpdate");
    
    NSString* mfile = @"/Users/jeremybrookfield/Work/test/AppcList.xml";
    NSData* mData = [NSData dataWithContentsOfFile:mfile];
    
    NSError* parseError = nil;
    
    NSDictionary* xmlDictionary = [XMLHandler dictionaryFromXMLData:mData error:parseError];
    
    // Print the dictionary
    NSLog(@"%@", xmlDictionary);
    return nil;
}

-(NSData* ) readAndUpdate {
    
    NSLog(@"XMLDatasetHandler : readAndUpdate");
    
    NSString *file = @"/Users/jeremybrookfield/Work/test/AppList.xml";
	NSXMLDocument *xmlDoc;
    NSError *err=nil;
    NSURL *furl = [NSURL fileURLWithPath:file];
	
    if (!furl) {
        NSLog(@"Can’t create an URL from file %@.", file); //note, even if the file is not found the furl will not be null
        return nil;
    }
	
     xmlDoc = [ [NSXMLDocument alloc] initWithContentsOfURL:furl options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error:&err];
    
	if (xmlDoc == nil) {
        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                      options:NSXMLDocumentTidyXML
                                                        error:&err];
        NSLog(@"error: unable to build XML Document, file ");
    }
	
	NSArray *nodes = [xmlDoc nodesForXPath:@"/AppsToProcess/MDXApp" error:&err];
                      
    if ([nodes count] > 0 ) {
        
        NSXMLElement *_mdxAppElement = [nodes objectAtIndex:0];
        if ([_mdxAppElement.name isEqual:@"MDXApp" ])  //in theory an unnecessary check as we have used XPath
        {
            NSXMLNode *node = [[_mdxAppElement elementsForName:@"Name"] objectAtIndex:0];
            NSString *name = node.stringValue;
            node = [[_mdxAppElement elementsForName:@"DisplayName"] objectAtIndex:0];
            NSString *displayName = node.stringValue;
            [node setStringValue:[@"updated_%@" stringByAppendingString:displayName]]; //change the Display Name
            __unused MDXApp *mdxApp = [[MDXApp alloc] initWithName:name displayName:displayName]; //create MDXApp object for future use
        }

        NSData *xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
        [xmlData writeToFile:@"/Users/jeremybrookfield/Work/test/AppListNew2.xml" atomically:YES];
        

    }

    return nil;
}

-(NSData* ) write {
    
    NSLog(@"XMLDatasetHandler : write");
    return nil;
}
@end
