//
//  CUShareClient.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-20.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUShareClient.h"
#import "CUShareOAuthView.h"
#import "GCDMulticastDelegate.h"
#import "RCTool.h"
#import "CUSinaShareClient.h"
#import "CUTencentShareClient.h"

@interface CUShareClient ()

@end

@implementation CUShareClient

@synthesize delegate;
@synthesize viewClient;

#pragma mark - life

- (id)init
{
    if (self = [super init]) {
        multicastMessageDelegate = (GCDMulticastDelegate <CUShareClientDelegate> *)[[GCDMulticastDelegate alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    self.viewClient = nil;
    self.delegate = nil;
    self.myDelegate = nil;
    
    [multicastMessageDelegate removeAllDelegates];
    
    [multicastMessageDelegate release];
    
    [super dealloc];
}

#pragma mark - common method

- (void)addDelegate:(id)aDelegate {
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), 
             @"Invoked on incorrect queue");
    
    [multicastMessageDelegate addDelegate:aDelegate 
                            delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id)aDelegate {
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), 
             @"Invoked on incorrect queue");
    
    [multicastMessageDelegate removeDelegate:aDelegate];
}


- (void)CUOpenAuthViewInViewController:(UIViewController *)vc;
{
    self.myDelegate = vc;
    
    self.viewClient = [[[CUShareOAuthView alloc] initWithNibName:nil bundle:nil] autorelease];

    self.viewClient.loginRequest = [self CULoginURLRequest];
    if (self.viewClient.view)//初始化并加载试图部件
    {
        self.viewClient.webView.delegate = self;
        [self.viewClient.webView loadRequest:[self CULoginURLRequest]];
        self.viewClient.delegate = self;
        
        NSString * oauthTitle = nil;
        CUShareClientType clientType = self.clientType;
        switch (clientType)
        {
            case CUSHARE_QQ:
                oauthTitle = @"腾讯微博登录";
                break;
            case CUSHARE_SINA:
                oauthTitle = @"新浪微博登录";
                break;
            default:
                break;
        }
        
        self.viewClient.title = oauthTitle;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    
//    [self performSelector:@selector(show:) withObject:vc afterDelay:0.1];
    
    if(vc)
    [vc presentModalViewController:self.viewClient animated:YES];
    

}

- (void)CUNotifyShareFailed:(CUShareClient *)client withError:(NSError *)error
{
    [multicastMessageDelegate CUShareFailed:client withError:error];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.viewClient performSelector:@selector(hide:) withObject:nil afterDelay:.2f];
}

- (void)CUNotifyShareSucceed:(CUShareClient *)client
{
    [multicastMessageDelegate CUShareSucceed:client];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.viewClient performSelector:@selector(hide:) withObject:nil afterDelay:.2f];
}

- (void)CUNotifyShareCancel:(CUShareClient *)client
{
    [multicastMessageDelegate CUShareCancel:client];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.viewClient performSelector:@selector(hide:) withObject:nil afterDelay:.20f];
}

- (void)CUNotifyAuthSucceed:(CUShareClient *)client
{
    [multicastMessageDelegate CUAuthSucceed:client];
    
    if(self.myDelegate && [self.myDelegate respondsToSelector:@selector(authSucceeded:)])
    {
        if([client isKindOfClass:[CUSinaShareClient class]])
            [self.myDelegate authSucceeded:SHT_SINA];
        else if([client isKindOfClass:[CUTencentShareClient class]])
            [self.myDelegate authSucceeded:SHT_QQ];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.viewClient performSelector:@selector(hide:) withObject:nil afterDelay:.2f];
}

- (void)CUNotifyAuthCanceled:(CUShareClient *)client
{
    [multicastMessageDelegate CUAuthCanceled:client];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.viewClient performSelector:@selector(hide:) withObject:nil afterDelay:.2f];
}

- (void)CUNotifyAuthFailed:(CUShareClient *)client withError:(NSError *)error
{
    [multicastMessageDelegate CUAuthFailed:client withError:error];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.viewClient performSelector:@selector(hide:) withObject:nil afterDelay:.2f];
}

- (void)CUNotifyLoginout:(CUShareClient *)client
{
    [multicastMessageDelegate CUNotifyLoginout:client];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - private

- (void)show:(UIViewController *)vc
{
    [viewClient show:YES];
}

#pragma mark - override me

- (NSURLRequest *)CULoginURLRequest
{
    return nil;
}

@end
