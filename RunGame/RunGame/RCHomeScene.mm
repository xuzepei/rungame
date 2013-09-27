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
        
        //设置背景
        CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"home_bg.png"];
        CCSprite* bgSprite = [CCSprite spriteWithSpriteFrame:spriteFrame];
        bgSprite.position = ccp(winSize.width/2.0, winSize.height/2.0);
        [self addChild:bgSprite];
        
        
        //设置菜单
//        CCMenuItemImage* menuItem0 = [CCMenuItemImage itemWithNormalImage:@"achievement_button.png" selectedImage:@"achievement_button_selected.png" target:self selector:@selector(clickedMenuItem:)];
//        menuItem0.tag = T_HOMEMENU_ACHIEVEMENT;
//        
//        CCMenuItemImage* menuItem1 = [CCMenuItemImage itemWithNormalImage:@"leaderboard_button.png" selectedImage:@"leaderboard_button_selected.png" target:self selector:@selector(clickedMenuItem:)];
//        menuItem1.tag = T_HOMEMENU_LEADERBOARD;
//        
//        CCMenu* leftMenu = [CCMenu menuWithItems:menuItem0,menuItem1,nil];
//        [leftMenu alignItemsVerticallyWithPadding:10.0];
//        leftMenu.position = ccp(68, 202);
//        [self addChild:leftMenu];
        
        CCMenuItem* menuItem = [CCMenuItemImage itemWithNormalImage:@"start_button.png" selectedImage:nil target:self selector:@selector(clickedMenuItem:)];
        menuItem.tag = T_HOMEMENU_START;
        CCMenu* menu = [CCMenu menuWithItems:menuItem,nil];
        menu.position = ccp(WIN_SIZE.width/2.0, 100);
        [self addChild:menu];

//        CCMenuItem* menuItem3 = [CCMenuItemImage itemWithNormalImage:@"home_menu_about.png" selectedImage:@"home_menu_about_selected.png" target:self selector:@selector(clickedMenuItem:)];
//        menuItem3.tag = T_HOMEMENU_ABOUT;
//        
//        CCMenuItem* menuItem4 = [CCMenuItemImage itemWithNormalImage:@"home_menu_setting.png" selectedImage:@"home_menu_setting_selected.png" target:self selector:@selector(clickedMenuItem:)];
//        menuItem4.tag = T_HOMEMENU_SETTING;
        
//        CCMenu* menu = [CCMenu menuWithItems:menuItem2,nil];
//        rightMenu.position = ccp(170, 30);
//        [self addChild:rightMenu];

    }
    
    return self;
}

- (void)dealloc
{
    [RCTool removeCacheFrame:@"home_scene_images.plist"];
    
    sharedInstance = nil;
    [super dealloc];
}

- (void)clickedMenuItem:(id)sender
{
    [RCTool playEffectSound:MUSIC_CLICK];
    
    CCMenuItem* menuItem = (CCMenuItem*)sender;
    CCLOG(@"%d",menuItem.tag);
    switch (menuItem.tag)
    {
        case T_HOMEMENU_START:
        {
            CCScene* scene = [RCGameScene scene];
            [DIRECTOR replaceScene:[CCTransitionFade transitionWithDuration:0.0 scene:scene withColor:ccWHITE]];
            break;
        }
        case T_HOMEMENU_LEADERBOARD:
        {
            [self showLeaderboard];
            break;
        }
        case T_HOMEMENU_ACHIEVEMENT:
        {
            RCAchievementViewController* temp = [[RCAchievementViewController alloc] initWithNibName:nil bundle:nil];
            [temp updateContent];
            [[RCTool getRootNavigationController] pushViewController:temp animated:YES];
            [temp release];
            
            [DIRECTOR pause];
            
            break;
        }
        case T_HOMEMENU_ABOUT:
        {
            RCAboutViewController* temp = [[RCAboutViewController alloc] initWithNibName:nil bundle:nil];
            [[RCTool getRootNavigationController] pushViewController:temp animated:YES];
            [temp release];
            
            [DIRECTOR pause];
            
            break;
        }
        case T_HOMEMENU_SETTING:
        {
            RCSettingsViewController* temp = [[RCSettingsViewController alloc] initWithNibName:nil bundle:nil];
            
            [[RCTool getRootNavigationController] pushViewController:temp animated:YES];
             [temp release];
            [DIRECTOR pause];
             
            break;
        }
            
        default:
            break;
    }
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

@end
