//
//  RCPanda.m
//  RunGame
//
//  Created by xuzepei on 9/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCPanda.h"
#import "CCAnimation+Helper.h"
#import "RCBox2dMoveTo.h"

#define JUMP_IMPULSE 6.0f
#define DEFAULT_SPEED_UP_TIME 20.0f
#define DEFAULT_SP_VALUE 10.0f

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
        self.jumpImpulse = 10.0;
        self.rollImpulse = 12.0;
        self.flyImpulse = 14.0;
        
        //self.speedUpCount = 1;
        self.spValue = DEFAULT_SP_VALUE;
        
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
        
        frameName = [NSString stringWithFormat:@"run_"];
        self.runAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.1];
        
 		[self scheduleUpdate];
        
        [self schedule:@selector(updateForTimes:) interval:0.5f];
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
    self.runAnimation = nil;
    
    [super dealloc];
}

- (void)update:(ccTime)delta
{
}

- (void)updateForTimes:(ccTime)delta
{
    //向下冲
    [self down];
    
    //减气力
    if([self isFlying])
        self.spValue = MAX(0,self.spValue - 0.5);
    else
        self.spValue = MIN(DEFAULT_SP_VALUE,self.spValue + 0.5);
    
    
    //检测跑动
    if(self.speedUpTime > 0)
        self.speedUpTime--;
    
    if(self.running)
    {
        if(self.speedUpTime <= 0)
        {
            self.running = NO;
            [self switchToStateAnimation];
            
            NSDictionary* token = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:self.running] forKey:@"isRunning"];
            [[NSNotificationCenter defaultCenter] postNotificationName:RUNNING_NOTIFICATION
                                                                object:nil
                                                              userInfo:token];
        }
    }
}

- (BOOL)needCheckCollision
{
    if(PST_JUMPUP == self.state || PST_WALKING == self.state|| PST_SCROLLING == self.state)
        return NO;
    
    return YES;
}

#pragma mark - Walk

- (void)walk
{
    [self stopAllActions];
    self.state = PST_WALKING;
    [self run];
    
    [self switchToStateAnimation];
    
    self.jumpCount = 0.0;
}

- (BOOL)isWalking
{
    return (self.state == PST_WALKING);
}

#pragma mark - Jump

- (void)jump
{
    //CCLOG(@"jumpCount:%d",self.jumpCount);
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
    

    
    //在跳起时不进行碰撞监测
    self.state = PST_JUMPUP;
    [self switchToStateAnimation];
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

    self.state = PST_ROLLING;
    [self switchToStateAnimation];
    
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
        
        self.state = PST_FLYING;
        [self switchToStateAnimation];
    }

    if(self.spValue > 0)
    {
        //添加冲力
        b2Vec2 impulse = b2Vec2(0,self.flyImpulse);
        
        b2Body* body = [self getBody];
        if(body)
        {
            body->ApplyLinearImpulse(impulse, body->GetPosition());
        }
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
    [self switchToStateAnimation];
    
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

#pragma mark - Run

- (void)run
{
    if(self.speedUpTime <= 0)
        return;
    
    if(NO == self.running)
    {
        self.running = YES;
        
        NSDictionary* token = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:self.running] forKey:@"isRunning"];
        [[NSNotificationCenter defaultCenter] postNotificationName:RUNNING_NOTIFICATION
                                                            object:nil
         userInfo:token];
    }
}

- (void)switchToStateAnimation
{
    switch (self.state) {
        case PST_WALKING:
        {
            [self stopAllActions];
            
            CCAnimation* tempAnimation = self.walkAnimation;
            if(self.running)
                tempAnimation = self.runAnimation;
            
            CCLOG(@"self.running:%d",self.running);
            CCAnimate* walk = [CCAnimate actionWithAnimation:tempAnimation];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:walk];
            [self runAction:repeat];
            break;
        }
        case PST_JUMPUP:
        case PST_JUMPING:
        {
            [self stopAllActions];
            CCAnimate* jump = [CCAnimate actionWithAnimation:self.jumpAnimation];
            CCSequence* sequence = [CCSequence actions:jump,nil];
            [self runAction:sequence];
            
            break;
        }
        case PST_ROLLING:
        {
            [self stopAllActions];
            CCAnimate* roll = [CCAnimate actionWithAnimation:self.rollAnimation];
            CCSequence* sequence = [CCSequence actions:roll,nil];
            sequence.tag = AT_ROLLING;
            [self runAction:sequence];
            
            break;
        }
        case PST_FLYING:
        {
            [self stopAllActions];
            CCAnimate* fly = [CCAnimate actionWithAnimation:self.flyAnimation];
            CCRepeatForever* repeat = [CCRepeatForever actionWithAction:fly];
            [self runAction:repeat];
            
            break;
        }
        case PST_SCROLLING:
        {
            [self stopAllActions];
            CCAnimate* scroll = [CCAnimate actionWithAnimation:self.scrollAnimation];
            CCCallFunc *done = [CCCallFuncN actionWithTarget:self selector:@selector(scrollDone:)];
            CCSequence* sequence = [CCSequence actions:scroll,done,nil];
            [self runAction:sequence];
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - Handle Entity

- (void)addSpeedUpTime
{
    self.speedUpTime += DEFAULT_SPEED_UP_TIME;
    
    [self run];
}

- (void)increaseSPValue
{
    self.spValue = MIN(DEFAULT_SP_VALUE,self.spValue+5);
}

- (void)decreaseSPValue
{
    self.spValue = MAX(0,self.spValue-1);
}

@end
