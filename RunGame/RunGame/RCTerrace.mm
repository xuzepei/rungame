//
//  RCTerrace.m
//  RunGame
//
//  Created by xuzepei on 9/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCTerrace.h"
#import "RCBox2dMoveTo.h"

@implementation RCTerrace

+ (id)terrace
{
	return [[[self alloc] initWithImage] autorelease];
}

- (id)initWithImage
{
    int random = arc4random()%5;
	if((self = [super initWithSpriteFrameName:[NSString stringWithFormat:@"terrace_%d.png",random]]))
	{
 		[self scheduleUpdate];
	}
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)update:(ccTime)delta
{
}

- (void)move:(CGPoint)offset
{
    CGPoint position = self.position;
    position.x += offset.x;
    position.y += offset.y;
    self.position = position;
    b2Vec2 positionVec2 = b2Vec2(position.x/PTM_RATIO,position.y/PTM_RATIO);
    b2Body* body = [self getBody];
    if(body)
        body->SetTransform(positionVec2,0);
}

- (void)beHit
{
    [self setBodyPos:ccp(self.position.x,self.position.y - 5)];
}

@end
