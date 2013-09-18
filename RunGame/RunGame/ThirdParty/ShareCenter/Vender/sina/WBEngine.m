//
//  WBEngine.m
//  SinaWeiBoSDK
//  Based on OAuth 2.0
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  Copyright 2011 Sina. All rights reserved.
//

#import "WBEngine.h"
#import "SFHFKeychainUtils.h"
#import "WBSDKGlobal.h"
#import "WBUtil.h"

#define kWBURLSchemePrefix              @"WB_"

#define kWBKeychainServiceNameSuffix    @"_WeiBoServiceName"
#define kWBKeychainUserID               @"WeiBoUserID"
#define kWBKeychainAccessToken          @"WeiBoAccessToken"
#define kWBKeychainExpireTime           @"WeiBoExpireTime"
#define kWBKeychainNickname             @"WeiBoNickname"

#define kQQURLSchemePrefix              @"QQ_"

#define kQQKeychainServiceNameSuffix    @"_QQServiceName"
#define kQQKeychainUserID               @"QQUserID"
#define kQQKeychainAccessToken          @"QQAccessToken"
#define kQQKeychainExpireTime           @"QQExpireTime"
#define kQQKeychainNickname           @"QQNickname"

@interface WBEngine (Private)

- (NSString *)urlSchemeString;

- (void)saveAuthorizeDataToKeychain;
- (void)readAuthorizeDataFromKeychain;
- (void)deleteAuthorizeDataInKeychain;

@end

@implementation WBEngine
@synthesize snsType=_snsType;
@synthesize appKey=_appKey;
@synthesize appSecret=_appSecret;
@synthesize userID=_userID;
@synthesize accessToken=_accessToken;
@synthesize expireTime=_expireTime;
@synthesize nickname=_nickname;
@synthesize redirectURI=_redirectURI;
@synthesize isUserExclusive=_isUserExclusive;
@synthesize request=_request;
@synthesize authorize=_authorize;
@synthesize delegate=_delegate;
@synthesize rootViewController=_rootViewController;


#pragma mark - WBEngine Life Circle

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    if (self = [super init])
    {
        self.appKey = theAppKey;
        self.appSecret = theAppSecret;
        
        self.userID = nil;
        self.accessToken = nil;
        self.expireTime = 0;
        self.nickname = nil;
        
        _isUserExclusive = NO;
        
        [self readAuthorizeDataFromKeychain];
        
    }
    
    return self;
}

- (void)setSnsType:(NSString *)_snstype
{
    _snsType = _snstype;
    [self readAuthorizeDataFromKeychain];
}

- (void)dealloc
{
    [_snsType release],_snsType= nil;
    [_appKey release], _appKey = nil;
    [_appSecret release], _appSecret = nil;
    
    [_userID release], _userID = nil;
    [_accessToken release], _accessToken = nil;
    [_nickname release]; _nickname = nil;
    
    [_redirectURI release], _redirectURI = nil;
    
    [_request setDelegate:nil];
    [_request disconnect];
    [_request release], _request = nil;
    
    [_authorize setDelegate:nil];
    [_authorize release], _authorize = nil;
    
    _delegate = nil;
    _rootViewController = nil;
    
    [super dealloc];
}

#pragma mark - WBEngine Private Methods

- (NSString *)urlSchemeString
{
    if ([_snsType isEqualToString:@"sina"]) {
        return [NSString stringWithFormat:@"%@%@", kWBURLSchemePrefix, _appKey];
    }
    else if ([_snsType isEqualToString:@"qq"])
    {
        return [NSString stringWithFormat:@"%@%@", kQQURLSchemePrefix, _appKey];
    }
    return nil;
}

- (void)saveAuthorizeDataToKeychain
{
    if ([_snsType isEqualToString:@"sina"]) {
        NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kWBKeychainServiceNameSuffix];
        [SFHFKeychainUtils storeUsername:kWBKeychainUserID andPassword:_userID forServiceName:serviceName updateExisting:YES error:nil];
        [SFHFKeychainUtils storeUsername:kWBKeychainAccessToken andPassword:_accessToken forServiceName:serviceName updateExisting:YES error:nil];
        [SFHFKeychainUtils storeUsername:kWBKeychainExpireTime andPassword:[NSString stringWithFormat:@"%lf", _expireTime] forServiceName:serviceName updateExisting:YES error:nil];
        [SFHFKeychainUtils storeUsername:kWBKeychainNickname andPassword:_nickname forServiceName:serviceName updateExisting:YES error:nil];
    }
    else if ([_snsType isEqualToString:@"qq"])
    {
        NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kQQKeychainServiceNameSuffix];
        [SFHFKeychainUtils storeUsername:kQQKeychainUserID andPassword:_userID forServiceName:serviceName updateExisting:YES error:nil];
        [SFHFKeychainUtils storeUsername:kQQKeychainAccessToken andPassword:_accessToken forServiceName:serviceName updateExisting:YES error:nil];
        [SFHFKeychainUtils storeUsername:kQQKeychainExpireTime andPassword:[NSString stringWithFormat:@"%lf", _expireTime] forServiceName:serviceName updateExisting:YES error:nil];
        [SFHFKeychainUtils storeUsername:kQQKeychainNickname andPassword:_nickname forServiceName:serviceName updateExisting:YES error:nil];
    }
}

- (void)readAuthorizeDataFromKeychain
{
    if ([_snsType isEqualToString:@"sina"]) {
        NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kWBKeychainServiceNameSuffix];
        self.userID = [SFHFKeychainUtils getPasswordForUsername:kWBKeychainUserID andServiceName:serviceName error:nil];
        self.accessToken = [SFHFKeychainUtils getPasswordForUsername:kWBKeychainAccessToken andServiceName:serviceName error:nil];
        self.expireTime = [[SFHFKeychainUtils getPasswordForUsername:kWBKeychainExpireTime andServiceName:serviceName error:nil] doubleValue];
        self.nickname = [SFHFKeychainUtils getPasswordForUsername:kWBKeychainNickname andServiceName:serviceName error:nil];
    }
    else if ([_snsType isEqualToString:@"qq"])
    {
        NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kQQKeychainServiceNameSuffix];
        self.userID = [SFHFKeychainUtils getPasswordForUsername:kQQKeychainUserID andServiceName:serviceName error:nil];
        self.accessToken = [SFHFKeychainUtils getPasswordForUsername:kQQKeychainAccessToken andServiceName:serviceName error:nil];
        self.expireTime = [[SFHFKeychainUtils getPasswordForUsername:kQQKeychainExpireTime andServiceName:serviceName error:nil] doubleValue];
        self.nickname = [SFHFKeychainUtils getPasswordForUsername:kQQKeychainNickname andServiceName:serviceName error:nil];
    }
}

- (void)deleteAuthorizeDataInKeychain
{
    self.userID = nil;
    self.accessToken = nil;
    self.expireTime = 0;
    
    if ([_snsType isEqualToString:@"sina"]) {
        NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kWBKeychainServiceNameSuffix];
        [SFHFKeychainUtils deleteItemForUsername:kWBKeychainUserID andServiceName:serviceName error:nil];
        [SFHFKeychainUtils deleteItemForUsername:kWBKeychainAccessToken andServiceName:serviceName error:nil];
        [SFHFKeychainUtils deleteItemForUsername:kWBKeychainExpireTime andServiceName:serviceName error:nil];
        [SFHFKeychainUtils deleteItemForUsername:kWBKeychainNickname andServiceName:serviceName error:nil];
    }
    else if ([_snsType isEqualToString:@"qq"])
    {
        NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kQQKeychainServiceNameSuffix];
        [SFHFKeychainUtils deleteItemForUsername:kQQKeychainUserID andServiceName:serviceName error:nil];
        [SFHFKeychainUtils deleteItemForUsername:kQQKeychainAccessToken andServiceName:serviceName error:nil];
        [SFHFKeychainUtils deleteItemForUsername:kQQKeychainExpireTime andServiceName:serviceName error:nil];
        [SFHFKeychainUtils deleteItemForUsername:kQQKeychainNickname andServiceName:serviceName error:nil];
    }
    
    
}

#pragma mark - WBEngine Public Methods

#pragma mark Authorization

- (void)logOut
{
    [self deleteAuthorizeDataInKeychain];
    
    if ([_delegate respondsToSelector:@selector(engineDidLogOut:)])
    {
        [_delegate engineDidLogOut:self];
    }
}

- (BOOL)isLoggedIn
{
    return _userID && _accessToken && (_expireTime > 0);
}

- (BOOL)isAuthorizeExpired
{
    if ([[NSDate date] timeIntervalSince1970] > _expireTime)
    {
        // force to log out
        [self deleteAuthorizeDataInKeychain];
        return YES;
    }
    return NO;
}

#pragma mark Request

- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(WBRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields
{
    // Step 1.
    // Check if the user has been logged in.
	if (![self isLoggedIn])
	{
        if ([_delegate respondsToSelector:@selector(engineNotAuthorized:)])
        {
            [_delegate engineNotAuthorized:self];
        }
        return;
	}
    
	// Step 2.
    // Check if the access token is expired.
    if ([self isAuthorizeExpired])
    {
        if ([_delegate respondsToSelector:@selector(engineAuthorizeExpired:)])
        {
            [_delegate engineAuthorizeExpired:self];
        }
        return;
    }
    
    [_request disconnect];
    
    if ([_snsType isEqualToString:@"sina"]) {
        self.request = [WBRequest requestWithAccessToken:_accessToken
                                                     url:[NSString stringWithFormat:@"%@%@", kWBSDKAPIDomain, methodName]
                                              httpMethod:httpMethod
                                                  params:params
                                            postDataType:postDataType
                                        httpHeaderFields:httpHeaderFields
                                                delegate:self];
    }
    else if ([_snsType isEqualToString:@"qq"])
    {
        self.request = [WBRequest requestWithAccessToken:_accessToken
                                                     url:[NSString stringWithFormat:@"%@%@", kQQSDKAPIDomain, methodName]
                                              httpMethod:httpMethod
                                                  params:params
                                            postDataType:postDataType
                                        httpHeaderFields:httpHeaderFields
                                                delegate:self];
    }
    
    
	
	[_request connect];
}

- (void)sendWeiBoWithText:(NSString *)text image:(UIImage *)image
{
    if ([_snsType isEqualToString:@"sina"]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        
        //NSString *sendText = [text URLEncodedString];
        
        [params setObject:(text ? text : @"") forKey:@"status"];
        
        if (image)
        {
            [params setObject:image forKey:@"pic"];
            
            [self loadRequestWithMethodName:@"statuses/upload.json"
                                 httpMethod:@"POST"
                                     params:params
                               postDataType:kWBRequestPostDataTypeMultipart
                           httpHeaderFields:nil];
        }
        else
        {
            [self loadRequestWithMethodName:@"statuses/update.json"
                                 httpMethod:@"POST"
                                     params:params
                               postDataType:kWBRequestPostDataTypeNormal
                           httpHeaderFields:nil];
        }
    }
    else if ([_snsType isEqualToString:@"qq"])
    {
            NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @"WBShareKit", @"title",
                                           @"http://www.minroad.com", @"url",
                                           @"Test",@"comment",
                                           text,@"summary",
                                           //								   @"http://img1.gtimg.com/tech/pics/hv1/95/153/847/55115285.jpg",@"images",
                                           @"4",@"source",
                                           nil];
            [params setValue:@"json" forKey:@"format"];
            [params setValue:self.appKey forKey:@"oauth_consumer_key"];
            [params setValue:self.accessToken forKey:@"access_token"];
            [params setValue:self.userID forKey:@"openid"];
            
            [self loadRequestWithMethodName:@"share/add_share"
                                 httpMethod:@"POST"
                                     params:params
                               postDataType:kWBRequestPostDataTypeNormal
                           httpHeaderFields:nil];
    }
}

#pragma mark - WBAuthorizeDelegate Methods

- (void)authorize:(WBAuthorize *)authorize didSucceedWithAccessToken:(NSString *)theAccessToken userID:(NSString *)theUserID expiresIn:(NSInteger)seconds
{
    self.accessToken = theAccessToken;
    self.userID = theUserID;
    self.expireTime = [[NSDate date] timeIntervalSince1970] + seconds;
    
    [self saveAuthorizeDataToKeychain];
    
    if ([_delegate respondsToSelector:@selector(engineDidLogIn:)])
    {
        [_delegate engineDidLogIn:self];
    }
}

- (void)authorize:(WBAuthorize *)authorize didFailWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(engine:didFailToLogInWithError:)])
    {
        [_delegate engine:self didFailToLogInWithError:error];
    }
}

#pragma mark - WBRequestDelegate Methods

- (void)request:(WBRequest *)request didFinishLoadingWithResult:(id)result
{
//    DebugLog(@"%@",result);
    if ([_delegate respondsToSelector:@selector(engine:requestDidSucceedWithResult:)])
    {
        [_delegate engine:self requestDidSucceedWithResult:result];
    }
}

- (void)request:(WBRequest *)request didFailWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(engine:requestDidFailWithError:)])
    {
        [_delegate engine:self requestDidFailWithError:error];
    }
}

@end
