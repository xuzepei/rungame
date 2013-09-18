//
//  CUShareCenter.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CUShareClient.h"

@interface CUShareCenter : NSObject
{
    CUShareClientType type;
    id<CUShareClientData> shareClient;
}

+ (CUShareCenter *)sharedInstanceWithType:(CUShareClientType)type;

+ (void)destory:(CUShareCenter *)instance;

- (void)sendWithText:(NSString *)text delegate:(id)delegate;
- (void)sendWithText:(NSString *)text andImage:(UIImage *)image delegate:(id)delegate;
- (void)sendWithText:(NSString *)text andImageURLString:(NSString *)imageURLString;

- (BOOL)isBind;
- (void)unBind;
- (void)bind:(UIViewController *)vc;

@property (nonatomic, readonly) CUShareClientType shareType;

//it really should be retain!
@property (nonatomic, retain) id<CUShareClientData> shareClient;

@property(assign)id delegate;

@end
