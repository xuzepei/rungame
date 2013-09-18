//
//  CUSinaShareClient.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUSinaShareClient.h"
#import "ASIFormDataRequest.h"

#import "CUShareOAuthView.h"

#import "WBAuthorize.h"
#import "WBRequest.h"
#import "WBSDKGlobal.h"
#import "CUConfig.h"
#import "NSString+URLEncoding.h"
#import "JSONKit.h"
#import "RCTool.h"

#import <stdlib.h>
#import <CommonCrypto/CommonHMAC.h>

//#define OauthType @"OpenId&OpenKey"
#ifndef OauthType
#define OauthType @"Oauth2.0"
#endif

#define kWBAuthorizeURL     @"https://api.weibo.com/oauth2/authorize"
#define kWBAccessTokenURL   @"https://api.weibo.com/oauth2/access_token"
#define kWBSDKAPIDomain             @"https://api.weibo.com/2/"

//< For Sina
#define kSinaKeyCodeLead @"获取到的授权码"
#define kSinaPostImagePath @"http://api.t.sina.com.cn/statuses/upload.json"
#define kSinaPostPath @"http://api.t.sina.com.cn/statuses/update.json"

#ifndef kSinaCountPerRequest
#define kSinaCountPerRequest 200
#endif

#define RT_USER_INFO 0 //登录用户信息
#define RT_FOLLOWING 1 //关注
#define RT_EACHOTHE 2 //相互关注
#define RT_FOLLOWERS 3 //粉丝
#define RT_SEND_MESSAGE 4 //发送消息

#define kSinaUserInfoKey @"sina_user"

//view

@interface  CUSinaShareClient()

@property (nonatomic, assign) BOOL isRequestingUserInfo;

- (void)post:(NSString *)text andImage:(UIImage *)image;

@end

/*
 * 请求参数按KEY的字母顺序排序
 */

static NSInteger sortRequestParams(NSString *key1, NSString *key2, void *params) {
	NSComparisonResult r = [key1 compare:key2];
	if(r == NSOrderedSame) {
		NSDictionary *dict = (NSDictionary *)params;
		NSString *value1 = [dict objectForKey:key1];
		NSString *value2 = [dict objectForKey:key2];
		return [value1 compare:value2];
	}
	return r;
}


/*
 * HMAC_SHA1签名
 */

static NSData *HMAC_SHA1(NSString *data, NSString *key) {
	unsigned char buf[CC_SHA1_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA1, [key UTF8String], [key length], [data UTF8String], [data length], buf);
	return [NSData dataWithBytes:buf length:CC_SHA1_DIGEST_LENGTH];
}


@implementation CUSinaShareClient

#pragma mark -  life

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    if (self = [super init]) {
        if (engine == nil){
            engine = [[WBEngine alloc] initWithAppKey:theAppKey appSecret:theAppSecret];
            [engine setRootViewController:nil];
            [engine setDelegate:self];
            [engine setRedirectURI:kOAuthRedirectURL_sina];
            [engine setIsUserExclusive:NO];
            engine.snsType = @"sina";
            
            WBAuthorize *auth = [[WBAuthorize alloc] initWithAppKey:theAppKey 
                                                          appSecret:theAppSecret];
            [auth setRootViewController:nil];
            [auth setDelegate:engine];
            [auth setRedirectURI:engine.redirectURI];
            
            engine.authorize = auth;
            
            [auth release];
        }
    }
    
    return self;
}

- (void)dealloc
{
    engine.delegate = nil;
    [engine release];
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark -  CUShareClientData
- (NSString *)userId
{
    if ([self isCUAuth])
    {
        return [[engine.userID copy] autorelease];
    }
    
    return nil;
}

- (NSString *)accessToken
{
    if ([self isCUAuth])
    {
        return [[engine.accessToken copy] autorelease];
    }
    
    return nil;
}

- (NSTimeInterval)expireTime
{
    if ([self isCUAuth])
    {
        return engine.expireTime;
    }
    
    return [[NSDate date] timeIntervalSince1970];
}

- (CUShareClientType)clientType
{
    return CUSHARE_SINA;
}

- (NSString *)nickname
{
    if([self isCUAuth])
    {
        NSDictionary* userInfo = [self CUGetAuthorizedUserInfo];
        NSString* nickname = @"";
        if(userInfo && [userInfo isKindOfClass:[NSDictionary class]])
        {
            nickname = [userInfo objectForKey:@"name"];
            if(0 == [nickname length])
                nickname = [userInfo objectForKey:@"screen_name"];
        }
        
        if(0 == [nickname length])
            nickname = @"";

        return nickname;
    }
    
    return @"";
}

- (BOOL)isCUAuth
{
    return [engine isLoggedIn] && ![engine isAuthorizeExpired];
}

- (void)CULogout
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    [engine logOut];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSinaUserInfoKey];
    
    return;
}

- (void)CUSendWithText:(NSString *)text delegate:(id)delegate
{
    return [self CUSendWithText:text andImage:nil delegate:delegate];
}

- (void)CUSendWithText:(NSString *)text andImage:(UIImage *)image delegate:(id)delegate
{
    self.myDelegate = delegate;
    
    if ([text length] == 0) {
        return;
    }
    
    return [self post:text andImage:image];
}

//需要高级授权
- (void)CUSendWithText:(NSString *)text andImageURLString:(NSString *)imageURLString
{
    return [self post:text andImageURLString:imageURLString];
}

- (void)CUGetUserInfo:(NSString *)uid
{
    //https://api.weibo.com/2/users/show.json
    if (![self isCUAuth] || self.isRequestingUserInfo) {
		return ;
	}
    
    NSString * apiPath = @"users/show";
    NSString * httpMehod = @"GET";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:engine.userID forKey:@"uid"];
    [params setObject:engine.accessToken forKey:@"access_token"];
    
    [self addGenerateSigStringFor:apiPath
                            using:httpMehod
                        withParam:nil
                 outputFullParams:&params];
    
	NSString * fullURL = [NSString stringWithFormat:@"%@%@.json", kWBSDKAPIDomain, apiPath];
	WBRequest * request = [WBRequest requestWithURL:fullURL
                                         httpMethod:httpMehod
                                             params:params
                                       postDataType:kWBRequestPostDataTypeNormal
                                   httpHeaderFields:nil
                                           delegate:nil];
    
    self.isRequestingUserInfo = YES;
    [request setCompleteBlock: ^(NSString * responseString){
        DebugLog(@"++++++ Sina Get userInfo: %@", responseString);
        NSDictionary * dict = [responseString objectFromJSONString];
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            NSString * name = [dict objectForKey:@"name"];
            if (0 == [name length])
            {
                name = [dict objectForKey:@"screen_name"];
            }
            engine.nickname = name;
            
            [[NSUserDefaults standardUserDefaults] setValue:responseString forKey:kSinaUserInfoKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        self.isRequestingUserInfo = NO;
//        {
//            "id": 1404376560,
//            "screen_name": "zaku",
//            "name": "zaku",
//            "province": "11",
//            "city": "5",
//            "location": "北京 朝阳区",
//            "description": "人生五十年，乃如梦如幻；有生斯有死，壮士复何憾。",
//            "url": "http://blog.sina.com.cn/zaku",
//            "profile_image_url": "http://tp1.sinaimg.cn/1404376560/50/0/1",
//            "domain": "zaku",
//            "gender": "m",
//            "followers_count": 1204,
//            "friends_count": 447,
//            "statuses_count": 2908,
//            "favourites_count": 0,
//            "created_at": "Fri Aug 28 00:00:00 +0800 2009",
//            "following": false,
//            "allow_all_act_msg": false,
//            "geo_enabled": true,
//            "verified": false,
//            "status": {
//                "created_at": "Tue May 24 18:04:53 +0800 2011",
//                "id": 11142488790,
//                "text": "我的相机到了。",
//                "source": "<a href="http://weibo.com" rel="nofollow">新浪微博</a>",
//                "favorited": false,
//                "truncated": false,
//                "in_reply_to_status_id": "",
//                "in_reply_to_user_id": "",
//                "in_reply_to_screen_name": "",
//                "geo": null,
//                "mid": "5610221544300749636",
//                "annotations": [],
//                "reposts_count": 5,
//                "comments_count": 8
//            },
//            "allow_all_comment": true,
//            "avatar_large": "http://tp1.sinaimg.cn/1404376560/180/0/1",
//            "verified_reason": "",
//            "follow_me": false,
//            "online_status": 0,
//            "bi_followers_count": 215
//        }
    }];
    
    [request setFailureBlock: ^(NSError * error){
        DebugLog(@"++++++ Sina Get userInfo Error: %@", error);
        self.isRequestingUserInfo = NO;
    }];
    
    [params release];
    
	[request connect];
}

- (void)CUGetFollowersWithPage:(NSUInteger)page
                       succeed:(void (^)(NSString *))completeBlock
                       failure:(void (^)(NSError *))failureBlock
{   
    if (![self isCUAuth]) {
		return ;
	}
    
    NSString * apiPath = @"friendships/followers";
    NSString * httpMehod = @"GET";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:engine.userID forKey:@"uid"];
    [params setObject:engine.accessToken forKey:@"access_token"];
    [params setObject:[NSString stringWithFormat:@"%d", kSinaCountPerRequest] forKey:@"count"];
    [params setObject:[NSString stringWithFormat:@"%d",kSinaCountPerRequest*page] forKey:@"cursor"];
    [params setObject:[NSNumber numberWithInt:RT_FOLLOWERS] forKey:@"type"];
    
    [self addGenerateSigStringFor:apiPath
                            using:httpMehod
                        withParam:nil
                 outputFullParams:&params];
    
	NSString * fullURL = [NSString stringWithFormat:@"%@%@.json", kWBSDKAPIDomain, apiPath];
	WBRequest * request = [WBRequest requestWithURL:fullURL
                                         httpMethod:httpMehod
                                             params:params
                                       postDataType:kWBRequestPostDataTypeNormal
                                   httpHeaderFields:nil
                                           delegate:nil];
    [request setCompleteBlock: ^(NSString * responseString){
        DebugLog(@"++++++ Sina Get Followers: %@", responseString);
        completeBlock(responseString);
    }];
    
    [request setFailureBlock: ^(NSError * error){
        DebugLog(@"++++++ Sina Get Followers Error: %@", error);
        failureBlock(error);
    }];
    
    [params release];
    
	[request connect];
}

- (void)CUGetFollowingsWithPage:(NSUInteger)page
                        succeed:(void (^)(NSString *))completeBlock
                        failure:(void (^)(NSError *))failureBlock
{
    if (![self isCUAuth]) {
		return ;
	}
    
    NSString * apiPath = @"friendships/friends";
    NSString * httpMehod = @"GET";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:engine.userID forKey:@"uid"];
    [params setObject:engine.accessToken forKey:@"access_token"];
    [params setObject:[NSString stringWithFormat:@"%d", kSinaCountPerRequest] forKey:@"count"];
    [params setObject:[NSString stringWithFormat:@"%d",kSinaCountPerRequest*page] forKey:@"cursor"];
    [params setObject:[NSNumber numberWithInt:RT_FOLLOWING] forKey:@"type"];
    
    [self addGenerateSigStringFor:apiPath
                            using:httpMehod
                        withParam:nil
                 outputFullParams:&params];
    
	NSString * fullURL = [NSString stringWithFormat:@"%@%@.json", kWBSDKAPIDomain, apiPath];
	WBRequest * request = [WBRequest requestWithURL:fullURL
                                         httpMethod:httpMehod
                                             params:params
                                       postDataType:kWBRequestPostDataTypeNormal
                                   httpHeaderFields:nil
                                           delegate:nil];
    [request setCompleteBlock: ^(NSString * responseString){
        DebugLog(@"++++++ Sina Get Followingss: %@", responseString);
        completeBlock(responseString);
    }];
    
    [request setFailureBlock: ^(NSError * error){
        DebugLog(@"++++++ Sina Get Followings Error: %@", error);
        failureBlock(error);
    }];
    
    [params release];
    
	[request connect];
}

- (void)CUGetFriendsWithPage:(NSUInteger)page
                     succeed:(void (^)(NSString *))completeBlock
                     failure:(void (^)(NSError *))failureBlock
{
    if (![self isCUAuth]) {
		return ;
	}
    
    NSString * apiPath = @"friendships/friends/bilateral";
    NSString * httpMehod = @"GET";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:engine.userID forKey:@"uid"];
    [params setObject:engine.accessToken forKey:@"access_token"];
    [params setObject:[NSString stringWithFormat:@"%d", kSinaCountPerRequest] forKey:@"count"];
    [params setObject:[NSString stringWithFormat:@"%d",kSinaCountPerRequest*page] forKey:@"cursor"];
    [params setObject:[NSNumber numberWithInt:RT_EACHOTHE] forKey:@"type"];
    
    [self addGenerateSigStringFor:apiPath
                            using:httpMehod
                        withParam:nil
                 outputFullParams:&params];
    
	NSString * fullURL = [NSString stringWithFormat:@"%@%@.json", kWBSDKAPIDomain, apiPath];
	WBRequest * request = [WBRequest requestWithURL:fullURL
                                         httpMethod:httpMehod
                                             params:params
                                       postDataType:kWBRequestPostDataTypeNormal
                                   httpHeaderFields:nil
                                           delegate:nil];
    [request setCompleteBlock: ^(NSString * responseString){
        DebugLog(@"++++++ Sina Get Friends: %@", responseString);
        completeBlock(responseString);
    }];
    
    [request setFailureBlock: ^(NSError * error){
        DebugLog(@"++++++ Sina Get Friends Error: %@", error);
        failureBlock(error);
    }];
    
    [params release];
    
	[request connect];
}

- (NSDictionary *)CUGetAuthorizedUserInfo
{
    NSString * infoString = [[NSUserDefaults standardUserDefaults] stringForKey:kSinaUserInfoKey];
    if (nil == infoString)
    {
        if ([self isCUAuth])
        {            
            do {
                infoString = [[NSUserDefaults standardUserDefaults] stringForKey:kSinaUserInfoKey];
                
                if (nil == infoString && !self.isRequestingUserInfo)
                {
                    [self CUGetUserInfo:engine.userID];
                }
                
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            } while (nil == infoString);
        }
    }
    
    return [infoString objectFromJSONString];
}

#pragma mark - Helper

- (NSString *)addGenerateSigStringFor:(NSString *)apiPath using:(NSString *)httpMethod withParam:(NSDictionary *)params outputFullParams:(NSMutableDictionary **)fullParams
{
//    NSString *sigTimeStamp = [NSString stringWithFormat:@"%0.0f", (double)[[NSDate date] timeIntervalSince1970]];
	
	NSMutableArray *paramsArray = [NSMutableArray array];
    
    [*fullParams setValue:engine.appKey forKey:@"oauth_consumer_key"];
    [*fullParams setValue:engine.accessToken forKey:@"access_token"];
    [*fullParams setValue:engine.userID forKey:@"openid"];
    [*fullParams setValue:@"2.a" forKey:@"oauth_version"];
    [*fullParams setValue:@"all" forKey:@"scope"];
    [*fullParams setValue:@"json" forKey:@"format"];
    
    NSString * ip = [RCTool getIpAddress];
    if (nil == ip)
        ip = @"";
    
    [*fullParams setObject:ip forKey:@"clientip"];
    
    DebugLog(@"++fullParams:%@", *fullParams);
	NSArray *sortedKeys = [[*fullParams allKeys] sortedArrayUsingFunction:sortRequestParams context:*fullParams];
	for (NSString *key in sortedKeys) {
		id value = [*fullParams valueForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            [paramsArray addObject:[NSString stringWithFormat:@"%@=%@", key, (NSString *)value]];
        }
	}
	NSString * normalQueryString = [paramsArray componentsJoinedByString:@"&"];
    
    NSString * encodedApiPath = [apiPath hasPrefix:@"/"]? [apiPath URLEncodedString] : [[NSString stringWithFormat:@"/%@", apiPath] URLEncodedString];
	NSString *requestSigBase = [NSString stringWithFormat:@"%@&%@&%@",
                                httpMethod, encodedApiPath, [normalQueryString URLEncodedString]];
    
	NSData *hmacSignature = HMAC_SHA1(requestSigBase, engine.appSecret);
    
	NSString *base64Signature = [RCTool base64forData:hmacSignature];
    DebugLog(@"++Sorted String: %@\r\n++Sig:%@", requestSigBase, base64Signature);
    
    if ([OauthType isEqualToString:@"OpenId&OpenKey"])
    {
        [*fullParams setValue:base64Signature forKey:@"sig"];
    }
    
	return base64Signature;
}



#pragma mark -  CUShareClient


- (NSURLRequest *)CULoginURLRequest
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:engine.appKey, @"client_id",
                            @"code", @"response_type",
                            engine.redirectURI, @"redirect_uri", 
                            @"mobile", @"display", nil];
    NSString *urlString = [WBRequest serializeURL:kWBAuthorizeURL
                                           params:params
                                       httpMethod:@"GET"];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];

    return request;
}

#pragma mark -  common method

- (void)post:(NSString *)text andImage:(UIImage *)image
{
    [engine sendWeiBoWithText:text image:image];
}

- (void)post:(NSString *)text andImageURLString:(NSString *)imageURLString
{
    if ([text length] == 0 && [imageURLString length] == 0) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    
	[params setObject:([text length] ? text : @"") forKey:@"status"];
	
    if ([imageURLString length] != 0)
    {
		[params setObject:imageURLString forKey:@"url"];
        
        [engine loadRequestWithMethodName:@"statuses/upload_url_text.json"
                               httpMethod:@"POST"
                                   params:params
                             postDataType:kWBRequestPostDataTypeMultipart
                         httpHeaderFields:nil];
    }
    else
    {
        [engine loadRequestWithMethodName:@"statuses/upload_url_text.json"
                               httpMethod:@"POST"
                                   params:params
                             postDataType:kWBRequestPostDataTypeMultipart
                         httpHeaderFields:nil];
    }
}

#pragma mark - UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    UIActivityIndicatorView *indicatorView = [self.viewClient getActivityIndicatorView];;
    [indicatorView sizeToFit];
	[indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    UIActivityIndicatorView *indicatorView = [self.viewClient getActivityIndicatorView];
	[indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    UIActivityIndicatorView *indicatorView = [self.viewClient getActivityIndicatorView];
    [indicatorView stopAnimating];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DebugLog(@"%@",request.URL);
    
    NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
    
    if (range.location != NSNotFound)
    {
        NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
        
        // if not canceled
        if (![code isEqualToString:@"21330"])
        {
            [engine.authorize requestAccessTokenWithAuthorizeCode:code];
        }
        
        return NO;
    }
    else
    {
        return YES;
    }
}
#pragma mark - CUShareOAuthViewDelegate
- (void)authViewDidCancel:(CUShareOAuthView *)authView
{
    [self CUNotifyAuthCanceled:self];
}

#pragma mark -  WBEngineDelegate

// If you try to log in with logIn or logInUsingUserID method, and
// there is already some authorization info in the Keychain,
// this method will be invoked.
// You may or may not be allowed to continue your authorization,
// which depends on the value of isUserExclusive.
- (void)engineAlreadyLoggedIn:(WBEngine *)wbEngine
{

}

// Log in successfully.
- (void)engineDidLogIn:(WBEngine *)wbEngine
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self CUGetUserInfo:wbEngine.userID];
    });
    
    [self CUNotifyAuthSucceed:self];
}

// Failed to log in.
// Possible reasons are:
// 1) Either username or password is wrong;
// 2) Your app has not been authorized by Sina yet.
- (void)engine:(WBEngine *)anEngine didFailToLogInWithError:(NSError *)error
{
    [self CUNotifyAuthFailed:self withError:error];
}

// Log out successfully.
- (void)engineDidLogOut:(WBEngine *)wbEngine
{
    [self CUNotifyLoginout:self];
}

// When you use the WBEngine's request methods,
// you may receive the following four callbacks.
- (void)engineNotAuthorized:(WBEngine *)wbEngine
{
    [self CUNotifyShareFailed:self withError:nil];
}

- (void)engineAuthorizeExpired:(WBEngine *)wbEngine
{
    [self CUNotifyAuthFailed:self withError:nil];
}

- (void)engine:(WBEngine *)wbEngine requestDidFailWithError:(NSError *)error
{
    //[self CUNotifyShareFailed:self withError:error];
    
    CCLOG(@"error:%@",[error description]);
    
    if(self.myDelegate && [self.myDelegate respondsToSelector:@selector(sendTextFailed:)])
    {
        [self.myDelegate sendTextFailed:SHT_SINA];
    }
}

- (void)engine:(WBEngine *)wbEngine requestDidSucceedWithResult:(id)result
{
    //[self CUNotifyShareSucceed:self];
    
    if(self.myDelegate && [self.myDelegate respondsToSelector:@selector(sendTextSucceeded:)])
    {
        [self.myDelegate sendTextSucceeded:SHT_SINA];
    }
}

@end
