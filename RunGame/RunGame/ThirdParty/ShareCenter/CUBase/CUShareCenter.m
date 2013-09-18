//
//  CUShareCenter.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUShareCenter.h"
#import "CUSinaShareClient.h"
#import "CUTencentShareClient.h"
#import "CURenrenShareClient.h"
#import "CUConfig.h"

@interface CUShareCenter ()


@end

@implementation CUShareCenter

static CUShareCenter *s_instance1 = nil;
static CUShareCenter *s_instance2 = nil;
static CUShareCenter *s_instance3 = nil;

@synthesize shareClient;

#pragma mark - life

- (id)init
{
    if (self = [super init]) {
        
    }
    
    return self;
}

- (id)initWithType:(CUShareClientType)aType
{
    if (self = [self init]) {
        type = aType;
    }
    
    return self;
}

- (void)dealloc
{
    [shareClient release];
    self.delegate = nil;
    
    [super dealloc];
}

//not thread safe
+ (CUShareCenter *)sharedInstance:(CUShareCenter *)instance {
    @synchronized([CUShareCenter class])
    {
        if (instance == nil)
        {
            instance = [[CUShareCenter alloc] init];
        }
    }
    
    return instance;
}

+ (CUShareCenter *)sharedInstanceWithType:(CUShareClientType)type
{
    CUShareCenter *center = nil;
    
    switch (type) {
        case CUSHARE_SINA:
        {
            if (s_instance1 == nil) {
                s_instance1 = [CUShareCenter sharedInstance:s_instance1];
                
                CUSinaShareClient *sinaClient = [[CUSinaShareClient alloc] initWithAppKey:kOAuthConsumerKey_sina 
                                                                                appSecret:kOAuthConsumerSecret_sina];
                s_instance1.shareClient = sinaClient;
                
                [sinaClient release];
            }
            
            center = s_instance1;
        }
            break;
        case CUSHARE_QQ:
        {
            if (s_instance2 == nil) {
                s_instance2 = [CUShareCenter sharedInstance:s_instance2];
                
                CUTencentShareClient *tencentClient = [[CUTencentShareClient alloc] initWithAppKey:kOAuthConsumerKey_tencent
                                                                                         appSecret:kOAuthConsumerSecret_tencent];
                s_instance2.shareClient = tencentClient;
                
                [tencentClient release];
            }
            
            center = s_instance2;
        }
            break;    
        case CUSHARE_RENREN:
        {
            if (s_instance3 == nil) {
                s_instance3 = [CUShareCenter sharedInstance:s_instance3];
                
                CURenrenShareClient *renrenClient = [[CURenrenShareClient alloc] initWithAppKey:kAPP_ID_renren
                                                                                      appSecret:kAPI_Key_renren];
                s_instance3.shareClient = renrenClient;
                
                [renrenClient release];
            }
            
            center = s_instance3;
        }
            break;
            
        default:
            break;
    }
    
    return center;
}

//not thread fault
+ (void)destory:(CUShareCenter *)instance
{
    if (instance != nil) {
        [instance release];
        instance = nil;
    }
    
    return;
}
#pragma mark - common method

- (CUShareClientType)shareType
{
    return type;
}

- (void)sendWithText:(NSString *)text delegate:(id)delegate
{
    return [self sendWithText:text andImage:nil delegate:delegate];
}

- (void)sendWithText:(NSString *)text andImage:(UIImage *)image delegate:(id)delegate
{
    [shareClient CUSendWithText:text andImage:image delegate:delegate];
}

- (void)sendWithText:(NSString *)text andImageURLString:(NSString *)imageURLString
{
    [shareClient CUSendWithText:text andImageURLString:imageURLString];
}

- (BOOL)isBind
{
    return [shareClient isCUAuth];
}

- (void)unBind
{
    return [shareClient CULogout];
}

- (void)bind:(UIViewController *)vc
{    
    [shareClient CUOpenAuthViewInViewController:vc];
    
    return;
}

@end
