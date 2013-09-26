//
//  RCGameSceneParallaxBackground.m
//  RunGame
//
//  Created by xuzepei on 9/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCGameSceneParallaxBackground.h"

#define SPRITE_TYPE 7

@implementation RCGameSceneParallaxBackground

- (id)init
{
    if(self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScrollSpeed:) name:RUNNING_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameover:) name:GAMEOVER_NOTIFICATION object:nil];
        
        
        CGSize winSize = WIN_SIZE;
        
        ccColor4B bgColor = {133,232,255,255};
        CCLayerColor* bgColorLayer = [CCLayerColor layerWithColor:bgColor width:winSize.width height:winSize.height*5];
        bgColorLayer.anchorPoint = ccp(0.5,0);
        [self addChild:bgColorLayer z:0];
        
        CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"terrain.png"];
		self.batch = [CCSpriteBatchNode batchNodeWithTexture:spriteFrame.texture];
        [self addChild:self.batch];
        
        [self initBgObjects];
        
        // Initialize the array that contains the scroll factors for individual stripes.
		_speedFactors = [[CCArray alloc] initWithCapacity:SPRITE_TYPE];
		[_speedFactors addObject:[NSNumber numberWithFloat:0.1f]];
		[_speedFactors addObject:[NSNumber numberWithFloat:0.2f]];
		[_speedFactors addObject:[NSNumber numberWithFloat:0.3f]];
		[_speedFactors addObject:[NSNumber numberWithFloat:0.5f]];
		[_speedFactors addObject:[NSNumber numberWithFloat:0.7f]];
		[_speedFactors addObject:[NSNumber numberWithFloat:1.0f]];
		[_speedFactors addObject:[NSNumber numberWithFloat:1.0f]];
		NSAssert([_speedFactors count] == SPRITE_TYPE, @"speedFactors count does not match numStripes!");
        
		_scrollSpeed = SCROLL_SPEED;
		[self scheduleUpdate];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.batch = nil;
    self.speedFactors = nil;
    
    [super dealloc];
}

- (void)update:(ccTime)delta
{
    CGSize winSize = WIN_SIZE;
	CCSprite* sprite;
	CCARRAY_FOREACH([self.batch children], sprite)
	{
		NSNumber* factor = [_speedFactors objectAtIndex:sprite.zOrder];
		
		CGPoint pos = sprite.position;
		pos.x -= _scrollSpeed * [factor floatValue];
		
        // Reposition stripes when they're out of bounds
		if(pos.x < -winSize.width)
		{
			pos.x += (winSize.width * 2) - 2;
		}
		
		sprite.position = pos;
	}
}

- (void)initBgObjects
{
    [self.batch removeAllChildrenWithCleanup:YES];
    
    CGSize winSize = WIN_SIZE;
    
    int i = 0;
    NSString* frameName = self.running ? @"forest_1.png":@"forest.png";
    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0, 0);
    sprite.position = CGPointMake(0,100);
    [self.batch addChild:sprite z:i tag:i];
    
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0,0);
    sprite.position = ccp(winSize.width - 1,100);
    sprite.flipX = YES;
    [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
    i++;
    
    frameName = self.running ? @"terrain_1.png":@"terrain.png";
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0, 0);
    sprite.position = CGPointMake(0,50);
    [self.batch addChild:sprite z:i tag:i];
    
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0,0);
    sprite.position = ccp(winSize.width - 1,50);
    sprite.flipX = YES;
    [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
    i++;
    
    
    frameName = self.running ? @"hill_1.png":@"hill.png";
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0, 0);
    sprite.position = CGPointMake(0,30);
    [self.batch addChild:sprite z:i tag:i];
    
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0,0);
    sprite.position = ccp(winSize.width - 1,30);
    sprite.flipX = YES;
    [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
    i++;
    
    frameName = self.running ? @"tree_1.png":@"tree.png";
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0, 0);
    sprite.position = CGPointMake(0,20);
    [self.batch addChild:sprite z:i tag:i];
    
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0,0);
    sprite.position = ccp(winSize.width - 1,20);
    sprite.flipX = YES;
    [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
    i++;
    
    frameName = self.running ? @"bush_1.png":@"bush.png";
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0, 0);
    sprite.position = CGPointMake(0,20);
    [self.batch addChild:sprite z:i tag:i];
    
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0,0);
    sprite.position = ccp(winSize.width - 1,20);
    sprite.flipX = YES;
    [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
    i++;
    
    frameName = self.running ? @"grass_1.png":@"grass.png";
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0, 0);
    sprite.position = CGPointMake(0,0);
    [self.batch addChild:sprite z:i tag:i];
    
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0,0);
    sprite.position = ccp(winSize.width - 1,0);
    sprite.flipX = YES;
    [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
    i++;
    
    frameName = self.running ? @"flower_1.png":@"flower.png";
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0, 0);
    sprite.position = CGPointMake(0,0);
    [self.batch addChild:sprite z:i tag:i];
    
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    if(NO == [RCTool isIphone5])
        sprite.scale = WIN_SIZE.width/568.0f;
    sprite.anchorPoint = CGPointMake(0,0);
    sprite.position = ccp(winSize.width - 1,0);
    sprite.flipX = YES;
    [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
    i++;
}

- (void)updateScrollSpeed:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    
    self.running = [[userInfo objectForKey:@"isRunning"] boolValue];
    
//    BOOL running = [[userInfo objectForKey:@"running"] boolValue];
//    if(running)
//    {
//        _scrollSpeed = SCROLL_SPEED*3;
//    }
//    else
//    {
//        _scrollSpeed = SCROLL_SPEED;
//    }
    
    [self initBgObjects];
}

- (void)gameover:(NSNotification*)notification
{
    _scrollSpeed = 0.0;
}

@end
