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

+ (id)scene;
+ (RCHomeScene*)sharedInstance;

@end
