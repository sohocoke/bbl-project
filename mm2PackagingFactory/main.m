//
//  main.c
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 22/03/14.
//


#import "MDXHandler.h"
#import "AppcHandler.h"

#import "XMLDatasetHandler.h"
#import "ArchiveHandler.h"
#import "UploadToAppC.h"
#import "PListHandler.h"
#import "Configuration.h"

int main(int argc, const char * argv[])
{
    NSLog(@"MM2 Packaging Factory is starting");
    
    if (argc != 4)
    {
        NSLog(@"Invalid number of args passed: Usage is mm2PackaginFactory pathToAppCList.xml pathToMM2AppList.xml pathToControlList.xml");
    }
    
    Configuration* configuration = [Configuration getInstance]; //Configuration is a singleton

    [configuration setPathToAppcList:[NSString stringWithUTF8String:argv[1]]];
    [configuration setPathToMM2AppList:[NSString stringWithUTF8String:argv[2]]];
    [configuration setPathToControlList:[NSString stringWithUTF8String:argv[3]]];
    
    
    //create MDX
    MDXHandler * mdxHandler = [[MDXHandler alloc] init];
    if ([mdxHandler createInternal:nil]) {
        
    }
    
    // Connect to AppController using CURL
    AppcHandler * appcHandler = [[AppcHandler alloc] init];
    [appcHandler createInternal:nil];

    
    NSLog(@"MM2 Packaging Factory finished");
    
    
    
//// PoC experiments


//    //open, modify and replace the info.plist
//    PListHandler * plistHandler = [[PListHandler alloc] init];
//    __unused NSData * mData = [plistHandler readAndUpdate];

//    //AppController using NUSURLConnection (this approach doesnt work  -can be deleted
//    UploadToAppC * uploadToAppC = [[UploadToAppC alloc] init];
//    //__unused NSData * mData = [uploadToAppC open];
//    [uploadToAppC open];



//    //open and then compress an archive
//    ArchiveHandler * archiveHandler = [[ArchiveHandler alloc] init];
//    __unused NSData * openArchive = [archiveHandler open];
//    __unused NSData * zipped = [archiveHandler compress];

//    //XML Handling
//    XMLDatasetHandler *xmlDatasetHandler = [[XMLDatasetHandler alloc] init];
//    __unused NSData *  xmlStructure = [xmlDatasetHandler dictionaryFromXML];
//read, update and write to a new location an XML Document
//    __unused NSData *  xmlStructure = [xmlDatasetHandler readAndUpdate];

    
    
    return 0;
}

