//
//  RCBombEntity.m
//  RunGame
//
//  Created by xuzepei on 9/23/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCBombEntity.h"
#import "CCAnimation+Helper.h"
#import "RCTool.h"

@implementation RCBombEntity

+ (id)entity:(ENTITY_TYPE)type
{
	return [[[self alloc] initWithType:type] autorelease];
}

- (id)initWithType:(ENTITY_TYPE)type
{
	if((self = [super initWithSpriteFrameName:[NSString stringWithFormat:@"entity_%d_0.png",type]]))
	{
        [RCTool preloadEffectSound:MUSIC_BOMB];
        
        self.type = type;
 		[self scheduleUpdate];
        
        NSArray* indexArray = [NSArray arrayWithObjects:@"0",@"1",@"2",nil];
        NSString* frameName = [NSString stringWithFormat:@"entity_%d_",type];
        CCAnimation* animation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.1];
        CCAnimate* animate = [CCAnimate actionWithAnimation:animation];
        CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
        [self runAction:repeat];
	}
    
	return self;
}

- (void)dealloc
{
    self.panda = nil;
    self.gameScene = nil;
    [super dealloc];
}

- (void)update:(ccTime)delta
{
    if([self checkCollision])
    {
        [RCTool playEffectSound:MUSIC_BOMB];
        
        CCAnimation* bomb_cloud = [CCAnimation animationWithFile:@"bomb_cloud.png" itemSize:CGSizeMake(108/2.0, 95/2.0) delay:0.1];

        CCSprite* cloudSprite = [CCSprite spriteWithFile:@"bomb_cloud.png" rect:CGRectMake(0,0,108/2.0, 95/2.0)];
        cloudSprite.position = self.position;
        [self.parent addChild:cloudSprite];
        [self setVisible:NO];
        
        CCAnimate* bombCloudAnimate = [CCAnimate actionWithAnimation:bomb_cloud];
        CCCallFunc* done = [CCCallFuncN actionWithTarget:self selector:@selector(doneBombCloud:)];
        CCSequence* sequence = [CCSequence actions:bombCloudAnimate,done,nil];
        [cloudSprite runAction:sequence];

        if(self.panda)
            [self.panda bomb];
        
        return;
    }
    
    if([self checkBeShooted])
    {
        [self setVisible:NO];
    }
}

- (void)doneBombCloud:(id)sender
{
    CCSprite* cloudSprite = (CCSprite*)sender;
    [cloudSprite setVisible:NO];
    [cloudSprite removeFromParentAndCleanup:YES];
}

- (BOOL)checkCollision
{
    if(self.isCollided)
        return NO;
    
    if(self.panda)
    {
        CGPoint pandaPoint = ccp([self.panda getBody]->GetPosition().x*PTM_RATIO,[self.panda getBody]->GetPosition().y*PTM_RATIO);
        CGPoint position = self.position;
        position.y += self.parent.position.y;
        
        CGFloat distance = ccpDistance(pandaPoint, position);
        if(distance <= self.panda.contentSize.width/2.0 + self.contentSize.width/2.0 - 6)
        {
            self.isCollided = YES;
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)checkBeShooted
{
    if(self.isShooted)
        return NO;
    
    if(self.gameScene.bulletBatchNode)
    {
        for(CCSprite* bullet in [self.gameScene.bulletBatchNode children])
        {
            CGPoint position = self.position;
            position.y += self.parent.position.y;
            
            CGFloat distance = ccpDistance(bullet.position, position);
            if(distance <= bullet.contentSize.width/2.0 + self.contentSize.width/2.0 - 6)
            {
                [bullet setVisible:NO];
                self.isShooted = YES;
                return YES;
            }
        }
    }
    
    return NO;
}

@end
