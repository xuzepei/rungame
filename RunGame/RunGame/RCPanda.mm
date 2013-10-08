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
        self.jumpImpulse = 16.0;
        self.rollImpulse = 18.0;
        self.flyImpulse = 20.0;
        self.money = [RCTool getRecordByType:RT_MONEY];
        self.bulletCount = [RCTool getRecordByType:RT_BULLET];
        
        //self.speedUpCount = 1;
        self.spValue = DEFAULT_SP_VALUE;

        [RCTool preloadEffectSound:MUSIC_ADD];
        [RCTool preloadEffectSound:MUSIC_JUMP];
        [RCTool preloadEffectSound:MUSIC_DEAD];
        
        NSArray* indexArray = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",nil];
        NSString* frameName = [NSString stringWithFormat:@"walk_"];
        self.walkAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.05];
        
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
        
        frameName = [NSString stringWithFormat:@"faint_"];
        self.faintAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.1];
        
        frameName = [NSString stringWithFormat:@"bomb_"];
        self.bombAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.1];
        
        indexArray = [NSArray arrayWithObjects:@"0",@"1",@"2",nil];
        frameName = [NSString stringWithFormat:@"dust_"];
        self.dustAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.1];
        
        frameName = [NSString stringWithFormat:@"bubble_"];
        self.bubbleAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.05];
        
 		[self scheduleUpdate];
        
        [self schedule:@selector(updateForTimes:) interval:0.5f];
        
        [self schedule:@selector(updateDistanceForTimes:) interval:0.1f];
	}
	return self;
}

- (void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.walkAnimation = nil;
    self.jumpAnimation = nil;
    self.rollAnimation = nil;
    self.flyAnimation = nil;
    self.scrollAnimation = nil;
    self.runAnimation = nil;
    self.dustAnimation = nil;
    self.bubbleAnimation = nil;
    self.faintAnimation = nil;
    self.bombAnimation = nil;
    
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
    {
        CGFloat spValue = self.spValue - 1;
        if(spValue < 0)
        {
            int milkCount = [RCTool getRecordByType:RT_MILK];
            if(milkCount > 0)
            {
                milkCount--;
                [RCTool setRecordByType:RT_MILK value:milkCount];
                spValue = DEFAULT_SP_VALUE/2.0;
            }
        }
        else
            spValue = self.spValue - 0.5;
        
        self.spValue = MAX(0,spValue);
    }
    else
        self.spValue = MIN(DEFAULT_SP_VALUE,self.spValue + 0.5);
    
    //减弹力
    if(self.springTime > 0)
        self.springTime--;
    
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

- (void)updateDistanceForTimes:(ccTime)delta
{
    //增加距离
    if(self.speedUpTime > 0)
        self.distance += MULTIPLE;
    else
        self.distance++;
    
    //记录最大的距离
    int max_distance = [RCTool getRecordByType:RT_DISTANCE];
    if(max_distance < self.distance)
        [RCTool setRecordByType:RT_DISTANCE value:self.distance];
    
    //减晕的时间
    if(self.faintTime > 0)
    {
        self.faintTime--;
        
        if(NO == self.isFainting)
        {
            self.isFainting = YES;
            [self switchToStateAnimation];
        }
    }
    else{
        
        if(self.isFainting)
        {
            self.isFainting = NO;
            [self switchToStateAnimation];
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
    //[self stopAllActions];
    self.state = PST_WALKING;
    [self run];
    
    [self switchToStateAnimation];
    
    self.jumpCount = 0;
}

- (BOOL)isWalking
{
    return (self.state == PST_WALKING);
}

#pragma mark - Jump

- (void)jump
{
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
    
    //[self stopAllActions];
    self.jumpCount++;

    //在跳起时不进行碰撞监测
    self.state = PST_JUMPUP;
    [RCTool playEffectSound:MUSIC_JUMP];
    [self switchToStateAnimation];
    [self performSelector:@selector(jumpUp:) withObject:nil afterDelay:0.1];
    
    //添加冲力
    CGFloat jumpImpulse = self.jumpImpulse;
    if(self.springTime > 0)
        jumpImpulse += 5;
    b2Vec2 impulse = b2Vec2(0,jumpImpulse);
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
    //[self stopAllActions];
    self.jumpCount++;

    self.state = PST_ROLLING;
    [RCTool playEffectSound:MUSIC_JUMP];
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
        //[self stopAllActions];
        
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
    //[self stopAllActions];
    
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

#pragma mark - Animation

- (void)switchToStateAnimation
{
    if(self.isDeaded)
        return;
    
    if(self.isFainting)
    {
        [self stopAllActions];
        CCAnimate* faint = [CCAnimate actionWithAnimation:self.faintAnimation];
        CCRepeatForever* repeat = [CCRepeatForever actionWithAction:faint];
        [self runAction:repeat];
        return;
    }
    
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
        {
            CCSprite* dust = [CCSprite spriteWithSpriteFrameName:@"dust_0.png"];
            dust.position = ccp(0,3);
            [self addChild:dust];
            
            CCAnimate* dustAnimate = [CCAnimate actionWithAnimation:self.dustAnimation];
            CCCallFunc *done = [CCCallFuncN actionWithTarget:self selector:@selector(dustDone:)];
            CCSequence* sequence = [CCSequence actions:dustAnimate,done,nil];
            [dust runAction:sequence];
            
        }
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

- (void)dustDone:(id)sender
{
    CCSprite* dust = (CCSprite*)sender;
    [dust removeFromParentAndCleanup:YES];
}

- (void)playBubbleAnimation
{
    CCSprite* bubble = [CCSprite spriteWithSpriteFrameName:@"bubble_0.png"];
    bubble.position = ccp(self.contentSize.width/2.0,self.contentSize.height/2.0);
    [self addChild:bubble];
    
    CCAnimate* bubbleAnimate = [CCAnimate actionWithAnimation:self.bubbleAnimation];
    CCCallFunc *done = [CCCallFuncN actionWithTarget:self selector:@selector(bubbleDone:)];
    CCSequence* sequence = [CCSequence actions:bubbleAnimate,done,nil];
    [bubble runAction:sequence];
    
    [RCTool playEffectSound:MUSIC_ADD];
}

- (void)bubbleDone:(id)sender
{
    CCSprite* bubble = (CCSprite*)sender;
    [bubble removeFromParentAndCleanup:YES];
}

#pragma mark - Handle Entity

- (void)addSpeedUpTime
{
    [self playBubbleAnimation];
    self.speedUpTime += DEFAULT_SPEED_UP_TIME;
    
    [self run];
}

- (void)increaseSPValue
{
    [self playBubbleAnimation];
    self.spValue = MIN(DEFAULT_SP_VALUE,self.spValue+5);
}

- (void)decreaseSPValue
{
    self.spValue = MAX(0,self.spValue-5);
}

- (void)addMoney
{
    [self playBubbleAnimation];
    self.money++;
    [RCTool setRecordByType:RT_MONEY value:self.money];
}

- (void)addSpringTime
{
    [self playBubbleAnimation];
    self.springTime += 10.0f;
}

- (void)addBulletCount
{
    [self playBubbleAnimation];
    self.bulletCount++;
    
    [RCTool setRecordByType:RT_BULLET value:self.bulletCount];
}

- (void)addFaintTime
{
    self.faintTime += 4.0f;
}

- (void)dead
{
    if(self.isDeaded)
        return;
    
    self.isDeaded = YES;
    [self unschedule:@selector(updateForTimes:)];
    [self unschedule:@selector(updateDistanceForTimes:)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GAMEOVER_NOTIFICATION
                                                        object:nil
                                                      userInfo:nil];
}

- (void)bomb
{
    if(self.isDeaded)
        return;
    
    [self dead];
    
    [self getBody]->SetActive(false);
    
    [self stopAllActions];
    CCAnimate* bomb = [CCAnimate actionWithAnimation:self.bombAnimation];
    CCRepeatForever* repeat = [CCRepeatForever actionWithAction:bomb];
    [self runAction:repeat];

    [self performSelector:@selector(goToHell:) withObject:nil afterDelay:1.0];
    
}

- (void)goToHell:(id)agrument
{
    
    [self getFixture]->SetSensor(true);
    [self getBody]->SetActive(true);
    
    //添加冲力
    b2Vec2 impulse = b2Vec2(0,-1);
    b2Body* body = [self getBody];
    if(body)
    {
        [RCTool pauseBgSound];
        [RCTool playEffectSound:MUSIC_DEAD];
        body->ApplyLinearImpulse(impulse, body->GetPosition());
    }
}

@end
