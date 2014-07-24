//
//  ArchiveHandle.m
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 23/03/14.
//

#import "ArchiveHandler.h"
#import "ZipArchive.h"

@implementation ArchiveHandler

- (instancetype)init

{
    if ((self = [super init])) {
        //initialization logic goes here
        NSLog(@"ArchiveHandler : init");
	}
	return self;
}

-(NSData* ) open {
    
    NSLog(@"ArchiveHandler : open");
    

    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //Documents directory is typically /Users/<userid>/Documents
    
    NSString *zipFilePath = [documentsDirectory stringByAppendingPathComponent:@"test.zip"];
    
    NSString *output = [documentsDirectory stringByAppendingPathComponent:@"unZippedDirName"];
    
    ZipArchive* za = [[ZipArchive alloc] init];
    
    if( [za UnzipOpenFile:zipFilePath] ) {
        if( [za UnzipFileTo:output overWrite:YES] != NO ) {
            NSLog(@"unzipped successfully");
        }
        
        [za UnzipCloseFile];
    }
    
    return nil;
}

-(NSData* ) compress {
    
    NSLog(@"ArchiveHandler : compress");
    
    BOOL isDir=NO;
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSArray *subpaths;
    
    NSString *toCompress = @"unZippedDirName";
    NSString *pathToCompress = [documentsDirectory stringByAppendingPathComponent:toCompress];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:pathToCompress isDirectory:&isDir] && isDir){
        subpaths = [fileManager subpathsAtPath:pathToCompress];
    } else if ([fileManager fileExistsAtPath:pathToCompress]) {
        subpaths = [NSArray arrayWithObject:pathToCompress];
    }
    
    NSString *zipFilePath = [documentsDirectory stringByAppendingPathComponent:@"zipped.zip"];
    
    ZipArchive *za = [[ZipArchive alloc] init];
    [za CreateZipFile2:zipFilePath];
    if (isDir) {
        for(NSString *path in subpaths){
            NSString *fullPath = [pathToCompress stringByAppendingPathComponent:path];
            if([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir){
                [za addFileToZip:fullPath newname:path];
            }
        }
    } else {
        [za addFileToZip:pathToCompress newname:toCompress];
    }
    
    __unused BOOL successCompressing = [za CloseZipFile2];
    
    return nil;
}

@end
