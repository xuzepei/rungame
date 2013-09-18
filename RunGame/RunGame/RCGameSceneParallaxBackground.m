//
//  RCGameSceneParallaxBackground.m
//  RunGame
//
//  Created by xuzepei on 9/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCGameSceneParallaxBackground.h"

#define SPRITE_TYPE 7
#define SCROLL_SPEED 8.0f

@implementation RCGameSceneParallaxBackground

- (id)init
{
    if(self = [super init])
    {
        CGSize winSize = WIN_SIZE;
        
        ccColor4B bgColor = {133,232,255,255};
        CCLayerColor* bgColorLayer = [CCLayerColor layerWithColor:bgColor];
        [self addChild:bgColorLayer z:0];
        
        CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"terrace.png"];
		self.batch = [CCSpriteBatchNode batchNodeWithTexture:spriteFrame.texture];
        [self addChild:self.batch];
        
        int i = 0;
        NSString* frameName = @"forest.png";
        CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0, 0);
        sprite.position = CGPointMake(0,100);
        [self.batch addChild:sprite z:i tag:i];
        
        sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0,0);
        sprite.position = ccp(winSize.width - 1,100);
        sprite.flipX = YES;
        [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
        i++;
        
        frameName = @"terrain.png";
        sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0, 0);
        sprite.position = CGPointMake(0,50);
        [self.batch addChild:sprite z:i tag:i];
        
        sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0,0);
        sprite.position = ccp(winSize.width - 1,50);
        sprite.flipX = YES;
        [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
        i++;
        
        
        frameName = @"hill.png";
        sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0, 0);
        sprite.position = CGPointMake(0,30);
        [self.batch addChild:sprite z:i tag:i];
        
        sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0,0);
        sprite.position = ccp(winSize.width - 1,30);
        sprite.flipX = YES;
        [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
        i++;
        
        frameName = @"tree.png";
        sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0, 0);
        sprite.position = CGPointMake(0,20);
        [self.batch addChild:sprite z:i tag:i];
        
        sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0,0);
        sprite.position = ccp(winSize.width - 1,20);
        sprite.flipX = YES;
        [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
        i++;
        
        frameName = @"bush.png";
        sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0, 0);
        sprite.position = CGPointMake(0,20);
        [self.batch addChild:sprite z:i tag:i];
        
        sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0,0);
        sprite.position = ccp(winSize.width - 1,20);
        sprite.flipX = YES;
        [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
        i++;
        
        
        frameName = @"grass.png";
        sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0, 0);
        sprite.position = CGPointMake(0,0);
        [self.batch addChild:sprite z:i tag:i];
        
        sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0,0);
        sprite.position = ccp(winSize.width - 1,0);
        sprite.flipX = YES;
        [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
        i++;
        
        frameName = @"flower.png";
        sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0, 0);
        sprite.position = CGPointMake(0,0);
        [self.batch addChild:sprite z:i tag:i];
        
        sprite = [CCSprite spriteWithSpriteFrameName:frameName];
        sprite.anchorPoint = CGPointMake(0,0);
        sprite.position = ccp(winSize.width - 1,0);
        sprite.flipX = YES;
        [self.batch addChild:sprite z:i tag:i+SPRITE_TYPE];
        i++;
        
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

@end
