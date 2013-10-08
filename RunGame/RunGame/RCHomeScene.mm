//
//  RCHomeScene.m
//  BeatMole
//
//  Created by xuzepei on 5/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCHomeScene.h"
#import "RCTool.h"
#import "RCGameScene.h"
#import "RCSettingsViewController.h"
#import "RCNavigationController.h"
#import "RCAchievementViewController.h"
#import "RCAboutViewController.h"
#import "RCGameSceneParallaxBackground.h"
#import "RCStoreLayer.h"


static RCHomeScene* sharedInstance = nil;
@implementation RCHomeScene

+ (id)scene
{
    CCScene* scene = [CCScene node];
    RCHomeScene* layer = [RCHomeScene node];
    [scene addChild:layer];
    return scene;
}

+ (RCHomeScene*)sharedInstance
{
    return sharedInstance;
}

- (id)init
{
    if(self = [super init])
    {
        sharedInstance = self;
        //self.isTouchEnabled = YES;
        CGSize winSize = WIN_SIZE;
        [RCTool preloadEffectSound:MUSIC_CLICK];
        
        [RCTool addCacheFrame:@"home_scene_images.plist"];
        
        [RCTool addCacheFrame:@"game_scene_images.plist"];
        
        [self initParallaxBackground];
        
        //设置背景
        CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"home_bg.png"];
        self.bgSprite = [CCSprite spriteWithSpriteFrame:spriteFrame];
        self.bgSprite.position = ccp(winSize.width/2.0, winSize.height/2.0 + 70);
        [self addChild:self.bgSprite z:2];
        
        [self initButtons];

    }
    
    return self;
}

- (void)dealloc
{
    //[RCTool removeCacheFrame:@"home_scene_images.plist"];
    
    self.bgSprite = nil;
    self.playButton = nil;
    self.aboutButton = nil;
    self.achievementButton = nil;
    self.leaderboardButton = nil;
    self.shopButton = nil;
    self.settingsButton = nil;
    
    sharedInstance = nil;
    [super dealloc];
}

- (void)initButtons
{
    CGSize winSize = WIN_SIZE;
    
    CCMenuItem* menuItem = [CCMenuItemImage itemWithNormalImage:@"start_button.png" selectedImage:nil target:self selector:@selector(clickedPlayButton:)];
    menuItem.tag = T_HOMEMENU_START;
    self.playButton = [CCMenu menuWithItems:menuItem,nil];
    self.playButton.position = ccp(winSize.width/2.0, 100);
    [self addChild:self.playButton z:10];
    
    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"intro_button.png"];
    menuItem = [CCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedIntroButton:)];
    self.aboutButton = [CCMenu menuWithItems:menuItem,nil];
    self.aboutButton.position = ccp(40, 30);
    [self addChild:self.aboutButton z:10];
    
    sprite = [CCSprite spriteWithSpriteFrameName:@"achievement_button.png"];
    menuItem = [CCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedAchievementButton:)];
    self.achievementButton = [CCMenu menuWithItems:menuItem,nil];
    self.achievementButton.position = ccp(90, 30);
    [self addChild:self.achievementButton z:10];
    
    sprite = [CCSprite spriteWithSpriteFrameName:@"rank_button.png"];
    menuItem = [CCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedRankButton:)];
    self.leaderboardButton = [CCMenu menuWithItems:menuItem,nil];
    self.leaderboardButton.position = ccp(winSize.width - 140, 30);
    [self addChild:self.leaderboardButton z:10];
    
    sprite = [CCSprite spriteWithSpriteFrameName:@"shop_button.png"];
    menuItem = [CCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedShopButton:)];
    self.shopButton = [CCMenu menuWithItems:menuItem,nil];
    self.shopButton.position = ccp(winSize.width - 90, 30);
    [self addChild:self.shopButton z:10];
    
    
    sprite = [CCSprite spriteWithSpriteFrameName:@"settings_button.png"];
    menuItem = [CCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedSettingButton:)];
    self.settingsButton = [CCMenu menuWithItems:menuItem,nil];
    self.settingsButton.position = ccp(winSize.width - 40, 30);
    [self addChild:self.settingsButton z:10];
}


- (void)clickedPlayButton:(id)sender
{
    [RCTool playEffectSound:MUSIC_CLICK];
    
    CCScene* scene = [RCGameScene scene];
    [DIRECTOR replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:scene withColor:ccWHITE]];
}

- (void)clickedIntroButton:(id)sender
{
//    RCAboutViewController* temp = [[RCAboutViewController alloc] initWithNibName:nil bundle:nil];
//    [[RCTool getRootNavigationController] pushViewController:temp animated:YES];
//    [temp release];
//    
//    [DIRECTOR pause];
}

- (void)clickedAchievementButton:(id)sender
{
//    RCAchievementViewController* temp = [[RCAchievementViewController alloc] initWithNibName:nil bundle:nil];
//    [temp updateContent];
//    [[RCTool getRootNavigationController] pushViewController:temp animated:YES];
//    [temp release];
//    
//    [DIRECTOR pause];
}

- (void)clickedRankButton:(id)sender
{
//    RCAchievementViewController* temp = [[RCAchievementViewController alloc] initWithNibName:nil bundle:nil];
//    [temp updateContent];
//    [[RCTool getRootNavigationController] pushViewController:temp animated:YES];
//    [temp release];
//    
//    [DIRECTOR pause];
}

- (void)clickedShopButton:(id)sender
{
    [self showAllButton:NO];
    
    RCStoreLayer* layer = [[[RCStoreLayer alloc] init] autorelease];
    layer.delegate = self;
    [self addChild:layer z:100];
}

- (void)clickedHelpButton:(id)sender
{
}

- (void)clickedSettingButton:(id)sender
{
    RCSettingsViewController* temp = [[RCSettingsViewController alloc] initWithNibName:nil bundle:nil];
    
    [[RCTool getRootNavigationController] pushViewController:temp animated:YES];
    [temp release];
    [DIRECTOR pause];
}

#pragma mark - GameCenter

- (void)showLeaderboard
{
	GKLeaderboardViewController* leaderboardController = [[[GKLeaderboardViewController alloc] init] autorelease];
	if(leaderboardController != NULL)
	{
		leaderboardController.category = @"2013090100";
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self;
        [[RCTool getRootNavigationController] presentModalViewController:leaderboardController animated:YES];
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[[RCTool getRootNavigationController] dismissModalViewControllerAnimated:YES];
}

#pragma mark - Parallax Background

- (void)initParallaxBackground
{
    RCGameSceneParallaxBackground* parallaxBg = [RCGameSceneParallaxBackground node];
    [self addChild:parallaxBg z:1];
}


#pragma mark - Store

- (void)showAllButton:(BOOL)b
{
    [self.bgSprite setVisible:b];
    [self.playButton setVisible:b];
    [self.aboutButton setVisible:b];
    [self.achievementButton setVisible:b];
    [self.leaderboardButton setVisible:b];
    [self.shopButton setVisible:b];
    [self.settingsButton setVisible:b];
}

- (void)clickedStoreBackButton:(id)sender
{
    [self showAllButton:YES];
}

@end
