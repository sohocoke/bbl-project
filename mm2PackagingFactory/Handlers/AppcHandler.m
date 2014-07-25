//
//  AppcHandler.m
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 04/04/14.
//

#import "AppcHandler.h"
@interface AppcHandler ()
@property (nonatomic, strong, readwrite) NSString * jsessionid;
@property (nonatomic, strong, readwrite) NSString * ocajsessionid;
@property (nonatomic, strong, readwrite) NSString * acnodeid;
@property (nonatomic, strong, readwrite) NSString * csrf;
@property (nonatomic, strong, readwrite) NSString * baseurl;

@end

@implementation AppcHandler

- (instancetype)init

{
    if ((self = [super init])) {
        //initialization logic goes here
        NSLog(@"AppcHandler : init");
	}
	return self;
}

-(BOOL ) createInternal: (MDXApp*) mdxApx
{

    NSString *testJSON = @"{\"errorcode\":\"0\",\"message\":\"Done\",\"ncgapplication\":{\"name\":\"MobileApp7\",\"description\":\"WorxMail EUR 94\",\"loginurl\":\"\",\"connectortype\":\"SSO\",\"categoryname\":\"Default\",\"deprovision\":\"IGNORE\",\"useridcreationrule\":\"$FN$LN\",\"ssotype\":\"Mobile\",\"enterpriseattributes\":\"\",\"passwordrule\":{\"maxlength\":\"0\",\"minlength\":\"0\",\"disallowusername\":\"false\",\"mustcontaincapitalletter\":\"false\",\"mustcontainspecialcharacter\":\"false\"},\"passwordvalidity\":{\"autoresetpassword\":\"false\",\"passwordexpiry\":\"0\",\"passwordvaliditydays\":\"0\"},\"workflowtemplate\":\"\",\"iconpath\":\"oca/img/ext/be984054-1fd5-450e-b72b-5b2ce56f4ac3.png\",\"applicationlabel\":\"WorxMail EUR\",\"totallicenses\":\"0\",\"maxthreshold\":\"40\",\"minthreshold\":\"10\",\"adintegrated\":\"false\",\"serviceaccountid\":\"\",\"serviceaccountpassword\":\"\",\"autoprovision\":\"false\",\"mobileprofile\":{\"binarylocation\":\"\",\"devicetype\":\"\",\"deviceos\":\"\"},\"vpn\":\"false\",\"appType\":\"mobile_ios\",\"auto\":\"false\",\"requiredKW\":\"false\",\"disabled\":\"false\",\"paid\":\"false\",\"uuid\":\"be984054-1fd5-450e-b72b-5b2ce56f4ac3\"}}";
//    NSString* testJSON = @"{\"ncglogin\": {\"adminId\": \"Administrator\",\"password\": \"password\"}}";
   
   [self parseRespone:testJSON];
    
    
    NSLog(@"APPCHandler : createInternal");
//    self.baseurl = @"https://192.168.204.150:4443";
    self.baseurl = @"https://161.202.193.123:4443";  // ETIT
    
    
    NSLog(@"_______________INITIAL CALL TO GET COOKIES_______________");
    //curl -I "https://161.202.193.123:4443/ControlPoint/" -H "If-None-Match: W/3603-1382729108000" -H "Accept-Encoding: gzip,deflate,sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"  -H "Cookie: ACNODEID=$ACNODEID" -H "Connection: keep-alive" -H "If-Modified-Since: Fri, 25 Oct 2013 19:25:08 GMT" --compressed -k

    NSMutableArray *mArgs = [self prepareStandardCURLArguments];
    [mArgs addObject:@"-I"]; //we only need the header in this call
    [mArgs addObject:[NSString stringWithFormat:@"%@/ControlPoint/",self.baseurl]];
    [self executeAndAnalyzeOutput: mArgs];
    NSLog(@"_______________");
    NSLog(@"");
    
    NSLog(@"_______________INITIAL CALL TO JavaScriptServlet_______________");
    //curl  "https://161.202.193.123:4443/ControlPoint/JavaScriptServlet" -H "Accept-Encoding: gzip,deflate,sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.3" -H "Accept: */*" -H "Referer: https://161.202.193.123::4443/ControlPoint/" -H "Cookie: JSESSIONID=0906755C54ED5024E24872C326681A0A; ACNODEID=8226125278091195649" -H "Connection: keep-alive" --compressed -k
    
    mArgs = [self prepareStandardCURLArguments];
    [mArgs addObject:[NSString stringWithFormat:@"%@/ControlPoint/JavaScriptServlet",self.baseurl]];
    [self executeAndAnalyzeOutput: mArgs];
    NSLog(@"_______________");
    NSLog(@"");
    
    
    
    
    NSLog(@"_______________LOGIN_______________");
    //curl  "https://161.202.193.123:4443/ControlPoint/rest/newlogin" -H "Cookie: JSESSIONID= 0906755C54ED5024E24872C326681A0A; ACNODEID=8226125278091195649" -H "Origin: https://161.202.193.123:4443" -H "Accept-Encoding: gzip,deflate,sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36" -H "Content-Type: application/json;charset=UTF-8" -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Referer: https://161.202.193.123:4443/ControlPoint/" -H "CG_CSRFTOKEN: C8XM-JE50-E2KJ-URV3-9KZD-J1K3-2YHF-ELTV"  -H "X-Requested-With: CloudGateway AJAX" -H "Connection: keep-alive" --data @login.txt --compressed -k
    
    mArgs = [self prepareStandardCURLArguments];
    [mArgs addObject:[NSString stringWithFormat:@"%@/ControlPoint/rest/newlogin",self.baseurl]];
    [mArgs addObject:@"--data"];
    [mArgs addObject:@"@/Users/andy/Documents/src/mm2PackagingFactory/data/login.txt"];
    [self executeAndAnalyzeOutput: mArgs];
    //possible results
    //{"errorcode":"0","message":"Done","ncglogin":{"sessionid":"3F1F20D03C7861870DA63D2CA5B45A7F"}} //good
    //null //invalid account
    //{"errorcode":"-100","message":"A configuration error occurred.","ncglogin":null} //invalid password
    //{"errorcode":"-100","message":"A configuration error occurred.","ncglogin":null} //e.g. missing or incorrect quotes (watch out for TextEdit smart quotes!)
    //The command did not return any data
    NSLog(@"_______________");
    NSLog(@"");

//    NSLog(@"_______________UPLOAD APP_______________");
//    //#UPLOAD APP WITHOUT ROLE OR CATEGORY CHANGE
//    //    $command= "$curlFolder\curl.exe --data-binary '`@$MDX' -k -X POST --cookie JSESSIONID=$JSESSION -H "Content-type:application/octet-stream" -v https://$AppCFQDN`:4443/ControlPoint/api/v1/mobileApp";
//    
//    mArgs = [self prepareStandardCURLArguments];
//    [mArgs addObject:[NSString stringWithFormat:@"%@/ControlPoint/api/v1/mobileApp",self.baseurl]];
//    [mArgs addObject:@"--data-binary"];
//    [mArgs addObject:@"@/Users/jeremybrookfield/Work/test/WorxMailEUR_iOS.mdx"];
//    [mArgs addObject:@"-X"];
//    [mArgs addObject:@"POST"];
//    [mArgs addObject:@"-H"];
//    [mArgs addObject:@"Content-type: application/octet-stream"];
//    [self executeAndAnalyzeOutput: mArgs];
    /*
     {"errorcode":"0","message":"Done","ncgapplication":{"name":"MobileApp7","description":"WorxMail EUR 94","loginurl":"","connectortype":"SSO","categoryname":"Default","deprovision":"IGNORE","useridcreationrule":"$FN$LN","ssotype":"Mobile","enterpriseattributes":"","passwordrule":{"maxlength":"0","minlength":"0","disallowusername":"false","mustcontaincapitalletter":"false","mustcontainspecialcharacter":"false"},"passwordvalidity":{"autoresetpassword":"false","passwordexpiry":"0","passwordvaliditydays":"0"},"workflowtemplate":"","iconpath":"oca/img/ext/be984054-1fd5-450e-b72b-5b2ce56f4ac3.png","applicationlabel":"WorxMail EUR","totallicenses":"0","maxthreshold":"40","minthreshold":"10","adintegrated":"false","serviceaccountid":"","serviceaccountpassword":"","autoprovision":"false","mobileprofile":{"binarylocation":"","devicetype":"","deviceos":""},"vpn":"false","appType":"mobile_ios","auto":"false","requiredKW":"false","disabled":"false","paid":"false","uuid":"be984054-1fd5-450e-b72b-5b2ce56f4ac3"}}
     {"errorcode":"-1","message":"A configuration error occurred." //if app already exists
    */
    NSLog(@"_______________");
    NSLog(@"\n");
    
    
    NSLog(@"_______________GET SETTINGS_______________");
    //#GET SETTINGS DATA FROM APP ON APPC
    //$command="$curlFolder\curl.exe ""https://$AppCFQDN`:4443/ControlPoint/rest/mobileappmgmt/$AppName"" -H ""Cookie: JSESSIONID=$JSESSION; ACNODEID=$ACNODEID"" -H ""Accept-Encoding: gzip,deflate,sdch"" -H ""Accept-Language: en-US,en;q=0.8"" -H ""User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"" -H ""Accept: application/json, text/javascript, */*; q=0.01"" -H ""Referer: https://$AppCFQDN`:4443/ControlPoint/main.html"" -H ""CG_CSRFTOKEN: $CSRF"" -H ""X-Requested-With: CloudGateway AJAX"" -H ""Connection: keep-alive"" --compressed -k"
    mArgs = [self prepareStandardCURLArguments];
    [mArgs addObject:[NSString stringWithFormat:@"%@/ControlPoint/rest/mobileappmgmt/MobileApp47",self.baseurl]];
    [self executeAndAnalyzeOutput: mArgs];
    //{"errorcode":"-1","message":"Mobile App data cannot be retrieved"}
    //null
    NSLog(@"_______________");
    NSLog(@"\n");
    
    
    
    
    
//    NSLog(@"_______________UPDATE APP_______________");
//    //#GET SETTINGS DATA FROM APP ON APPC
//    //$command="$curlFolder\curl.exe ""https://$AppCFQDN`:4443/ControlPoint/rest/mobileappmgmt/$AppName"" -H ""Cookie: JSESSIONID=$JSESSION; ACNODEID=$ACNODEID"" -H ""Accept-Encoding: gzip,deflate,sdch"" -H ""Accept-Language: en-US,en;q=0.8"" -H ""User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"" -H ""Accept: application/json, text/javascript, */*; q=0.01"" -H ""Referer: https://$AppCFQDN`:4443/ControlPoint/main.html"" -H ""CG_CSRFTOKEN: $CSRF"" -H ""X-Requested-With: CloudGateway AJAX"" -H ""Connection: keep-alive"" --compressed -k"
//    mArgs = [self prepareStandardCURLArguments];
//    [mArgs addObject:[NSString stringWithFormat:@"%@/ControlPoint/rest/mobileappmgmt/MobileApp3",self.baseurl]];
//    [self executeAndAnalyzeOutput: mArgs];
//    //{"errorcode":"-1","message":"Mobile App data cannot be retrieved"}
//    //null
//    NSLog(@"_______________");
//    NSLog(@"\n");
//    
    
    
//    NSLog(@"_______________GET OCAJSESSIONID_______________");
//    //#GET OCAJSESSIONID
//    //    $command="$curlFolder\curl.exe -I ""https://$AppCFQDN`:4443/oca/img/default.png"" -H ""If-None-Match: W/""""55689-1382729873000"""""" -H ""Accept-Encoding: gzip,deflate,sdch"" -H ""Accept-Language: en-US,en;q=0.8"" -H ""User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"" -H ""Accept: image/webp,*/*;q=0.8"" -H ""Referer: https://$AppCFQDN`:4443/ControlPoint/main.html"" -H ""Cookie: ACNODEID=$ACNODEID"" -H ""Connection: keep-alive"" -H ""If-Modified-Since: Fri, 25 Oct 2013 19:37:53 GMT"" --compressed -k"
//    //    $result=Invoke-Expression $command 2>&1
//    mArgs = [self prepareStandardCURLArguments];
//    [mArgs addObject:[NSString stringWithFormat:@"%@/oca/img/default.png",self.baseurl]];
//    [mArgs addObject:@"-I"];
//    [self executeAndAnalyzeOutput: mArgs];
// 
//    mArgs = [self prepareStandardCURLArguments2];
//    [mArgs addObject:[NSString stringWithFormat:@"%@/ControlPoint/rest/role",self.baseurl]];
//    [self executeAndAnalyzeOutput: mArgs];
//    NSLog(@"_______________");
//    NSLog(@"");
    return TRUE;
}


-(NSMutableArray*) prepareStandardCURLArguments {
    NSMutableArray* argArray  = [[NSMutableArray alloc]init];

    [argArray addObject:@"-H"];
    [argArray addObject:@"Accept-Encoding: gzip,deflate,sdch"];
    
    [argArray addObject:@"-H"];
    [argArray addObject:@"Accept: application/json,text/javascript,text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"];
    
    [argArray addObject:@"-H"];
    [argArray addObject:@"Accept-Language: en-US,en;q=0.8"];

    [argArray addObject:@"-H"];
    [argArray addObject:@"Connection: keep-alive"];
    
    [argArray addObject:@"-H"];
    [argArray addObject:@"X-Requested-With: CloudGateway AJAX"];

    [argArray addObject:@"-H"];
    [argArray addObject:[NSString stringWithFormat:@"Referer: %@/ControlPoint/",self.baseurl]];
    
    [argArray addObject:@"-H"];
    [argArray addObject:[NSString stringWithFormat:@"Origin: %@",self.baseurl]];
    
    [argArray addObject:@"-H"];
    [argArray addObject:@"Content-Type: application/json;charset=UTF-8"];

    [argArray addObject:@"-H"];
    [argArray addObject:@"User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"];
    
    [argArray addObject:@"-H"];
    [argArray addObject:[NSString stringWithFormat:@"Cookie: %@%@; %@%@; %@%@",@"JSESSIONID=",self.jsessionid,@"ACNODEID=",self.acnodeid,@"OCAJSESSIONID=",self.ocajsessionid]];
//    [argArray addObject:[NSString stringWithFormat:@"Cookie: %@%@; %@%@",@"JSESSIONID=",self.jsessionid,@"ACNODEID=",self.acnodeid]];
    
    [argArray addObject:@"-H"];
    [argArray addObject:[NSString stringWithFormat:@"CG_CSRFTOKEN: %@",self.csrf]];

    [argArray addObject:@"--compressed"];
    [argArray addObject:@"-k"];
    
    return argArray;
}

-(NSMutableArray*) prepareStandardCURLArguments2 {
    NSMutableArray* argArray  = [[NSMutableArray alloc]init];
    
    [argArray addObject:@"-H"];
    [argArray addObject:@"Accept-Encoding: gzip,deflate,sdch"];
    
    [argArray addObject:@"-H"];
    [argArray addObject:@"Accept: application/json,text/javascript,text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"];
    
    [argArray addObject:@"-H"];
    [argArray addObject:@"Accept-Language: en-US,en;q=0.8"];
    
    [argArray addObject:@"-H"];
    [argArray addObject:@"Connection: keep-alive"];
    
    [argArray addObject:@"-H"];
    [argArray addObject:@"X-Requested-With: CloudGateway AJAX"];
    
    [argArray addObject:@"-H"];
    [argArray addObject:[NSString stringWithFormat:@"Referer: %@/ControlPoint/main.html",self.baseurl]];
    
    [argArray addObject:@"-H"];
    [argArray addObject:[NSString stringWithFormat:@"Origin: %@",self.baseurl]];
    
    [argArray addObject:@"-H"];
    [argArray addObject:@"Content-Type: application/json;charset=UTF-8"];
    
    [argArray addObject:@"-H"];
    [argArray addObject:@"User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"];
    
    [argArray addObject:@"-H"];
    [argArray addObject:[NSString stringWithFormat:@"Cookie: %@%@; %@%@; %@%@",@"JSESSIONID=",self.jsessionid,@"ACNODEID=",self.acnodeid,@"OCAJSESSIONID=",self.ocajsessionid]];
//    [argArray addObject:[NSString stringWithFormat:@"Cookie: %@%@; %@%@",@"JSESSIONID=",self.jsessionid,@"ACNODEID=",self.acnodeid]];
    
    [argArray addObject:@"-H"];
    [argArray addObject:[NSString stringWithFormat:@"CG_CSRFTOKEN: %@",self.csrf]];
    
    [argArray addObject:@"--compressed"];
    [argArray addObject:@"-k"];
    
    return argArray;
}

-(BOOL) executeAndAnalyzeOutput : (NSMutableArray *)mArgs  {
    NSArray *args = [ mArgs copy];
    
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/curl"];
    [task setArguments:args];

    NSPipe * out = [NSPipe pipe];
    [task setStandardOutput:out]; //direct output to pipe

    NSString* taskDetails = @"curl ";
    for (NSString* arg in args) {
        NSString* token = arg;
        if (! [[arg substringToIndex:1] isEqual:@"-"])
            token = [[@"\"" stringByAppendingString:arg] stringByAppendingString:@"\""];
        taskDetails = [taskDetails stringByAppendingString:token];
        taskDetails = [taskDetails stringByAppendingString:@" "];
    }
    NSLog(@"task details: %@", taskDetails);
    
    [task launch];
    [task waitUntilExit];  // wait until command has ended

    NSFileHandle *response = [out fileHandleForReading]; // read output
    NSData *responseAsData = [response readDataToEndOfFile];

    if ([responseAsData length] > 0 ) {
        
        NSLog(@"The command returned %lu bytes", [responseAsData length]);
        
        //convert to string (note: will contain linefeeds)
        NSString* responseAsString = [NSString stringWithUTF8String:[responseAsData bytes]];
        NSLog(@"\n%@",responseAsString);
        [self parseRespone:responseAsString];
        
        

        NSString * jsessionidCookie;
        NSString * ocajsessionidCookie;
        NSString * acnodeidCookie;
        NSString * csrfToken;
        //check for JSESSIONID
        if ([self checkForString:@"JSESSIONID" in:responseAsData offsetToValue:11 lengthOfValue:32 value:&jsessionidCookie]) {
            self.jsessionid = jsessionidCookie;
        }
        //check for OCAJSESSIONID
        if ([self checkForString:@"OCAJSESSIONID" in:responseAsData offsetToValue:14 lengthOfValue:32 value:&ocajsessionidCookie]) {
            self.ocajsessionid = ocajsessionidCookie;
        }
        //check for ACNODEID
        if ([self checkForString:@"ACNODEID" in:responseAsData offsetToValue:9 lengthOfValue:19 value:&acnodeidCookie]) {
            self.acnodeid = acnodeidCookie;
        }
        //check for CSRF TOKEN
        if ([self checkForString:@"CG_CSRFTOKEN" in:responseAsData offsetToValue:16 lengthOfValue:39 value:&csrfToken]) {
            self.csrf= csrfToken;
        }
        
        return TRUE;
        
    }
    else
    {
        NSLog(@"The command did not return any data");
        return FALSE;
    }
}

-(BOOL) checkForString : (NSString *) strToFind in: (NSData *) httpHeaderAndBody  offsetToValue : (int) offset lengthOfValue: (int) length  value : (NSString **) val
{
    NSData *strToFindAsData = [strToFind dataUsingEncoding:NSUTF8StringEncoding];

    NSRange indexOfData = [httpHeaderAndBody rangeOfData:strToFindAsData  options:0 range:NSMakeRange(0, [httpHeaderAndBody length])];
    
    if (indexOfData.length > 0) {
        NSLog(@"Index Of Data =%i" , (int) indexOfData.location) ;
        // jqXHR.setRequestHeader("CG_CSRFTOKEN", "CK6Q-BJTW-R4OA-P9AB-T1RE-PSJ9-2IEO-8EQ5");
        //NSRange CSRFValue = NSMakeRange(indexOfData.location+16, 39);
        NSRange valueRange = NSMakeRange(indexOfData.location+offset, length);
        NSData *mValueAsData = [httpHeaderAndBody  subdataWithRange:valueRange];
        *val = [[NSString alloc] initWithData:mValueAsData encoding:NSUTF8StringEncoding];
        return TRUE;
    }
    else
    {
        //NSLog(@"%@ not found in the response.",strToFind);
        return FALSE;
    }
    
}
-(BOOL) parseRespone : (NSString *) response
{
    NSData *responseAsData = [response dataUsingEncoding:NSUTF8StringEncoding];
    BOOL didSucceed = FALSE;
    NSError *error = nil;
    if (response) {
        id object = [NSJSONSerialization
                     JSONObjectWithData:responseAsData
                     options:0
                     error:&error];
        if(error) {
             /* JSON was malformed, act appropriately here */
             return FALSE;
        }
        if([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *results = object;
            NSDictionary *ncgapplication = [results objectForKey:@"ncgapplication"];
            NSString *message = [results objectForKey:@"message"];
            NSString *errorcode = [results objectForKey:@"errorcode"];
            for(id __unused key in ncgapplication)
            {
                //NSLog(@"key=%@ value=%@", key, [ncgapplication objectForKey:key]);
            }
            if ([message isEqualToString:@"Done"] && [errorcode isEqualToString:@"0"]) {
                didSucceed = TRUE;
            }

        }
    }

    return didSucceed;

}

@end
