//
//  CUTencentShareClient.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-16.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUTencentShareClient.h"
#import "ASIFormDataRequest.h"

#import "CUShareOAuthView.h"

#import "WBAuthorize.h"
#import "WBRequest.h"
#import "WBSDKGlobal.h"
#import "CUConfig.h"
#import "JSONKit.h"
#import "NSString+URLEncoding.h"
#import "RCTool.h"

#import <stdlib.h>
#import <CommonCrypto/CommonHMAC.h>

//#define OauthType @"OpenId&OpenKey"
#ifndef OauthType
#define OauthType @"Oauth2.0"
#endif

#define kQQAuthorizeURL     @"https://open.t.qq.com/cgi-bin/oauth2/authorize"
#define kQQAccessTokenURL   @"https://open.t.qq.com/cgi-bin/oauth2/access_token"
#define kQQRestserverBaseURL  @"https://open.t.qq.com/api/"

#define kQQUserInfoKey @"qq_user"

////< For Sina
//#define kSinaKeyCodeLead @"获取到的授权码"
//#define kSinaPostImagePath @"http://api.t.sina.com.cn/statuses/upload.json"
//#define kSinaPostPath @"http://api.t.sina.com.cn/statuses/update.json"

//view

@interface  CUTencentShareClient()

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

@implementation CUTencentShareClient

#pragma mark -  life

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    if (self = [super init]) {
        if (engine == nil){
            engine = [[WBEngine alloc] initWithAppKey:theAppKey appSecret:theAppSecret];
            [engine setRootViewController:nil];
            [engine setDelegate:self];
            [engine setRedirectURI:kOAuthRedirectURL_tencent];
            [engine setIsUserExclusive:NO];
            engine.snsType = @"qq";
            
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
    return CUSHARE_QQ;
}

- (NSString *)nickname
{
    if([self isCUAuth])
    {
        NSDictionary* userInfo = [self CUGetAuthorizedUserInfo];
        NSString* nickname = @"";
        if(userInfo && [userInfo isKindOfClass:[NSDictionary class]])
        {
            nickname = [userInfo objectForKey:@"nick"];
            if(0 == [nickname length])
                nickname = [userInfo objectForKey:@"name"];
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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kQQUserInfoKey];
    
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
    
    //return [self post:text andImage:image];
    NSString * apiPath = image? @"t/add_pic" : @"t/add";
    NSString * httpMehod = @"POST";
    WBRequestPostDataType dataType = image? kWBRequestPostDataTypeMultipart : kWBRequestPostDataTypeNormal;
    
    NSMutableDictionary * fullParams = [[NSMutableDictionary alloc] init];
    [fullParams setValue:text forKey:@"content"];
    
    [self addGenerateSigStringFor:apiPath
                            using:httpMehod
                        withParam:nil
                 outputFullParams:&fullParams];
    
	NSString * fullURL = [kQQRestserverBaseURL stringByAppendingString:apiPath];
	WBRequest * request = [WBRequest requestWithURL:fullURL
                                         httpMethod:httpMehod
                                             params:fullParams
                                       postDataType:dataType
                                   httpHeaderFields:nil
                                           delegate:nil];
    if (image)
    {
        //添加图片表单域pic
        [request addPostImage:image forKey:@"pic"];
    }
    [request setCompleteBlock: ^(NSString * responseString){
        DebugLog(@"++++++ Tecent Send Text Succeed: %@", responseString);
        
        //[self CUNotifyShareSucceed:self];
        
        if(self.myDelegate && [self.myDelegate respondsToSelector:@selector(sendTextSucceeded:)])
        {
            [self.myDelegate sendTextSucceeded:SHT_QQ];
        }
    }];
    
    [request setFailureBlock: ^(NSError * error){
        DebugLog(@"++++++ Tecent Get Followers Error: %@", error);
        
        //[self CUNotifyAuthFailed:self withError:error];
        
        if(self.myDelegate && [self.myDelegate respondsToSelector:@selector(sendTextFailed:)])
        {
            [self.myDelegate sendTextFailed:SHT_QQ];
        }
        
    }];
    
    [fullParams release];
    
	[request connect];

}

//需要高级授权
- (void)CUSendWithText:(NSString *)text andImageURLString:(NSString *)imageURLString
{
    return [self post:text andImageURLString:imageURLString];
}

- (void)CUGetUserInfo:(NSString *)uid
{
    if (![self isCUAuth] || self.isRequestingUserInfo) {
		return ;
	}
    
    NSString * apiPath = @"user/info";
    NSString * httpMehod = @"GET";
    
    NSMutableDictionary * fullParams = [[NSMutableDictionary alloc] init];
    
    [self addGenerateSigStringFor:apiPath
                            using:httpMehod
                        withParam:nil
                 outputFullParams:&fullParams];
    
	NSString * fullURL = [kQQRestserverBaseURL stringByAppendingString:apiPath];
	WBRequest * request = [WBRequest requestWithURL:fullURL
                                         httpMethod:httpMehod
                                             params:fullParams
                                       postDataType:kWBRequestPostDataTypeNormal
                                   httpHeaderFields:nil
                                           delegate:nil];
    
    self.isRequestingUserInfo = YES;
    [request setCompleteBlock: ^(NSString * responseString){
        DebugLog(@"++++++ Tecent Get userInfo: %@", responseString);
        NSDictionary * response = [responseString objectFromJSONString];
        if ([response isKindOfClass:[NSDictionary class]] && 0 == [[response objectForKey:@"ret"] integerValue])
        {
            //成功
            NSString * infoString = [[response objectForKey:@"data"] JSONString];
            [[NSUserDefaults standardUserDefaults] setValue:infoString forKey:kQQUserInfoKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            //失败
            int64_t delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self CUGetUserInfo:uid];
            });
        }
        self.isRequestingUserInfo = NO;
//        {
//            errcode : 0,
//            msg : ok,
//            ret : 0,
//            data :
//            {
//                birth_day : 1,
//                birth_month : 1,
//                birth_year : 2000,
//                city_code : 3,
//                comp : [
//                        {
//                            begin_year : 2010,
//                            company_name : 腾讯微博,
//                            department_name : 开放平台,
//                            end_year : 9999,
//                            id : 24047
//                        }],
//                country_code : 1,
//                edu : [
//                       {
//                           departmentid : 5197,
//                           id : 24037,
//                           level : 4,
//                           schoolid : 10418,
//                           year : 2009
//                       }],
//                fansnum : 53,
//                favnum : 3,
//                head : http://app.qlogo.cn/mbloghead/8df62426cf2873508634,
//                homecity_code : 13,
//                homecountry_code : 1,
//                homepage : http://t.qq.com/china394337002,
//                homeprovince_code : 42,
//                hometown_code : 42,
//                idolnum : 100,
//                industry_code : 2002,
//                introduction : 十年树木，百年树人,
//                isent : 0,
//                ismyblack : 0,
//                ismyfans : 0,
//                ismyidol : 0,
//                isrealname : 1,
//                isvip : 1,
//                location : 未知,
//                mutual_fans_num : 10,
//                name : china394337002,
//                nick : 续立冬,
//                openid : DE9DF084BC1191C4659BB5110FAB122E,
//                province_code : 1,
//                regtime : 1291044551,
//                send_private_flag : 0,
//                sex : 1,
//                tag : [
//                       {
//                           id : 3274154839212534452,
//                           name : 微博控
//                       }],
//                tweetinfo : [
//                             {
//                                 city_code : xxx,
//                                 country_code : xxx,
//                                 emotiontype : 0,
//                                 emotionurl : xxx,
//                                 from : 微博开放平台,
//                                 fromurl : http://wiki.open.t.qq.com/index.php/产品类FAQ#.E6.8F.90.E4.BA.A4.E5.BA.94.E7.94.A8.E6.9D.A5.E6.BA.90.E5.AD.97.E6.AE.B5.E5.AE.A1.E6.A0.B8.E8.83.BD.E5.BE.97.E5.88.B0.E4.BB.80.E4.B9.88.E5.A5.BD.E5.A4.84.EF.BC.9F,
//                                 geo : xxx,
//                                 id : 103785058012989,
//                                 image : [xxx],
//                                 latitude : 0,
//                                 location : 未知,
//                                 longitude : 0,
//                                 music : 
//                                 {
//                                     author : xxx,
//                                     url : xxx,
//                                     title : xxx
//                                 },
//                                 origtext : 种草不让人去躺，不如改种仙人掌!,
//                                 province_code : xxx,
//                                 self : 1,
//                                 status : 0,
//                                 text : 种草不让人去躺，不如改种仙人掌!,
//                                 timestamp : 1340005671,
//                                 type : 1,
//                                 video : 
//                                 {
//                                     picurl : xxx,
//                                     player : xxx,
//                                     realurl : xxx,
//                                     shorturl : xxx,
//                                     title : xxx
//                                 }
//                             }],
//                tweetnum : 100,
//                verifyinfo : xxx,
//                exp : 1,
//                level : 1
//            },
//            seqid : xxx
//        }
    }];
    
    [request setFailureBlock: ^(NSError * error){
        DebugLog(@"++++++ Tecent Get userInfo Error: %@", error);
        self.isRequestingUserInfo = NO;
    }];
    
    [fullParams release];
    
	[request connect];
}

- (void)CUGetFollowersWithPage:(NSUInteger)page
                       succeed:(void (^)(NSString *))completeBlock
                       failure:(void (^)(NSError *))failureBlock
{
    if (![self isCUAuth]) {
		return ;
	}

    NSString * apiPath = @"friends/fanslist_s";
    NSString * httpMehod = @"GET";
    
    NSMutableDictionary * fullParams = [[NSMutableDictionary alloc] init];
    [fullParams setValue:[NSString stringWithFormat:@"%d",page * 30] forKey:@"startindex"];
    [fullParams setValue:[NSString stringWithFormat:@"%d",30] forKey:@"reqnum"];
    [fullParams setValue:[NSString stringWithFormat:@"%d",0] forKey:@"install"];
    
    [self addGenerateSigStringFor:apiPath
                            using:httpMehod
                        withParam:nil
                 outputFullParams:&fullParams];
    
	NSString * fullURL = [kQQRestserverBaseURL stringByAppendingString:apiPath];
	WBRequest * request = [WBRequest requestWithURL:fullURL
                                         httpMethod:httpMehod
                                             params:fullParams
                                       postDataType:kWBRequestPostDataTypeNormal
                                   httpHeaderFields:nil
                                           delegate:nil];
    [request setCompleteBlock: ^(NSString * responseString){
        DebugLog(@"++++++ Tecent Get Followers: %@", responseString);
        completeBlock(responseString);
    }];
    
    [request setFailureBlock: ^(NSError * error){
        DebugLog(@"++++++ Tecent Get Followers Error: %@", error);
        failureBlock(error);
    }];
    
    [fullParams release];
    
	[request connect];
}

- (void)CUGetFollowingsWithPage:(NSUInteger)page
                        succeed:(void (^)(NSString *))completeBlock
                        failure:(void (^)(NSError *))failureBlock
{
    if (![self isCUAuth]) {
		return ;
	}
    
    NSString * apiPath = @"friends/idollist";
    NSString * httpMehod = @"GET";
    
    NSMutableDictionary * fullParams = [[NSMutableDictionary alloc] init];
    [fullParams setValue:[NSString stringWithFormat:@"%d",page * 30] forKey:@"startindex"];
    [fullParams setValue:[NSString stringWithFormat:@"%d",30] forKey:@"reqnum"];
    [fullParams setValue:[NSString stringWithFormat:@"%d",0] forKey:@"install"];
    
    [self addGenerateSigStringFor:apiPath
                            using:httpMehod
                        withParam:nil
                 outputFullParams:&fullParams];
    
	NSString * fullURL = [kQQRestserverBaseURL stringByAppendingString:apiPath];
	WBRequest * request = [WBRequest requestWithURL:fullURL
                                         httpMethod:httpMehod
                                             params:fullParams
                                       postDataType:kWBRequestPostDataTypeNormal
                                   httpHeaderFields:nil
                                           delegate:nil];
    
    [request setCompleteBlock: ^(NSString * responseString){
        DebugLog(@"++++++ Tecent Get Followings: %@", responseString);
        completeBlock(responseString);
    }];
    
    [request setFailureBlock: ^(NSError * error){
        DebugLog(@"++++++ Tecent Get Followings Error: %@", error);
        failureBlock(error);
    }];
    
    [fullParams release];
    
	[request connect];
}


- (void)CUGetFriendsWithPage:(NSUInteger)page
                     succeed:(void (^)(NSString *))completeBlock
                     failure:(void (^)(NSError *))failureBlock
{
    if (![self isCUAuth]) {
		return ;
	}
    
    NSString * apiPath = @"friends/mutual_list";
    NSString * httpMehod = @"GET";
    
    NSMutableDictionary * fullParams = [[NSMutableDictionary alloc] init];
    [fullParams setValue:engine.userID forKey:@"fopenid"];
    [fullParams setValue:[NSString stringWithFormat:@"%d",page * 30] forKey:@"startindex"];
    [fullParams setValue:[NSString stringWithFormat:@"%d",30] forKey:@"reqnum"];
    [fullParams setValue:[NSString stringWithFormat:@"%d",0] forKey:@"install"];
    
    [self addGenerateSigStringFor:apiPath
                            using:httpMehod
                        withParam:nil
                 outputFullParams:&fullParams];
    
	NSString * fullURL = [kQQRestserverBaseURL stringByAppendingString:apiPath];
	WBRequest * request = [WBRequest requestWithURL:fullURL
                                         httpMethod:httpMehod
                                             params:fullParams
                                       postDataType:kWBRequestPostDataTypeNormal
                                   httpHeaderFields:nil
                                           delegate:nil];
    
    [request setCompleteBlock: ^(NSString * responseString){
        DebugLog(@"++++++ Tecent Get Friends: %@", responseString);
        completeBlock(responseString);
    }];
    
    [request setFailureBlock: ^(NSError * error){
        DebugLog(@"++++++ Tecent Get Friends Error: %@", error);
        failureBlock(error);
    }];
    
    [fullParams release];
    
	[request connect];
}
- (NSDictionary *)CUGetAuthorizedUserInfo
{
    NSString * infoString = [[NSUserDefaults standardUserDefaults] stringForKey:kQQUserInfoKey];
    if (nil == infoString)
    {
        if ([self isCUAuth])
        {
            do {
                infoString = [[NSUserDefaults standardUserDefaults] stringForKey:kQQUserInfoKey];
                
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
#pragma mark -  CUShareClient


- (NSURLRequest *)CULoginURLRequest
{
    NSArray * permissions = @[@"get_user_info",@"add_share",@"add_topic",@"add_one_blog",@"list_album",@"upload_pic",@"list_photo",@"add_album",@"check_page_fans"];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"token", @"response_type",
                                   engine.appKey, @"client_id",
                                   @"user_agent", @"type",
                                   engine.redirectURI, @"redirect_uri",
                                   @"mobile", @"display",
								   [NSString stringWithFormat:@"%f",[[[UIDevice currentDevice] systemVersion] floatValue]],@"status_os",
								   [[UIDevice currentDevice] name],@"status_machine",
                                   @"v2.0",@"status_version",
								   
                                   nil];
		
	if (permissions != nil) {
		NSString* scope = [permissions componentsJoinedByString:@","];
		[params setValue:scope forKey:@"scope"];
	}
    
    NSString *urlString = [WBRequest serializeURL:kQQAuthorizeURL
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

    if ([kOAuthRedirectURL_tencent rangeOfString:request.URL.host].length > 0)
    {
        NSString * urlString = request.URL.absoluteString;
        NSRange start = [urlString rangeOfString:@"access_token="];

        if (start.location != NSNotFound)
        {
            NSDictionary *params = [CUTencentShareClient parseURLParams:[request.URL fragment]];
            
            NSString * token        = [params objectForKey:@"access_token"];
            NSString * expireTime   = [params objectForKey:@"expires_in"];
            NSString * openid = [params objectForKey:@"openid"];
//            NSString * openkey = [params objectForKey:@"openkey"];
//            NSString * refresh_token = [params objectForKey:@"refresh_token"];
//            NSString * state = [params objectForKey:@"state"];
            NSString * name = [params objectForKey:@"name"];
            NSString * nick = [params objectForKey:@"nick"];
            
            if ((token == (NSString *) [NSNull null]) || (token.length == 0))
            {
                [delegate performSelector:@selector(request:didFailWithError:) withObject:request withObject:nil];
            }
            else
            {
                if ([engine respondsToSelector:@selector(authorize:didSucceedWithAccessToken:userID:expiresIn:)])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString * nickname = nick;
                        if (0 == [nickname length])
                        {
                            nickname = name;
                        }
                        engine.nickname = nickname;
                        
                        [engine authorize:engine.authorize didSucceedWithAccessToken:token
                                   userID:openid
                                expiresIn:[expireTime integerValue]];
                    });
                }
            }
        }
        
        return NO;
    }
    
    return YES;
}

/**
 * 解析URL参数的工具方法。
 */
+ (NSDictionary *)parseURLParams:(NSString *)query{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
        if (kv.count == 2) {
            NSString *val =[[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [params setObject:val forKey:[kv objectAtIndex:0]];
        }
	}
    return [params autorelease];
}

#pragma mark - 添加全局oauth参数并签名
- (NSString *)addGenerateSigStringFor:(NSString *)apiPath using:(NSString *)httpMethod withParam:(NSDictionary *)params outputFullParams:(NSMutableDictionary **)fullParams
{
//    NSString *sigTimeStamp = [NSString stringWithFormat:@"%0.0f", (double)[[NSDate date] timeIntervalSince1970]];
	
	NSMutableArray *paramsArray = [NSMutableArray array];
    if (nil == *fullParams)
    {
        *fullParams = [[[NSMutableDictionary alloc] initWithDictionary:params] autorelease];
    }
    
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
- (void)engineAlreadyLoggedIn:(WBEngine *)anEngine
{
    
}

// Log in successfully.
- (void)engineDidLogIn:(WBEngine *)anEngine
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self CUGetUserInfo:anEngine.userID];
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
- (void)engineDidLogOut:(WBEngine *)anEngine
{
    [self CUNotifyLoginout:self];
}

// When you use the WBEngine's request methods,
// you may receive the following four callbacks.
- (void)engineNotAuthorized:(WBEngine *)anEngine
{
    [self CUNotifyShareFailed:self withError:nil];
}

- (void)engineAuthorizeExpired:(WBEngine *)anEngine
{
    [self CUNotifyAuthFailed:self withError:nil];
}

- (void)engine:(WBEngine *)anEngine requestDidFailWithError:(NSError *)error
{
    [self CUNotifyShareFailed:self withError:error];
}

- (void)engine:(WBEngine *)anEngine requestDidSucceedWithResult:(id)result
{
    [self CUNotifyShareSucceed:self];
}

@end
