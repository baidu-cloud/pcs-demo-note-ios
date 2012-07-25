//
//  BaiduOAuthSdk.m
//  BaiduOAuthSdk
//
//  Created by YM on 7/24/12.
//  Copyright (c) 2012 baidu. All rights reserved.
//

#import "BaiduOAuthSdk.h"

// the open url
#define BAIDUOPENIDURL @"https://openapi.baidu.com/oauth/2.0/authorize?response_type=token&redirect_uri=oob&display=mobile&scope=basic netdisk&client_id="

// the url to indicate login successfully
#define LOGINSUCCESSURL @"login_success"

// the url to indicate register successfully
#define REGISTERSUCCESSFUL @"wap.baidu.com/?"

// the key to indicate login failed
#define LOGINERRORACCESSDENIED @"error=access_denied"

// the url and parameter separator
#define URLSEPARATOR @"#"

// the parameter separator
#define PARAMETERSEPARATOR @"&"

// the token separator
#define ACCESSTOKENSEPARATOR @"="

// the argument index
#define ARGUMENTINDEX 1

// the key of access token
#define KEYOFACCESSTOKEN @"access_token"

// key : session secret
#define KEYSESSIONSECRET @"session_secret"

// key : session key
#define KEYSESSIONKEY @"session_key"

// key : expires_in
#define KEYEXPIRESIN @"expires_in"

// key : refresh token
#define KEYREFRESHTOKEN @""

// login denied
#define INFOACCESSDENIED @"access denied"

// user account url
#define USERACCOUNTURL @"https://openapi.baidu.com/rest/2.0/passport/users/getInfo"

// key : username
#define KEY_USERNAME @"username"

// key : userid
#define KEY_USERID @"userid"

// token index
#define ACCESSTOKENINDEX 1

// the currect item count
#define CURRECTITEMCOUNT 2

@implementation BaiduOAuthSdk

@synthesize apiKey;
@synthesize mpWebView;
@synthesize mpDelegate;
@synthesize accessToken;
@synthesize sessionKey;
@synthesize sessionSecret;
@synthesize expires;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        apiKey = nil;
        accessToken = nil;
        sessionSecret = nil;
        sessionKey = nil;
        expires = 0;
    }
    return self;
}

- (void) performBaiduOAuthWithApiKey:(NSString *) appApiKey
{
    mpWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [self.view addSubview:mpWebView];
    self.view.frame = CGRectMake(0, 0, 320, 480);
    
    mpWebView.delegate = self;
    self.apiKey = appApiKey;
    NSString *url = [NSString stringWithFormat:@"%@%@", BAIDUOPENIDURL, self.apiKey];
    NSLog(@"url : %@", url);
    
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"%25" withString:@"%"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:url]];
    [mpWebView loadRequest:request];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSLog(@" hello world! ");
    
    
    
    NSURL *url = [request URL];
    NSString *path = [url absoluteString];
    
    BOOL ret = YES;
    
    if(path){
        NSRange range = [path rangeOfString:LOGINSUCCESSURL];
        BOOL found = NO;
        
        if(NSNotFound != range.location){
            
            found = YES;
            
            NSArray *array = [path componentsSeparatedByString:URLSEPARATOR];
            
            if(array && array.count >= CURRECTITEMCOUNT){
                
                NSString *args = [array objectAtIndex:ARGUMENTINDEX];
                if(args){
                    array = [args componentsSeparatedByString:PARAMETERSEPARATOR];
                    
                    for(int i = 0; i < array.count; ++i){
                        NSString *tmp = [array objectAtIndex:i];
                        
                        // get the access token
                        if(tmp && [tmp hasPrefix:KEYOFACCESSTOKEN]){
                            NSArray *item = [tmp componentsSeparatedByString:ACCESSTOKENSEPARATOR];
                            
                            if(item && item.count >= CURRECTITEMCOUNT){
                                accessToken = [item objectAtIndex:ACCESSTOKENINDEX];
                            }
                        }
                        
                        // get session secret
                        if(tmp && [tmp hasPrefix:KEYSESSIONSECRET]){
                            NSArray *item = [tmp componentsSeparatedByString:ACCESSTOKENSEPARATOR];
                            
                            if(item && item.count >= CURRECTITEMCOUNT){
                                sessionSecret = [item objectAtIndex:ACCESSTOKENINDEX];
                            }
                        }
                        
                        // get session key
                        if(tmp && [tmp hasPrefix:KEYSESSIONKEY]){
                            NSArray *item = [tmp componentsSeparatedByString:ACCESSTOKENSEPARATOR];
                            
                            if(item && item.count >= CURRECTITEMCOUNT){
                                sessionKey = [item objectAtIndex:ACCESSTOKENINDEX];
                            }
                        }
                        
                        // get session key
                        if(tmp && [tmp hasPrefix:KEYEXPIRESIN]){
                            NSArray *item = [tmp componentsSeparatedByString:ACCESSTOKENSEPARATOR];
                            
                            if(item && item.count >= CURRECTITEMCOUNT){
                                NSString *expiresIn = [item objectAtIndex:ACCESSTOKENINDEX];
                                
                                if(expiresIn){
                                    expires = [[NSDate date] timeIntervalSince1970] + [expiresIn longLongValue];
                                }
                            }
                        }
                    }
                }
            }
            
            if(mpDelegate){
                if(accessToken && accessToken.length > 0){
                    [mpDelegate onComplete:accessToken];
                    [self dismissModalViewControllerAnimated:YES];
                    self.view.hidden = YES;
                    ret = NO;
                    
                    [self clearCookies];
                }
            }
             
        }
        
        if(NO == found){
            range = [path rangeOfString:REGISTERSUCCESSFUL];
            if(NSNotFound != range.location){
                [self performSelector:@selector(makeWebviewLoadLoginUrl) withObject:nil afterDelay:0];
                ret = NO;
                found = YES;
            }
            
        }
        
        if(NO == found){
            range = [path rangeOfString:LOGINERRORACCESSDENIED];
            
            if(NSNotFound != range.location){
                
                
                if(mpDelegate){
                    [mpDelegate onError:INFOACCESSDENIED];
                    [self dismissModalViewControllerAnimated:YES];
                    ret = NO;
                    
                    [self clearCookies];
                }
                 
            }
        }
    }
    
    return ret;
}

//
// clear cookies
//
-(void)clearCookies
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
}

//
// view finish loading, get cookie
//
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

//
// view started.......
//
-(void)webViewDidStartLoad:(UIWebView *)webView
{
}

//
// fail load
//
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}
































@end
