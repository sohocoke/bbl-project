//
//  UploadToAppC.m
//  mm2PackagingFactory
//
//  Created by jeremy brookfield on 28/03/14.
//

#import "UploadToAppC.h"
#import "NSData+NSDataAdditions.h"
#import "NSString+NSStringAdditions.h"

@interface UploadToAppC ()

@property (nonatomic, strong, readwrite) NSURLConnection *      connection;
@property (nonatomic, strong, readwrite) NSTimer *              earlyTimeoutTimer;
@property (nonatomic, assign, readwrite) BOOL                   httpResponse2XX;
@property (nonatomic, assign, readwrite) BOOL                   httpResponse3XX;
@property (nonatomic, copy,   readwrite) NSString *             filePath;
@property (nonatomic, strong, readwrite) NSOutputStream *       fileStream;
@property (nonatomic, strong, readwrite) NSString *             jsessionid;
@property (nonatomic, strong, readwrite) NSString *             acnodeid;
@property (nonatomic, strong, readwrite) NSString *             csrf;
@property (nonatomic, strong, readwrite) NSMutableData *        receivedData;
@end



@implementation UploadToAppC
/*
 
 UrlRequest* theRequest = [NSMutableUrlRequest ...]
 [MyClass httpAuthorizeRequest:theRequest withUsername:@"someuser" andPassword:@"mysecret"];
 // snip
 
 + (void)httpAuthorizeRequest:(NSMutableURLRequest*)request withUsername:(NSString*)username andPassword:(NSString*)password
 {
 NSString* authorizationToken = [[NSString stringWithFormat:@"%@:%@", username, password] base64Representation];
 [request setValue:[NSString stringWithFormat:@"Basic %@", authorizationToken] forHTTPHeaderField:@"Authorization"];
 }
 int main (int argc, const char * argv[]) {
 NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
 
 NSString *key = @"my password";
 NSString *secret = @"text to encrypt";
 
 NSData *plain = [secret dataUsingEncoding:NSUTF8StringEncoding];
 NSData *cipher = [plain AES256EncryptWithKey:key];
 printf("%s\n", [[cipher description] UTF8String]);
 
 plain = [cipher AES256DecryptWithKey:key];
 printf("%s\n", [[plain description] UTF8String]);
 printf("%s\n", [[[NSString alloc] initWithData:plain encoding:NSUTF8StringEncoding] UTF8String]);
 
 [pool drain];
 return 0;
 }
*/

- (instancetype)init

{
    if ((self = [super init])) {
        NSLog(@"UploadToAppC : init");
	}
	return self;
}

-(NSData* ) open {


    NSError *err=nil;
    //[UploadToAppC httpAuthorizeRequest:mURLRequest withUsername:@"Administrator"  andPassword:@"password"];

    NSURLResponse *mURLResponse = NULL;
    UploadToAppC *uploadToAppC = [[UploadToAppC alloc] init];
    uploadToAppC.receivedData = [NSMutableData dataWithLength:20000]; //initialize receivedData
    
    NSLog(@"%@",@"INITIAL CALL TO APPC");
    //    $command="$curlFolder\curl.exe ""https://$AppCFQDN`:4443/"" -H ""Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"" -H ""Connection: keep-alive"" -H ""Accept-Encoding: gzip,deflate,sdch"" -H ""Cookie: ACNODEID=$ACNODEID"" -H ""Accept-Language: en-US,en;q=0.8"" -H ""User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"" --compressed -k"
    
    NSURL *mURL = [NSURL URLWithString:@"https://161.202.193.123:4443/"];
    NSMutableURLRequest *mURLRequest = [NSMutableURLRequest requestWithURL:mURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0f];
    
    [mURLRequest setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept:"];
    [mURLRequest setValue:@"keep-alive"                     forHTTPHeaderField:@"Connection:"];
    [mURLRequest setValue:@"gzip,deflate,sdch"              forHTTPHeaderField:@"Accept-Encoding:"];
    [mURLRequest setValue:@"ACNODEID="                      forHTTPHeaderField:@"Cookie:"];
    [mURLRequest setValue:@"Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"   forHTTPHeaderField:@"User-Agent:"];
    [mURLRequest setValue:@"en-US,en;q=0.8"                 forHTTPHeaderField:@"Accept-Language:"];

    [uploadToAppC sendSynchronousRequest:mURLRequest returningResponse:&mURLResponse error:&err];

    
    NSLog(@"%@",@"\n\n\n\nCALL TO GET JESSIONID AND ACNODEID");
    //CALL TO GET JESSIONID AND ACNODEID
    [mURLRequest setURL:[NSURL URLWithString:@"https://161.202.193.123:4443/ControlPoint/JavaScriptServlet"]];

    [mURLRequest setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept:"];
    [mURLRequest setValue:@"keep-alive"                     forHTTPHeaderField:@"Connection:"];
    [mURLRequest setValue:@"gzip,deflate,sdch"              forHTTPHeaderField:@"Accept-Encoding:"];
    [mURLRequest setValue:@"ACNODEID="                      forHTTPHeaderField:@"Cookie:"];
    [mURLRequest setValue:@"W/""""3603-1382729108000"""""   forHTTPHeaderField:@"If-None-Match:"];
    [mURLRequest setValue:@"Fri, 25 Oct 2013 19:25:08 GMT"  forHTTPHeaderField:@"If-Modified-Since:"];
    [mURLRequest setValue:@"Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"   forHTTPHeaderField:@"User-Agent:"];
    [mURLRequest setValue:@"en-US,en;q=0.8"                 forHTTPHeaderField:@"Accept-Language:"];

    [uploadToAppC sendSynchronousRequest:mURLRequest returningResponse:&mURLResponse error:&err];

    
    NSLog(@"%@",@"\n\n\n\nGET CG_CSRF FROM APPC");
    //GET CG_CSRF FROM APPC
    //$command="$curlFolder\curl.exe ""https://$AppCFQDN`:4443/ControlPoint/JavaScriptServlet"" -H ""Accept-Encoding: gzip,deflate,sdch"" -H ""Accept-Language: en-US,en;q=0.8"" -H ""User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"" -H ""Accept: */*"" -H ""Referer: https://$AppCFQDN`:4443/ControlPoint/"" -H ""Cookie: JSESSIONID=$JSESSION; ACNODEID=$ACNODEID"" -H ""Connection: keep-alive"" --compressed -k"
  
    [uploadToAppC.receivedData setLength:0]; //clear receivedData
    [mURLRequest setURL:[NSURL URLWithString:@"https://161.202.193.123:4443/ControlPoint/JavaScriptServlet"]];
    NSString *cookieString = [NSString stringWithFormat:@"%@%@; %@%@",@"JSESSIONID=",uploadToAppC.jsessionid,@"ACNODEID=",uploadToAppC.acnodeid];
    [mURLRequest setValue:@"*/*" forHTTPHeaderField:@"Accept:"];
    [mURLRequest setValue:cookieString forHTTPHeaderField:@"Cookie:"];
    [mURLRequest setValue:@"https://161.202.193.123:4443/ControlPoint/" forHTTPHeaderField:@"Referer:"];
    [uploadToAppC sendSynchronousRequest:mURLRequest returningResponse:&mURLResponse error:&err];
 
    
    NSLog(@"%@",@"CHECK TO MAKE SURE COOKIES ARE CORRECT");
    //#CHECK TO MAKE SURE COOKIES ARE CORRECT
    //$command="$curlFolder\curl.exe ""https://$AppCFQDN`:4443/ControlPoint/rest/sharefilegtwy"" -H ""Cookie: JSESSIONID=$JSESSION; ACNODEID=$ACNODEID"" -H ""Accept-Encoding:gzip,deflate,sdch"" -H ""Accept-Language: en-US,en;q=0.8"" -H ""User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"" -H ""Accept: application/json, text/javascript, */*; q=0.01"" -H ""Referer: https://$AppCFQDN`:4443/ControlPoint/"" -H ""CG_CSRFTOKEN: $CSRF"" -H ""X-Requested-With: CloudGateway AJAX"" -H ""Connection: keep-alive"" --compressed -k"
    
    [uploadToAppC.receivedData setLength:0]; //clear receivedData
    [mURLRequest setURL:[NSURL URLWithString:@"https://161.202.193.123:4443/ControlPoint/rest/sharefilegtwy"]];
    [mURLRequest setValue:cookieString                      forHTTPHeaderField:@"Cookie:"];
    [mURLRequest setValue:@"gzip,deflate,sdch"              forHTTPHeaderField:@"Accept-Encoding:"];
    [mURLRequest setValue:@"en-US,en;q=0.8"                 forHTTPHeaderField:@"Accept-Language:"];
    [mURLRequest setValue:@"Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"   forHTTPHeaderField:@"User-Agent:"];
    [mURLRequest setValue:@"application/json, text/javascript, */*; q=0.01" forHTTPHeaderField:@"Accept:"];
    [mURLRequest setValue:@"https://161.202.193.123:4443/ControlPoint/" forHTTPHeaderField:@"Referer:"];
    [mURLRequest setValue:uploadToAppC.csrf                 forHTTPHeaderField:@"CG_CSRFTOKEN:"];
    [mURLRequest setValue:@"CloudGateway AJAX"              forHTTPHeaderField:@"X-Requested-With:"];
    [mURLRequest setValue:@"keep-alive"                     forHTTPHeaderField:@"Connection:"];
    //NSDictionary *allHTTPHeaderFields = [mURLRequest allHTTPHeaderFields];
    
    [uploadToAppC sendSynchronousRequest:mURLRequest returningResponse:&mURLResponse error:&err];
    
    
//    [uploadToAppC.receivedData setLength:0]; //clear receivedData
//    [mURLRequest setURL:[NSURL URLWithString:@"https://161.202.193.123:4443/ControlPoint/rest/sharefilegtwy/index.html"]];
//    NSString *post =[NSString stringWithFormat:@"CG_CSRFTOKEN=%@",uploadToAppC.csrf];
//    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
//    NSString *postLength = [NSString stringWithFormat:@"%d", (int) [postData length]];
//    [mURLRequest setHTTPMethod:@"POST"];
//    [mURLRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [mURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [mURLRequest setHTTPBody:postData];
//    [uploadToAppC sendSynchronousRequest:mURLRequest returningResponse:&mURLResponse error:&err];
    /*
     <!DOCTYPE HTML>
     <html>
     <body>
     <form name="autoForm" action="index&#46;html" method="post" ><input type="hidden" name="CG_CSRFTOKEN" value="ZZX1-GTFO-11OO-H5F1-AKX5-O2UB-F2IG-1SOV"/>
     </form>
     <script>
     document.forms.autoForm.submit();
     </script>
     </body>
     </html>
     */
    
    
    
    NSLog(@"\n\n\n\n%@",@"LOGIN TO APPC WITH PASSWORD");
    
    //#LOGIN TO APPC WITH PASSWORD
    //$command="$curlFolder\curl.exe ""https://$AppCFQDN`:4443/ControlPoint/rest/newlogin"" -H ""Cookie: JSESSIONID=$JSESSION; ACNODEID=$ACNODEID"" -H ""Origin: https://$AppCFQDN`:4443"" -H ""Accept-Encoding: gzip,deflate,sdch"" -H ""Accept-Language: en-US,en;q=0.8"" -H ""User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"" -H ""Content-Type: application/json;charset=UTF-8"" -H ""Accept: application/json, text/javascript, */*; q=0.01"" -H ""Referer: https://$AppCFQDN`:4443/ControlPoint/"" -H ""CG_CSRFTOKEN: $CSRF"" -H ""X-Requested-With: CloudGateway AJAX"" -H ""Connection: keep-alive"" --data '`@$loginTextfile' --compressed -k"
    [uploadToAppC.receivedData setLength:0]; //clear receivedData
    [mURLRequest setURL:[NSURL URLWithString:@"https://161.202.193.123:4443/ControlPoint/rest/newlogin"]];
    [mURLRequest setValue:@"https://161.202.193.123:4443" forHTTPHeaderField:@"Origin:"];
    NSString *post = @"{\"ncglogin\":{\"adminid\":\"Administrator\",\"password\":\"passwordXXXXX\"}}";
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int) [postData length]];
    [mURLRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mURLRequest setHTTPMethod:@"POST"];
    [mURLRequest setHTTPBody:postData];

    [uploadToAppC sendSynchronousRequest:mURLRequest returningResponse:&mURLResponse error:&err];
    
    //    [mURLRequest setURL:[NSURL URLWithString:@"https://161.202.193.123:4443/ControlPoint/rest/sharefilegtwy/index.html"]];
    //    NSString *post =[NSString stringWithFormat:@"CG_CSRFTOKEN=%@",uploadToAppC.csrf];
    //    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    //    NSString *postLength = [NSString stringWithFormat:@"%d", (int) [postData length]];
    //    [mURLRequest setHTTPMethod:@"POST"];
    //    [mURLRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //    [mURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //    [mURLRequest setHTTPBody:postData];
    return nil;
}

+ (void)httpAuthorizeRequest:(NSMutableURLRequest*)request withUsername:(NSString*)username andPassword:(NSString*)password
{
    NSData* data = [[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
    __unused NSString* authorizationToken = [NSString base64StringFromData: data length:(int)data.length];
    [request setValue:[NSString stringWithFormat:@"Basic %@", authorizationToken] forHTTPHeaderField:@"Authorization"];
}


#pragma mark URL Handling



- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse* __strong*)response error:(NSError* __strong*)error
{
    NSLog(@"--->sendSynchronousRequest using CFRunLoopRun ");
    NSMutableData *receivedData =[NSMutableData new];
    
    NSURLConnection* conn = [NSURLConnection connectionWithRequest:request delegate:self];
    [conn start];
    CFRunLoopRun();
    NSLog(@"<---sendSynchronousRequest");
    
    
    return receivedData;

}


- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response // called by the NSURLConnection when the request/response exchange is complete.
{
    NSLog(@"--->didReceiveResponse");
    #pragma unused(conn)
    NSHTTPURLResponse * httpResponse;
    
    NSLog(@"%@", @"Received a response from this server");
    
    httpResponse = (NSHTTPURLResponse *) response;
    
    
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) == 2)
    {
        self.httpResponse2XX = YES;
        NSLog(@"%@" "%zd", @"Success : Response receieved : ",httpResponse.statusCode);
        NSLog(@"%@",httpResponse.debugDescription);
        NSArray *cookies = [[NSArray alloc] init];
        cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[httpResponse allHeaderFields] forURL:[NSURL URLWithString:@""]];
        for (NSHTTPCookie *cookie in cookies) {
            NSLog(@"we were returned a cookie :  %@ , %@ ",cookie.name, cookie.value);
            if ([cookie.name isEqualToString:@"JSESSIONID"] )   self.jsessionid = cookie.value;
            if ([cookie.name isEqualToString:@"ACNODEID"] )     self.acnodeid = cookie.value;
        }
    }
    else if ((httpResponse.statusCode / 100) == 3)
    {
        self.httpResponse3XX = YES;
        NSLog(@"%@" "%zd", @"Success : Redirection request received - However we will not follow it : ",httpResponse.statusCode);
    }
    
    else
    {
        self.httpResponse2XX = NO;
        self.httpResponse3XX = NO;
        NSLog(@"%@" "%zd", @"Response NOK : ",httpResponse.statusCode);
    }
    NSLog(@"<---didReceiveResponse");
}


- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data // A delegate method called by the NSURLConnection as data arrives.
{
    NSLog(@"--->didReceiveData");
    
    [self.receivedData appendData:data];

    NSLog(@"------> received %i bytes ", (int) data.length);
    NSLog(@"------> total received %i bytes ", (int) [self.receivedData length]);

    NSLog(@"<---didReceiveData");
}


- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error // A delegate method called by the NSURLConnection if the connection fails.
{
    NSLog(@"--->didFailWithError");
    NSLog(@"%@  %@", @"Connection failed with" ,error);
    CFRunLoopStop(CFRunLoopGetCurrent());
    NSLog(@"<---didFailWithError");
}


- (void)connectionDidFinishLoading:(NSURLConnection *)conn // A delegate method called by the NSURLConnection when the connection has been done successfully.
{
    NSLog(@"--->connectionDidFinishLoading");
    NSLog(@"%@", @"Finished loading");
    
    if (self.httpResponse2XX){
        NSString    *receivedDataAsString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",receivedDataAsString);

        NSData *csrf = [@"CG_CSRFTOKEN" dataUsingEncoding:NSUTF8StringEncoding];
        
        NSRange indexOfData = [self.receivedData rangeOfData:csrf  options:0 range:NSMakeRange(0, [self.receivedData length])];
        
        if (indexOfData.length > 0) {
            NSLog(@"Index Of Data =%i" , (int) indexOfData.location) ;
            // jqXHR.setRequestHeader("CG_CSRFTOKEN", "CK6Q-BJTW-R4OA-P9AB-T1RE-PSJ9-2IEO-8EQ5");
            NSRange CSRFValue = NSMakeRange(indexOfData.location+16, 39);
            NSData *mCSRFValueAsData = [self.receivedData subdataWithRange:CSRFValue];
            self.csrf = [[NSString alloc] initWithData:mCSRFValueAsData encoding:NSUTF8StringEncoding];
        }
        else{
            NSLog(@"Data not found ...");
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ";
        NSLog(@"Connection Succeeded at %@", [formatter stringFromDate:[NSDate date]]);
    }
    else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ";
        NSLog(@"Connection FA.ILED at %@", [formatter stringFromDate:[NSDate date]]);
    }
    
    CFRunLoopStop(CFRunLoopGetCurrent());
    NSLog(@"<---connectionDidFinishLoading");
}


- (void)connection:(NSURLConnection *)conn didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge // A delegate method called by the NSURLConnection when you accept a specificauthentication challenge by returning YES from -connection:canAuthenticateAgainstProtectionSpace:..
{
    NSLog(@"--->didReceiveAuthenticationChallenge");
    assert(challenge != nil);
    NSString *authenticationMethod = [[challenge protectionSpace] authenticationMethod];
    
    NSLog(@"We have received an authentication challenge of type : %@", [[challenge protectionSpace] authenticationMethod]);
    
    
    if ([authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"] )
    {
        NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
        assert(protectionSpace != nil);
        
        SecTrustRef trust = [protectionSpace serverTrust];
        assert(trust != NULL);
        
        NSURLCredential * mcredential = [NSURLCredential credentialForTrust:trust];
        assert(mcredential != nil);
        
        SecCertificateRef serverCert = SecTrustGetLeafCertificate(trust);
        if (serverCert != NULL  ) {
            
            CFStringRef summaryRef = SecCertificateCopySubjectSummary(serverCert);
            NSLog(@"The subject name in the server's certificate is : %@ ", summaryRef);
        }
        
        [[challenge sender] useCredential:mcredential forAuthenticationChallenge:challenge];
    }
    
    
    //NSURLAuthenticationMethodClientCertificate
    
    if ([authenticationMethod isEqualToString:@"NSURLAuthenticationMethodClientCertificate"] )
    {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Y167045" ofType:@"p12"];
        NSData *p12data = [NSData dataWithContentsOfFile:path];
        CFDataRef inP12data = (__bridge CFDataRef)p12data;
        
        SecIdentityRef myIdentity;
        SecTrustRef myTrust;
        OSStatus oSstatus = extractIdentityAndTrust(inP12data, &myIdentity, &myTrust);
        if (oSstatus == 0){
            NSLog(@"[EMP DIAG : SSL] extractIdentityAndTrust succeeded");
        }
        SecCertificateRef myCertificate;
        SecIdentityCopyCertificate(myIdentity, &myCertificate);
        const void *certs[] = { myCertificate };
        CFArrayRef certsArray = CFArrayCreate(NULL, certs, 1, NULL);
        
        NSURLCredential *credential = [NSURLCredential credentialWithIdentity:myIdentity certificates:(__bridge NSArray*)certsArray persistence:NSURLCredentialPersistencePermanent];
        
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
    NSLog(@"[EMP DIAG : SSL]<---didReceiveAuthenticationChallenge");
    
}


static SecCertificateRef SecTrustGetLeafCertificate(SecTrustRef trust) // Returns the leaf certificate from a SecTrust object (that is always the certificate at index 0).
{
    SecCertificateRef   result;
    
    assert(trust != NULL);
    
    if (SecTrustGetCertificateCount(trust) > 0) {
        result = SecTrustGetCertificateAtIndex(trust, 0);
        assert(result != NULL);
    } else {
        result = NULL;
    }
    return result;
}


OSStatus extractIdentityAndTrust(CFDataRef inP12data, SecIdentityRef *identity, SecTrustRef *trust)
{
    OSStatus securityError = errSecSuccess;
    
    CFStringRef password = CFSTR("citrix");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inP12data, options, &items);
    
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemTrust);
        *trust = (SecTrustRef)tempTrust;
    }
    
    if (options) {
        CFRelease(options);
    }
    
    return securityError;
}

- (BOOL)connection:(NSURLConnection *)conn canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
// A delegate method called by the NSURLConnection when something happens with the connection security-wise.
{
    NSLog(@"--->canAuthenticateAgainstProtectionSpace");
    assert(protectionSpace != nil);
    NSLog(@"<---canAuthenticateAgainstProtectionSpace");
    return TRUE;
}

- (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
    
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }
    
    return result;
}



@end
