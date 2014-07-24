//
//  ExecuteProgram.m
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 22/03/14.
//

#import "ExecuteProgram.h"

@implementation ExecuteProgram{}

- (instancetype)init

{
    if ((self = [super init])) {
        //initialization logic goes here
        NSLog(@"ExecuteProgram : init");
	}
	return self;
}
/*
 /Applications/Citrix/MDXToolkit/CGAppCLPrepTool  -C "iPhone Distribution: PERCULA Consulting GmbH" -P "/Users/jeremybrookfield/Work/SourceCode/XCodeCertsandProfiles/Wildcard.mobileprovision" -in "/Users/jeremybrookfield/Work/test/WorxMail-Release-1.5-94Changed.ipa" -out "/Users/jeremybrookfield/Work/test/WorxMail-Release-1.5-94Changed_iOS.mdx" -logFile "/Applications/Citrix/MDXToolkit/logs/Citrix.log" -logWriteLevel 4  -desc "WorxMail 94" -app "WorxMail" -maxPlatform "7.1" -minPlatform "6.0" -excludedDevices "iphone"
*/
/*
 /Applications/Citrix/MDXToolkit/CGAppCLPrepTool  -C "iPhone Distribution: Credit Suisse AG" -P "/Users/jeremybrookfield/Work/CS Enterprise/citrix_2014.mobileprovision" -in "/Users/jeremybrookfield/Work/test/WorxMail-Release-1.5-94.ipa" -out "/Users/jeremybrookfield/Work/test/WorxMail-Release-1.5-94_iOS.mdx" -logFile "/Applications/Citrix/MDXToolkit/logs/Citrix.log" -logWriteLevel 4  -desc "WorxMail 94" -app "WorxMail" -maxPlatform "7.1" -minPlatform "6.0" -excludedDevices "iphone"
 */

//********Citrix mobile app was created successfully.********

-(NSData* ) invoke {
    
    NSLog(@"ExecuteProgram : invoke");
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/ls"];
    //[task setArguments:@[@"-a",  @"/Volumes"]]; //technique #1 to pass args
    
    //NSArray* args = [NSArray arrayWithObjects: @"-a",@"/Volumes", nil]; //technique #w to pass args
    
    NSMutableArray* mutableargs  = [[NSMutableArray alloc]init];
    [mutableargs addObject:@"-a"];
    [mutableargs addObject:@"/Volumes"];
    NSArray *args = [mutableargs copy]; //technique #3 to pass args, useful if there are many args
    
    [task setArguments:args];
    NSPipe * out = [NSPipe pipe];
    [task setStandardOutput:out]; //direct output to pipe
    
    [task launch];   // issue ls -a /Volumes
    [task waitUntilExit];  // wait until command has ended
    
    NSFileHandle *response = [out fileHandleForReading]; // read output
    NSData *responseAsData = [response readDataToEndOfFile];
    
    
    
    if ([responseAsData length] > 0 ) {
    
        NSLog(@"The command returned %lu bytes", [responseAsData length]);

        //print as hex e.g. 2e0a2e2e  0a424f4f  = . linefeed .. linefeed boo
        NSLog(@"%@", responseAsData);
    
        //read file one byte at a time and print that byte
        const char* dataBytes = (const char*)[responseAsData bytes];
        NSUInteger length = [responseAsData length];
        NSUInteger index;
    
        for (index = 0; index<length; index++)
        {
            char aByte = dataBytes[index];
            NSLog(@"%i",aByte); // print out dec representation of ascii value e.g 65 is A, 10 is linefeed etc
        }
    
        //convert to string (note: will contain linefeeds)
        NSString* responseAsString = [NSString stringWithUTF8String:[responseAsData bytes]];
        NSLog(@"\n%@",responseAsString);
        
        return responseAsData;
    }
    else
    {
         NSLog(@"The command did not return any data");
        return nil;
    }
    


    
}

@end


