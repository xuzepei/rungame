//
//  RCResultLayer.m
//  RunGame
//
//  Created by xuzepei on 9/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCResultLayer.h"


@implementation RCResultLayer

- (id)init
{
    if(self = [super init])
    {

        [self initBg];
        
        [self initLabels];
        
        [self initButtons];
    }
    
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    self.label0 = nil;
    self.label1 = nil;
    self.label2 = nil;
    
    [super dealloc];
}

- (void)updateContent:(int)distance
{
    [self.label0 setString:[NSString stringWithFormat:@"%d",distance]];
    [self.label1 setString:[NSString stringWithFormat:@"%d",[RCTool getRecordByType:RT_DISTANCE]]];
    [self.label2 setString:[NSString stringWithFormat:@"%d",[RCTool getRecordByType:RT_MONEY]]];
}

- (void)initBg
{
    CGSize winSize = WIN_SIZE;
    CCSprite* bgSprite = [CCSprite spriteWithSpriteFrameName:@"result_bg.png"];
    //bgSprite.scale = winSize.width/568.0f;
    bgSprite.position = ccp(winSize.width/2.0,winSize.height/2.0);
    [self addChild:bgSprite];
}

- (void)initLabels
{
    CGSize winSize = WIN_SIZE;
    self.label0 = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"gold_number.png" itemWidth:18.0 itemHeight:20.0 startCharMap:'0'] autorelease];
    self.label0.anchorPoint = ccp(1, 0);
    self.label0.position = ccp(winSize.width/2.0 + 110, 170);
    [self addChild:self.label0];
    
    self.label1 = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"bold_number.png" itemWidth:13 itemHeight:13 startCharMap:'0'] autorelease];
    self.label1.anchorPoint = ccp(1, 0);
    self.label1.position = ccp(winSize.width/2.0 + 106, 121);
    [self addChild:self.label1];
    
    self.label2 = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"bold_number.png" itemWidth:13 itemHeight:13 startCharMap:'0'] autorelease];
    self.label2.anchorPoint = ccp(1, 0);
    self.label2.position = ccp(winSize.width/2.0 + 106, 92);
    [self addChild:self.label2];
}

- (void)initButtons
{
    CGSize winSize = WIN_SIZE;
    
    CCMenuItem* menuItem = [CCMenuItemImage itemWithNormalImage:@"back_button.png" selectedImage:nil disabledImage:nil target:self selector:@selector(clickedBackButton:)];
    CCMenu* menu = [CCMenu menuWithItems:menuItem, nil];
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(30, 30);
    [self addChild: menu z:50];
    
//    menuItem = [CCMenuItemImage itemWithNormalImage:@"upload_button.png" selectedImage:nil disabledImage:nil target:self selector:@selector(clickedUploadButton:)];
//    menu = [CCMenu menuWithItems:menuItem, nil];
//    menu.position = ccp(winSize.width/2.0 + 20.0, 50);
//    [self addChild: menu z:50];
    
    menuItem = [CCMenuItemImage itemWithNormalImage:@"restart_button_small.png" selectedImage:nil disabledImage:nil target:self selector:@selector(clickedRestartButton:)];
    menu = [CCMenu menuWithItems:menuItem, nil];
    menu.position = ccp(winSize.width/2.0 + 70.0, 50);
    [self addChild: menu z:50];
    
    menuItem = [CCMenuItemImage itemWithNormalImage:@"shop_button.png" selectedImage:nil disabledImage:nil target:self selector:@selector(clickedShopButton:)];
    menu = [CCMenu menuWithItems:menuItem, nil];
    menu.position = ccp(winSize.width/2.0 + 120.0, 50);
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

- (void)clickedUploadButton:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickedUploadButton:)])
    {
        [self.delegate clickedUploadButton:nil];
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

- (void)clickedShopButton:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickedShopButton:)])
    {
        [self.delegate clickedShopButton:nil];
        [self removeFromParentAndCleanup:YES];
    }
}

@end
