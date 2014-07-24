//
//  MDXHandler
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 31/03/14.
//

#import "MDXHandler.h"

@implementation MDXHandler

- (instancetype)init

{
    if ((self = [super init])) {
        //initialization logic goes here
        NSLog(@"MDXHandler : init");
	}
	return self;
}

/*
 /Applications/Citrix/MDXToolkit/CGAppCLPrepTool  -C "iPhone Distribution: Credit Suisse AG" -P "/Users/jeremybrookfield/Work/CS Enterprise/citrix_2014.mobileprovision" -in "/Users/jeremybrookfield/Work/test/WorxMail-Release-1.5-94.ipa" -out "/Users/jeremybrookfield/Work/test/WorxMail-Release-1.5-94_iOS.mdx" -logFile "/Applications/Citrix/MDXToolkit/logs/Citrix.log" -logWriteLevel 4  -desc "WorxMail 94" -app "WorxMail" -maxPlatform "7.1" -minPlatform "6.0" -excludedDevices "iphone"
 */

-(BOOL ) createInternal: (MDXApp*) mdxApx
{
    
    NSLog(@"AppcHandler : invoke");
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/Applications/Citrix/MDXToolkit/CGAppCLPrepTool"];
    
    
    NSMutableArray* argArray  = [[NSMutableArray alloc]init];
    [argArray addObject:@"-C"];
    [argArray addObject:@"iPhone Distribution: Credit Suisse AG"]; //certificate and private key as named in Keychain
    [argArray addObject:@"-P"];
    [argArray addObject:@"/Users/jeremybrookfield/Work/CS Enterprise/citrix_2014.mobileprovision"]; //Mobile Provision profile
    
    [argArray addObject:@"-in"];
    [argArray addObject:@"/Users/jeremybrookfield/Work/mm_apps/ios/WorxMail-Release-1.5-94.ipa"]; //input .ipa
    
    [argArray addObject:@"-out"];
    [argArray addObject:@"/Users/jeremybrookfield/Work/mm_apps/ios/WorxMail-Release-1.5-94.mdx"]; //output .mdx
    
    [argArray addObject:@"-logFile"];
    [argArray addObject:@"/Users/jeremybrookfield/Work/mm_apps/ios/WorxMail-Release-1.5-94.log"];
    [argArray addObject:@"-logWriteLevel"];
    [argArray addObject:@"4"];
    
    [argArray addObject:@"-desc"];
    [argArray addObject:@"WorxMail 94"];
    
    [argArray addObject:@"-app"];
    [argArray addObject:@"WorxMail HKG"];
    
    [argArray addObject:@"-maxPlatform"];
    [argArray addObject:@"7.1"];
    //[argArray addObject:@"-minPlatform"];
    //[argArray addObject:@"6.1"];
    //[argArray addObject:@"-excludedDevices"];
    //[argArray addObject:@"iphone"];
    
    NSArray *args = [argArray copy]; //NSTask doesn't seem to like MutableArray
    [task setArguments:args];
    
    
    NSPipe * out = [NSPipe pipe];
    [task setStandardOutput:out]; //direct output to pipe
    
    [task launch];
    [task waitUntilExit];  // wait until command has ended
    
    NSFileHandle *response = [out fileHandleForReading]; // read output
    NSData *responseAsData = [response readDataToEndOfFile];
    
    
    
    if ([responseAsData length] > 0 ) {
        
        NSLog(@"The command returned %lu bytes", [responseAsData length]);
        
        //convert to string (note: will contain linefeeds)
        NSString* responseAsString = [NSString stringWithUTF8String:[responseAsData bytes]];
        NSLog(@"\n%@",responseAsString);
        
        if ([responseAsString rangeOfString:@"FIXME "].location != NSNotFound)
        {
            NSLog(@"------------Wrapper successful-------------");
            return TRUE;
        }
        else {
            NSLog(@"------DID NOT FIND CG_CSRFTOKEN------------");
            return FALSE;
        }
        
    }
    else
    {
        NSLog(@"The command did not return any data");
        return FALSE;
    }
    
    
    
    
}

@end





