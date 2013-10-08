//
//  RCStoreLayer.m
//  RunGame
//
//  Created by xuzepei on 10/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCStoreLayer.h"

@implementation RCStoreLayer

- (id)init
{
    if(self = [super init])
    {
        self.shieldPrice = 1;//8;
        self.bambooPrice = 1;//26;
        self.milkPrice = 1;//99;
        self.isTouchEnabled = YES;
        
        [self initBg];
        
        [self initButtons];
        
        [self initLabels];
    }
    
    return self;
}

- (void)dealloc
{
    self.moneyLabel = nil;
    self.shieldLabel = nil;
    self.bambooLabel = nil;
    self.milkLabel = nil;
    self.shieldLabel2 = nil;
    self.bambooLabel2 = nil;
    self.milkLabel2 = nil;
    self.clickedButtonEffect = nil;
    
    self.delegate = nil;
    [super dealloc];
}

- (void)initBg
{
    CGSize winSize = WIN_SIZE;
    CCSprite* bgSprite = [CCSprite spriteWithSpriteFrameName:@"store_bg.png"];
    bgSprite.position = ccp(winSize.width/2.0,winSize.height/2.0);
    [self addChild:bgSprite];
    
    CCSprite* bambooSprite = [CCSprite spriteWithSpriteFrameName:@"bamboo.png"];
    bambooSprite.position = ccp(winSize.width - 20,winSize.height - 20);
    [self addChild:bambooSprite];
    
    self.clickedButtonEffect = [CCSprite spriteWithSpriteFrameName:@"clicked_button_effect.png"];
}

- (void)initLabels
{
    CGSize winSize = WIN_SIZE;
    
    self.moneyLabel = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"bold_number.png" itemWidth:13 itemHeight:13 startCharMap:'0'] autorelease];
    self.moneyLabel.anchorPoint = ccp(1, 0.5);
    self.moneyLabel.position = ccp(winSize.width - 32, winSize.height - 20);
    [self addChild:self.moneyLabel];
    
    self.shieldLabel = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"light_number.png" itemWidth:10 itemHeight:12 startCharMap:'0'] autorelease];
    self.shieldLabel.anchorPoint = ccp(1, 0);
    self.shieldLabel.position = ccp(winSize.width/2.0, 182);
    [self.shieldLabel setString:[NSString stringWithFormat:@"%d",self.shieldPrice]];
    [self addChild:self.shieldLabel];
    
    self.bambooLabel = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"light_number.png" itemWidth:10 itemHeight:12 startCharMap:'0'] autorelease];
    self.bambooLabel.anchorPoint = ccp(1, 0);
    self.bambooLabel.position = ccp(winSize.width/2.0, 136);
    [self.bambooLabel setString:[NSString stringWithFormat:@"%d",self.bambooPrice]];
    [self addChild:self.bambooLabel];
    
    self.milkLabel = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"light_number.png" itemWidth:10 itemHeight:12 startCharMap:'0'] autorelease];
    self.milkLabel.anchorPoint = ccp(1, 0);
    self.milkLabel.position = ccp(winSize.width/2.0, 90);
    [self.milkLabel setString:[NSString stringWithFormat:@"%d",self.milkPrice]];
    [self addChild:self.milkLabel];
    
    self.shieldLabel2 = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"light_number.png" itemWidth:10 itemHeight:12 startCharMap:'0'] autorelease];
    self.shieldLabel2.anchorPoint = ccp(0, 0);
    self.shieldLabel2.position = ccp(winSize.width/2.0 + 160, 182);
    [self addChild:self.shieldLabel2];
    
    self.bambooLabel2 = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"light_number.png" itemWidth:10 itemHeight:12 startCharMap:'0'] autorelease];
    self.bambooLabel2.anchorPoint = ccp(0, 0);
    self.bambooLabel2.position = ccp(winSize.width/2.0 + 160, 136);
    [self addChild:self.bambooLabel2];
    
    self.milkLabel2 = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"light_number.png" itemWidth:10 itemHeight:12 startCharMap:'0'] autorelease];
    self.milkLabel2.anchorPoint = ccp(0, 0);
    self.milkLabel2.position = ccp(winSize.width/2.0 + 160, 90);
    [self addChild:self.milkLabel2];
    
    [self updateContent];
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
    //
    //    menuItem = [CCMenuItemImage itemWithNormalImage:@"restart_button_small.png" selectedImage:nil disabledImage:nil target:self selector:@selector(clickedRestartButton:)];
    //    menu = [CCMenu menuWithItems:menuItem, nil];
    //    menu.position = ccp(winSize.width/2.0 + 70.0, 50);
    //    [self addChild: menu z:50];
    //
    //    menuItem = [CCMenuItemImage itemWithNormalImage:@"shop_button.png" selectedImage:nil disabledImage:nil target:self selector:@selector(clickedShopButton:)];
    //    menu = [CCMenu menuWithItems:menuItem, nil];
    //    menu.position = ccp(winSize.width/2.0 + 120.0, 50);
    //    [self addChild: menu z:50];
    
}

- (void)clickedBackButton:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickedStoreBackButton:)])
    {
        [self.delegate clickedStoreBackButton:nil];
        [self removeFromParentAndCleanup:YES];
    }
}

- (void)updateContent
{
    [self.moneyLabel setString:[NSString stringWithFormat:@"%d",[RCTool getRecordByType:RT_MONEY]]];
    
    [self.shieldLabel2 setString:[NSString stringWithFormat:@"%d",[RCTool getRecordByType:RT_SHIELD]]];
    
    [self.bambooLabel2 setString:[NSString stringWithFormat:@"%d",[RCTool getRecordByType:RT_BULLET]]];
    
    [self.milkLabel2 setString:[NSString stringWithFormat:@"%d",[RCTool getRecordByType:RT_MILK]]];
}

#pragma mark - Touch Event

- (void)buy:(RECORD_TYPE)type
{
    int money = [RCTool getRecordByType:RT_MONEY];
    
    if(RT_SHIELD == type)
    {
        if(money > self.shieldPrice)
        {
            money -= self.shieldPrice;
            
            int temp = [RCTool getRecordByType:RT_SHIELD];
            temp++;
            [RCTool setRecordByType:RT_SHIELD value:temp];
        }
    }
    else if(RT_BULLET == type)
    {
        if(money > self.bambooPrice)
        {
            money -= self.bambooPrice;
            
            int temp = [RCTool getRecordByType:RT_BULLET];
            temp++;
            [RCTool setRecordByType:RT_BULLET value:temp];
        }
    }
    else if(RT_MILK == type)
    {
        if(money > self.milkPrice)
        {
            money -= self.milkPrice;
            
            int temp = [RCTool getRecordByType:RT_MILK];
            temp++;
            [RCTool setRecordByType:RT_MILK value:temp];
        }
    }
    
    [RCTool setRecordByType:RT_MONEY value:money];
    [self updateContent];
}

- (void)registerWithTouchDispatcher
{
    [[DIRECTOR touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGSize winSize = WIN_SIZE;
    CGRect buttonRect0 = CGRectMake(winSize.width/2.0 - 188, 170, 132, 40);
    CGRect buttonRect1 = CGRectMake(winSize.width/2.0 - 188, 123, 132, 40);
    CGRect buttonRect2 = CGRectMake(winSize.width/2.0 - 188, 78, 132, 40);
    if(CGRectContainsPoint(buttonRect0, touchLocation))
    {
        self.clickedButtonEffect.position = ccp(winSize.width/2.0 - 122, 191);
        [self addChild:self.clickedButtonEffect z:10];
        
        [self buy:RT_SHIELD];
    }
    else if(CGRectContainsPoint(buttonRect1, touchLocation))
    {
        self.clickedButtonEffect.position = ccp(winSize.width/2.0 - 122, 145);
        [self addChild:self.clickedButtonEffect z:10];
        
        [self buy:RT_BULLET];
    }
    else if(CGRectContainsPoint(buttonRect2, touchLocation))
    {
        self.clickedButtonEffect.position = ccp(winSize.width/2.0 - 122, 98);
        [self addChild:self.clickedButtonEffect z:10];
        
        [self buy:RT_MILK];
    }
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self.clickedButtonEffect removeFromParentAndCleanup:NO];
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self.clickedButtonEffect removeFromParentAndCleanup:NO];
}

@end
