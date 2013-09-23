//
//  RCPanda.h
//  RunGame
//
//  Created by xuzepei on 9/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "RCBox2dSprite.h"
#import "CCActionManager.h"

typedef enum
{
    PST_UNKNOWN = -1,
    PST_WALKING,
    PST_JUMPUP,
    PST_JUMPING,
    PST_ROLLING,
    PST_FLYING,
    PST_SCROLLING,
}PANDA_STATE;

typedef enum
{
    AT_WALKING,
    AT_JUMPING,
    AT_RUNING,
    AT_ROLLING,
    AT_FLYING,
}ACTION_TAG;

@interface RCPanda : RCBox2dSprite {
    
}

@property(assign)PANDA_STATE state;
@property(nonatomic,retain)CCAnimation* walkAnimation;
@property(nonatomic,retain)CCAnimation* jumpAnimation;
@property(nonatomic,retain)CCAnimation* rollAnimation;
@property(nonatomic,retain)CCAnimation* flyAnimation;
@property(nonatomic,retain)CCAnimation* scrollAnimation;
@property(nonatomic,retain)CCAnimation* runAnimation;
@property(assign)float jumpImpulse;
@property(assign)float rollImpulse;
@property(assign)float flyImpulse;
@property(assign)int jumpCount;
@property(assign)BOOL running;

@property(assign)int speedUpCount; //加速次数
@property(assign)float speedUpTime; //加速时间
@property(assign)float spValue; //气力值


+ (id)panda;
- (BOOL)needCheckCollision;

- (void)walk;
- (BOOL)isWalking;
- (void)jump;
- (BOOL)isJumping;
- (void)roll;
- (BOOL)isRolling;
- (void)fly;
- (BOOL)isFlying;
- (void)scroll;
- (BOOL)isScrolling;
- (void)down;
- (void)run;

- (void)addSpeedUpTime;
- (void)increaseSPValue;


@end
