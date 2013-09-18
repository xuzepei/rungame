//
//  CUTencentShareClient.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-16.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CUShareClient.h"
#import "WBEngine.h"

#import "CUShareOAuthView.h"

@interface CUTencentShareClient : CUShareClient
<CUShareClientData, WBEngineDelegate>
{
    WBEngine *engine;
    
    /**************************************
     * Inherited from CUShareClient:
     *
     * UIWebView *webView;
     * UINavigationBar	*navBar;
     * UIInterfaceOrientation orientation;
     * UIToolbar *pinCopyPromptBar;
     * id<CUShareClientDelegate> delegate;
     ***************************************/
}

//CUShareClientData
- (BOOL)isCUAuth;
- (void)CULogout;

- (void)CUSendWithText:(NSString *)text delegate:(id)delegate;
- (void)CUSendWithText:(NSString *)text andImage:(UIImage *)image delegate:(id)delegate;
- (void)CUSendWithText:(NSString *)text andImageURLString:(NSString *)imageURLString;

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

- (NSURLRequest *)CULoginURLRequest;

@end

