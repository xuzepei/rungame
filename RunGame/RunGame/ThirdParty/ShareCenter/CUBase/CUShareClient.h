//
//  CUShareClient.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-20.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CUShareOAuthView.h"

#ifndef DebugLog
#ifdef DEBUG
#define DebugLog(...) NSLog(__VA_ARGS__)
#else
#define DebugLog(...)
#endif
#endif

typedef enum _CUShareClientType
{
    CUSHARE_SINA = 0,
    CUSHARE_QQ = 1,
    CUSHARE_RENREN = 2
}
CUShareClientType;

@protocol CUShareClientData <UIWebViewDelegate>

@property (nonatomic, readonly) NSString * userId;
@property (nonatomic, readonly) NSString * accessToken;
@property (nonatomic, readonly) NSTimeInterval expireTime;
@property (nonatomic, readonly) NSString * nickname;

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret;

- (BOOL)isCUAuth;
- (void)CUOpenAuthViewInViewController:(UIViewController *)vc;
- (void)CULogout;

- (void)CUSendWithText:(NSString *)text delegate:(id)delegate;
- (void)CUSendWithText:(NSString *)text andImage:(UIImage *)image delegate:(id)delegate;
- (void)CUSendWithText:(NSString *)text andImageURLString:(NSString *)imageURLString;

@optional

- (void)CUGetFollowersWithPage:(NSUInteger)page
                       succeed:(void (^)(NSString *))completeBlock
                       failure:(void (^)(NSError *))failureBlock;

- (void)CUGetFollowingsWithPage:(NSUInteger)page
                        succeed:(void (^)(NSString *))completeBlock
                        failure:(void (^)(NSError *))failureBlock;

- (void)CUGetFriendsWithPage:(NSUInteger)page
                     succeed:(void (^)(NSString *))completeBlock
                     failure:(void (^)(NSError *))failureBlock;

- (NSDictionary *)CUGetAuthorizedUserInfo;

- (void)addDelegate:(id)aDelegate;
- (void)removeDelegate:(id)aDelegate;

@end

@class CUShareClient;
@protocol CUShareClientDelegate <NSObject>

@optional
- (void)CUShareFailed:(CUShareClient *)client withError:(NSError *)error;
- (void)CUShareSucceed:(CUShareClient *)client;
- (void)CUShareCancel:(CUShareClient *)client;

- (void)CUAuthSucceed:(CUShareClient *)client;
- (void)CUAuthCanceled:(CUShareClient *)client;
- (void)CUAuthFailed:(CUShareClient *)client withError:(NSError *)error;
- (void)CUNotifyLoginout:(CUShareClient *)client;

@end

@class GCDMulticastDelegate;
@interface CUShareClient : NSObject
<UIWebViewDelegate, CUShareOAuthViewDelegate>
{
    id<CUShareClientDelegate> delegate;
    
    CUShareOAuthView *viewClient;
    
    GCDMulticastDelegate <CUShareClientDelegate> *multicastMessageDelegate;
}

@property (nonatomic, assign) id<CUShareClientDelegate> delegate;
@property (nonatomic, retain) CUShareOAuthView *viewClient;

@property (nonatomic, readonly) CUShareClientType clientType;
@property (nonatomic, readonly) NSString * userId;
@property (nonatomic, readonly) NSString * accessToken;
@property (nonatomic, readonly) NSTimeInterval expireTime;
@property (nonatomic, readonly) NSString * nickname;
@property (assign)id myDelegate;

- (void)addDelegate:(id)aDelegate;
- (void)removeDelegate:(id)aDelegate;

- (void)CUOpenAuthViewInViewController:(UIViewController *)vc;

- (void)CUNotifyShareFailed:(CUShareClient *)client withError:(NSError *)error;
- (void)CUNotifyShareSucceed:(CUShareClient *)client;
- (void)CUNotifyShareCancel:(CUShareClient *)client;
- (void)CUNotifyAuthSucceed:(CUShareClient *)client;
- (void)CUNotifyAuthCanceled:(CUShareClient *)client;
- (void)CUNotifyAuthFailed:(CUShareClient *)client withError:(NSError *)error;
- (void)CUNotifyLoginout:(CUShareClient *)client;

@end
