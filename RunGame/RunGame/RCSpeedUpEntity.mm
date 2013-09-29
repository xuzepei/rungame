//
//  RCSpeedUpEntity.m
//  RunGame
//
//  Created by xuzepei on 9/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCSpeedUpEntity.h"


@implementation RCSpeedUpEntity

+ (id)entity:(ENTITY_TYPE)type
{
	return [[[self alloc] initWithType:type] autorelease];
}

- (id)initWithType:(ENTITY_TYPE)type
{
	if((self = [super initWithSpriteFrameName:[NSString stringWithFormat:@"entity_%d.png",type]]))
	{
        self.type = type;
 		[self scheduleUpdate];
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
            [self.panda addSpeedUpTime];
        [self setVisible:NO];
    }
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

@end
