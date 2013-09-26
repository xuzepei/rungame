//
//  RCSnakeEntity.m
//  RunGame
//
//  Created by xuzepei on 9/23/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCSnakeEntity.h"
#import "CCAnimation+Helper.h"

@implementation RCSnakeEntity

+ (id)entity:(ENTITY_TYPE)type
{
	return [[[self alloc] initWithType:type] autorelease];
}

- (id)initWithType:(ENTITY_TYPE)type
{
	if((self = [super initWithSpriteFrameName:[NSString stringWithFormat:@"entity_%d_0.png",type]]))
	{
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
    [super dealloc];
}

- (void)update:(ccTime)delta
{
    if([self checkCollision])
    {
        if(self.panda)
            [self.panda addFaintTime];
        //[self setVisible:NO];
    }
}

- (BOOL)checkCollision
{
    if(self.isCollided)
        return NO;
    
    if(self.panda)
    {
        CGPoint pandaPoint = ccp([self.panda getBody]->GetPosition().x*PTM_RATIO,[self.panda getBody]->GetPosition().y*PTM_RATIO);
        CGFloat distance = ccpDistance(pandaPoint, self.position);
        if(distance <= self.panda.contentSize.width/2.0 + self.contentSize.width/2.0 - 6)
        {
            self.isCollided = YES;
            return YES;
        }
    }
    
    return NO;
}

@end
