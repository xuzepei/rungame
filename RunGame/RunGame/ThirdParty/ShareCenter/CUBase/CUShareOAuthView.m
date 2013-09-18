//
//  CUShareOAuthView.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CUShareOAuthView.h"
#import "CUConfig.h"
#import "RCTool.h"

int kActiveIndicatorTag = 10;

CGRect ApplicationFrame(UIInterfaceOrientation interfaceOrientation) {
	
	CGRect bounds = [[UIScreen mainScreen] applicationFrame];
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
    
	bounds.origin.x = 0;
	return bounds;
}

@interface  CUShareOAuthView()

- (void)bounceOutAnimationStopped;
- (void)bounceInAnimationStopped;
- (void)bounceNormalAnimationStopped;
- (void)allAnimationsStopped;

- (UIInterfaceOrientation)currentOrientation;
- (void)sizeToFitOrientation:(UIInterfaceOrientation)orientation;
- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation;
- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation;

- (void)addObservers;
- (void)removeObservers;

@end

@implementation CUShareOAuthView

@synthesize webView;
@synthesize loginRequest;


#pragma mark -  life

- (void)dealloc
{
    self.webView = nil;
    self.loginRequest = nil;
    
    [panelView release], panelView = nil;
    [containerView release], containerView = nil;
    [webView release], webView = nil;
    [indicatorView release], indicatorView = nil;
    
    self.titleBar = nil;
    
    [super dealloc];
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    
    self.titleBar.topItem.title = title;
}

#pragma mark -  UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];

    CGSize winSize = [UIScreen mainScreen].bounds.size;
    self.view.frame = CGRectMake(0,0,winSize.height,winSize.width);

    //add title bar
    [self initTitleView];
    
    // add the web view
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - NAVIGATION_BAR_HEIGHT)];
    [webView setDelegate:self];
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];

    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView setCenter:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0)];
    [self.view addSubview:indicatorView];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(toInterfaceOrientation == previousOrientation)
        return NO;
    
    return toInterfaceOrientation == UIDeviceOrientationLandscapeLeft
    || toInterfaceOrientation == UIDeviceOrientationLandscapeRight;
}

#pragma mark - Title View

- (void)initTitleView
{
    if(nil == _titleBar)
    {
        _titleBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [RCTool getScreenSize].height, NAVIGATION_BAR_HEIGHT)];
        
        UINavigationItem *navigationItem = [[[UINavigationItem alloc] initWithTitle:@""] autorelease];
        navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(clickedBackButton:)] autorelease];
        navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(clickedRefreshButton:)] autorelease];
        
        [_titleBar pushNavigationItem:navigationItem animated: NO];
    }
    
    [self.view addSubview:_titleBar];
}

#pragma mark Actions

- (void)clickedBackButton:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(authViewDidCancel:)])
    {
        [_delegate authViewDidCancel:self];
    }
    
    [self hide:YES];
}

- (void)clickedRefreshButton:(id)sender
{
    if(self.webView)
    {
        if(NO == self.webView.isLoading)
            [self.webView reload];
    }
}

#pragma mark Orientations

- (UIInterfaceOrientation)currentOrientation
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (void)sizeToFitOrientation:(UIInterfaceOrientation)orientation
{
    [self.view setTransform:CGAffineTransformIdentity];
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    
    self.view.center = CGPointMake(winSize.width/2, winSize.height/2);
    
    if(previousOrientation == orientation)
        return;
    
    [self.view setTransform:[self transformForOrientation:orientation]];
    
    previousOrientation = orientation;
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == UIInterfaceOrientationLandscapeLeft)
    {
		return CGAffineTransformMakeRotation(-M_PI / 2);
	}
    else if (orientation == UIInterfaceOrientationLandscapeRight)
    {
		return CGAffineTransformMakeRotation(M_PI / 2);
	}
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
		return CGAffineTransformMakeRotation(-M_PI);
	}
    else
    {
		return CGAffineTransformIdentity;
	}
}

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

#pragma mark Obeservers

- (void)addObservers
{
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(deviceOrientationDidChange:)
//												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)removeObservers
{
//	[[NSNotificationCenter defaultCenter] removeObserver:self
//													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}


#pragma mark Animations

- (void)bounceOutAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceInAnimationStopped)];
    [panelView setAlpha:0.8];
	[panelView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
	[UIView commitAnimations];
}

- (void)bounceInAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceNormalAnimationStopped)];
    [panelView setAlpha:1.0];
	[panelView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)];
	[UIView commitAnimations];
}

- (void)bounceNormalAnimationStopped
{
    [self allAnimationsStopped];
}

- (void)allAnimationsStopped
{
    // nothing shall be done here
}

#pragma mark Dismiss

- (void)hideAndCleanUp
{
    [self removeObservers];
	//[self.view removeFromSuperview];
}

#pragma mark - WBAuthorizeWebView Public Methods

- (void)loadRequestWithURL:(NSURL *)url
{
    NSURLRequest *request =[NSURLRequest requestWithURL:url
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:20.0];
    [webView loadRequest:request];
}

- (UIActivityIndicatorView *)getActivityIndicatorView
{
    return indicatorView;
}

- (void)show:(BOOL)animated
{
    //[self sizeToFitOrientation:[self currentOrientation]];

//  	[[RCTool frontWindow] addSubview:self.view];
    
//    if (animated)
//    {
//        CATransition *animation = [CATransition animation];
//        animation.duration = 0.25;
//        animation.type = kCATransitionPush;
//        animation.subtype = kCATransitionFromRight;
//        [self.view.superview.layer addAnimation:animation
//                                         forKey:@"push_oauth"];
//    }
//    else
//    {
//        [self allAnimationsStopped];
//    }
//
//    [self addObservers];
}

- (void)hide:(BOOL)animated
{
    DIRECTOR.view.alpha = 1.0;
    [self dismissModalViewControllerAnimated:YES];
    [self hideAndCleanUp];
}

#pragma mark - UIDeviceOrientationDidChangeNotification Methods

- (void)deviceOrientationDidChange:(id)object
{
//	UIInterfaceOrientation orientation = [self currentOrientation];
//	if ([self shouldRotateToOrientation:orientation])
//    {
//        NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
//        
//		[UIView beginAnimations:nil context:nil];
//		[UIView setAnimationDuration:duration];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//		[self sizeToFitOrientation:orientation];
//		[UIView commitAnimations];
//	}
}


@end
