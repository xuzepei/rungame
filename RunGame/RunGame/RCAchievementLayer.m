//
//  RCAchievementLayer.m
//  RunGame
//
//  Created by xuzepei on 10/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCAchievementLayer.h"


@implementation RCAchievementLayer

- (id)init
{
    if(self = [super init])
    {
        self.isTouchEnabled = YES;
        
        [self initBg];
        
        [self initButtons];
        
        [self updateContent];
    }
    
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    [super dealloc];
}

- (void)initBg
{
    CGSize winSize = WIN_SIZE;
    CCSprite* bgSprite = [CCSprite spriteWithSpriteFrameName:@"achievement_bg.png"];
    bgSprite.position = ccp(winSize.width/2.0,winSize.height/2.0);
    [self addChild:bgSprite];
}

- (void)initButtons
{
    CCMenuItem* menuItem = [CCMenuItemImage itemWithNormalImage:@"back_button.png" selectedImage:nil disabledImage:nil target:self selector:@selector(clickedBackButton:)];
    CCMenu* menu = [CCMenu menuWithItems:menuItem, nil];
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(30, 30);
    [self addChild: menu z:50];
}

- (void)clickedBackButton:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickedAchievementBackButton:)])
    {
        [self.delegate clickedAchievementBackButton:nil];
        [self removeFromParentAndCleanup:YES];
    }
}

- (void)updateContent
{
    CGSize winSize = WIN_SIZE;
    for(int i = 0; i < 6; i++)
    {
        NSString* frameName = [NSString stringWithFormat:@"achievement_%d.png",i];
        BOOL b = [RCTool checkAchievementByType:i];
        if(b)
            frameName = [NSString stringWithFormat:@"achievement_%d%d.png",i,i];
        
        CCSprite* achievement = [CCSprite spriteWithSpriteFrameName:frameName];
        
        CGFloat offset_x = winSize.width/2.0 - (achievement.contentSize.width + 16);
        int y = i;
        CGFloat offset_y = winSize.height/2.0 + 20;
        if(i >= 3)
        {
            offset_y = winSize.height/2.0 - 66;
            y -= 3;
        }
        
        achievement.position = ccp(offset_x + (achievement.contentSize.width + 16)*y,offset_y);
        [self addChild:achievement];
    }
}

#pragma mark - Touch Event

- (void)registerWithTouchDispatcher
{
    [[DIRECTOR touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
//    CCParticleSystem* system = [CCParticleSystemQuad particleWithFile:@"touch.plist"];
//    system.position = touchLocation;
//    system.autoRemoveOnFinish = YES;
//	[self addChild:system z:1 tag:1];
    
//    CGSize winSize = WIN_SIZE;
//    CGRect buttonRect0 = CGRectMake(winSize.width/2.0 - 188, 170, 132, 40);
//    CGRect buttonRect1 = CGRectMake(winSize.width/2.0 - 188, 123, 132, 40);
//    CGRect buttonRect2 = CGRectMake(winSize.width/2.0 - 188, 78, 132, 40);
//    if(CGRectContainsPoint(buttonRect0, touchLocation))
//    {
//        self.clickedButtonEffect.position = ccp(winSize.width/2.0 - 122, 191);
//        [self addChild:self.clickedButtonEffect z:10];
//        
//        [self buy:RT_SHIELD];
//    }
//    else if(CGRectContainsPoint(buttonRect1, touchLocation))
//    {
//        self.clickedButtonEffect.position = ccp(winSize.width/2.0 - 122, 145);
//        [self addChild:self.clickedButtonEffect z:10];
//        
//        [self buy:RT_BULLET];
//    }
//    else if(CGRectContainsPoint(buttonRect2, touchLocation))
//    {
//        self.clickedButtonEffect.position = ccp(winSize.width/2.0 - 122, 98);
//        [self addChild:self.clickedButtonEffect z:10];
//        
//        [self buy:RT_MILK];
//    }
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}

@end
