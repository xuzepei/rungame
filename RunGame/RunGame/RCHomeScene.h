//
//  RCHomeScene.h
//  BeatMole
//
//  Created by xuzepei on 5/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>

@interface RCHomeScene : CCLayer<GKLeaderboardViewControllerDelegate> {
    
}

@property(nonatomic,retain)CCSprite* bgSprite;
@property(nonatomic,retain)CCMenu* playButton;
@property(nonatomic,retain)CCMenu* aboutButton;
@property(nonatomic,retain)CCMenu* achievementButton;
@property(nonatomic,retain)CCMenu* leaderboardButton;
@property(nonatomic,retain)CCMenu* shopButton;
@property(nonatomic,retain)CCMenu* settingsButton;

+ (id)scene;
+ (RCHomeScene*)sharedInstance;

@end
