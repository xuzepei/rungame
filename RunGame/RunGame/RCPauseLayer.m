//
//  RCPauseLayer.m
//  RunGame
//
//  Created by xuzepei on 9/25/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCPauseLayer.h"

@implementation RCPauseLayer

- (id)init
{
    if(self = [super init])
    {
        CGSize winSize = WIN_SIZE;
        ccColor4B bgColor = {0,0,0,160};
        CCLayerColor* bgColorLayer = [CCLayerColor layerWithColor:bgColor width:winSize.width height:winSize.height*5];
        [self addChild:bgColorLayer z:0];
        
        [self initButtons];
    }
    
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    
    [super dealloc];
}

- (void)initButtons
{
    CGSize winSize = WIN_SIZE;
    
    CCMenuItem* menuItem = [CCMenuItemImage itemWithNormalImage:@"back_button.png" selectedImage:nil disabledImage:nil target:self selector:@selector(clickedBackButton:)];
    CCMenu* menu = [CCMenu menuWithItems:menuItem, nil];
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(30, 30);
    [self addChild: menu z:50];
    
    menuItem = [CCMenuItemImage itemWithNormalImage:@"start_button.png" selectedImage:nil disabledImage:nil target:self selector:@selector(clickedResumeButton:)];
    menu = [CCMenu menuWithItems:menuItem, nil];
    menu.position = ccp(winSize.width/2.0 - 80.0, winSize.height/2.0);
    [self addChild: menu z:50];
    
    menuItem = [CCMenuItemImage itemWithNormalImage:@"restart_button.png" selectedImage:nil disabledImage:nil target:self selector:@selector(clickedRestartButton:)];
    menu = [CCMenu menuWithItems:menuItem, nil];
    menu.position = ccp(winSize.width/2.0 + 80.0, winSize.height/2.0);
    [self addChild: menu z:50];
    
}

- (void)clickedBackButton:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickedBackButton:)])
    {
        [self.delegate clickedBackButton:nil];
        [self removeFromParentAndCleanup:YES];
    }
}

- (void)clickedResumeButton:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickedResumeButton:)])
    {
        [self.delegate clickedResumeButton:nil];
        [self removeFromParentAndCleanup:YES];
    }
}

- (void)clickedRestartButton:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickedRestartButton:)])
    {
        [self.delegate clickedRestartButton:nil];
        [self removeFromParentAndCleanup:YES];
    }
}

@end
