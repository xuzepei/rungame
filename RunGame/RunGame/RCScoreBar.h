//
//  RCScoreBar.h
//  RunGame
//
//  Created by xuzepei on 9/24/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPanda.h"

@interface RCScoreBar : CCSprite {
    
}

@property(assign)RCPanda* panda;
@property(nonatomic,retain)CCSprite* spBar;
@property(nonatomic,retain)CCLabelAtlas* label0;
@property(nonatomic,retain)CCLabelAtlas* label1;
@property(nonatomic,retain)CCLabelAtlas* label2;
@property(nonatomic,retain)CCLabelAtlas* label3;
@property(nonatomic,retain)CCLabelAtlas* label4;

+ (id)bar;
- (void)updateSP;
- (void)updateShieldCount;
- (void)updateBulletCount;
- (void)updateMilkCount;
- (void)updateMoney;
- (void)updateDistance;

@end
