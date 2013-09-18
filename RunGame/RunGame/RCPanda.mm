//
//  RCPanda.m
//  RunGame
//
//  Created by xuzepei on 9/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCPanda.h"
#import "CCAnimation+Helper.h"

#define JUMP_IMPULSE 6.0f

@implementation RCPanda

+ (id)panda
{
	return [[[self alloc] initWithImage] autorelease];
}

- (id)initWithImage
{
    // Loading the Ship's sprite using a sprite frame name (eg the filename)
	if ((self = [super initWithSpriteFrameName:@"walk_0.png"]))
	{
        self.jumpImpulse = 16.0;
        self.rollImpulse = 18.0;
        self.flyImpulse = 20.0;
        
        NSArray* indexArray = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",nil];
        NSString* frameName = [NSString stringWithFormat:@"walk_"];
        self.walkAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.1];
        
        frameName = [NSString stringWithFormat:@"jump_"];
        self.jumpAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.1];
        
        frameName = [NSString stringWithFormat:@"roll_"];
        self.rollAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.1];
        
        frameName = [NSString stringWithFormat:@"fly_"];
        self.flyAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.1];
        
        frameName = [NSString stringWithFormat:@"scroll_"];
        self.scrollAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.1];
        
 		[self scheduleUpdate];
        
        [self schedule:@selector(updateForTimes:) interval:1.0f];
	}
	return self;
}

- (void)dealloc
{
    self.walkAnimation = nil;
    self.jumpAnimation = nil;
    self.rollAnimation = nil;
    self.flyAnimation = nil;
    self.scrollAnimation = nil;
    
    [super dealloc];
}

- (void)update:(ccTime)delta
{
    
}

- (void)updateForTimes:(ccTime)delta
{
    //向下冲
    [self down];
}

- (BOOL)needCheckCollision
{
    if(PST_JUMPUP == self.state || PST_WALKING == self.state || PST_SCROLLING == self.state)
        return NO;
    
    return YES;
}

#pragma mark - Walk

- (void)walk
{
//    if([self isScrolling])
//        return;
    
    [self stopAllActions];

    CCAnimate* walk = [CCAnimate actionWithAnimation:self.walkAnimation];
    CCRepeatForever* repeat = [CCRepeatForever actionWithAction:walk];
    //repeat.tag = AT_WALKING;
    [self runAction:repeat];
    
    self.state = PST_WALKING;
    self.jumpCount = 0.0;
}

- (BOOL)isWalking
{
    return (self.state == PST_WALKING);
}

#pragma mark - Jump

- (void)jump
{
    CCLOG(@"jumpCount:%d",self.jumpCount);
    if(PST_JUMPUP == self.state)
        return;
    
    if(PST_JUMPING == self.state)
    {
        [self roll];
        return;
    }
    else if(PST_ROLLING == self.state || PST_FLYING == self.state)
    {
        [self fly];
        return;
    }
    
    [self stopAllActions];
    self.jumpCount++;
    
    CCAnimate* jump = [CCAnimate actionWithAnimation:self.jumpAnimation];
    CCSequence* sequence = [CCSequence actions:jump,nil];
    //sequence.tag = AT_JUMPING;
    [self runAction:sequence];
    
    //在跳起时不进行碰撞监测
    self.state = PST_JUMPUP;
    [self performSelector:@selector(jumpUp:) withObject:nil afterDelay:0.1];
    
    //添加冲力
    b2Vec2 impulse = b2Vec2(0,self.jumpImpulse);
    b2Body* body = [self getBody];
    if(body)
    {
        body->ApplyLinearImpulse(impulse, body->GetPosition());
    }
}

- (void)jumpUp:(id)argument
{
    self.state = PST_JUMPING;
}

- (BOOL)isJumping
{
    return (PST_JUMPING == self.state);
}

#pragma mark - Roll

- (void)roll
{
    [self stopAllActions];
    self.jumpCount++;

    CCAnimate* roll = [CCAnimate actionWithAnimation:self.rollAnimation];
    CCSequence* sequence = [CCSequence actions:roll,nil];
    sequence.tag = AT_ROLLING;
    [self runAction:sequence];
    
    self.state = PST_ROLLING;
    
    //添加冲力
    b2Vec2 impulse = b2Vec2(0,self.rollImpulse);
    b2Body* body = [self getBody];
    if(body)
    {
        body->ApplyLinearImpulse(impulse, body->GetPosition());
    }
}

- (BOOL)isRolling
{
    return (PST_ROLLING == self.state);
}

#pragma mark - Fly

- (void)fly
{
    self.jumpCount++;
    
    if(PST_FLYING != self.state)
    {
        [self stopAllActions];
        
        CCAnimate* fly = [CCAnimate actionWithAnimation:self.flyAnimation];
        CCRepeatForever* repeat = [CCRepeatForever actionWithAction:fly];
        [self runAction:repeat];
        
        self.state = PST_FLYING;
    }

    //添加冲力
    b2Vec2 impulse = b2Vec2(0,self.flyImpulse);
    b2Body* body = [self getBody];
    if(body)
    {
        body->ApplyLinearImpulse(impulse, body->GetPosition());
    }
}

- (BOOL)isFlying
{
    return (PST_FLYING == self.state);
}

#pragma mark - Scoll

- (void)scroll
{
    [self stopAllActions];
    self.state = PST_SCROLLING;
    
    CCAnimate* scroll = [CCAnimate actionWithAnimation:self.scrollAnimation];
    CCCallFunc *done = [CCCallFuncN actionWithTarget:self selector:@selector(scrollDone:)];
    CCSequence* sequence = [CCSequence actions:scroll,done,nil];
    [self runAction:sequence];
}

- (BOOL)isScrolling
{
    return (PST_SCROLLING == self.state);
}

- (void)scrollDone:(id)sender
{
    [self walk];
}

#pragma mark - Down

- (void)down
{
    if(PST_UNKNOWN == self.state || PST_WALKING == self.state || PST_FLYING == self.state)
    {
        //添加冲力
        b2Vec2 impulse = b2Vec2(0,-1);
        b2Body* body = [self getBody];
        if(body)
        {
            body->ApplyLinearImpulse(impulse, body->GetPosition());
        }
    }
}

@end
