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
    NSString* path = @"/Users/andy/Documents/src/mm2PackagingFactory";
    
    NSLog(@"AppcHandler : invoke");
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/Applications/Citrix/MDXToolkit/CGAppCLPrepTool"];
    
    
    NSMutableArray* argArray  = [[NSMutableArray alloc]init];
    [argArray addObject:@"Wrap"];

    [argArray addObject:@"-Cert"];
    [argArray addObject:@"iPhone Distribution: Credit Suisse AG"]; //certificate and private key as named in Keychain
    [argArray addObject:@"-Profile"];
    [argArray addObject:[NSString stringWithFormat:@"%@/mm2PackagingFactory/Resources/citrix_2014.mobileprovision", path]]; //Mobile Provision profile
    
    [argArray addObject:@"-in"];
    [argArray addObject:[NSString stringWithFormat:@"%@/mm2PackagingFactory/Resources/MVCNetworking.ipa", path]]; //input .ipa
    
    [argArray addObject:@"-out"];
    [argArray addObject:[NSString stringWithFormat:@"%@/mm2PackagingFactory/Resources/MVCNetworking.mdx", path]]; //output .mdx
    
    [argArray addObject:@"-logFile"];
    [argArray addObject:@"wrap-MVCNetworking.log"];
    [argArray addObject:@"-logWriteLevel"];
    [argArray addObject:@"4"];
    
    [argArray addObject:@"-appName"];
    [argArray addObject:@"MVCNetworking"];
    
    [argArray addObject:@"-appDesc"];
    [argArray addObject:@"test wrapping MVCNetworking"];
    
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
    
    NSLog(@"will run task: %@", [task description]);
    
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





