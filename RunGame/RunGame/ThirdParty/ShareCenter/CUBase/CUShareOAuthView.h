//
//  CUShareOAuthView.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern int kActiveIndicatorTag;

@protocol CUShareOAuthViewDelegate;

@interface CUShareOAuthView : UIViewController <UIWebViewDelegate>
{
    UIView *panelView;
    UIView *containerView;
    UIActivityIndicatorView *indicatorView;
	UIWebView *webView;
    
    UIInterfaceOrientation previousOrientation;
}

@property (nonatomic, assign) id<CUShareOAuthViewDelegate> delegate;

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSURLRequest *loginRequest;
@property (nonatomic,retain)UINavigationBar* titleBar;

- (UIActivityIndicatorView *)getActivityIndicatorView;

- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;

@end

@protocol CUShareOAuthViewDelegate <NSObject>

@optional
- (void)authViewDidCancel:(CUShareOAuthView *)authView;

@end
