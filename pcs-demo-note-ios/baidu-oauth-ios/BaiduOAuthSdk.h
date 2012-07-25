//
//  BaiduOAuthSdk.h
//  BaiduOAuthSdk
//
//  Created by YM on 7/24/12.
//  Copyright (c) 2012 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BaiduOAuthDelegate <NSObject>

// Successfully get token
-(void)onComplete:(NSString*)token;
// Failed to get access token
-(void)onError:(NSString*)error;
// OAuth Canceled
-(void)onCancel;

@end

@interface BaiduOAuthSdk : UIViewController <UIWebViewDelegate>

// api key
@property (strong, nonatomic) NSString *apiKey;

// access token
@property (strong, nonatomic) NSString *accessToken;

// session secret
@property (strong, nonatomic) NSString *sessionSecret;

// session key
@property (strong, nonatomic) NSString *sessionKey;

// expire date
@property (assign, nonatomic) long long expires;

// webview
@property (strong, nonatomic) IBOutlet UIWebView *mpWebView;

// delegate
@property (unsafe_unretained, nonatomic) id<BaiduOAuthDelegate> mpDelegate;


// APIs
- (void) performBaiduOAuthWithApiKey:(NSString *)apiKey;

@end



















