//
//  RCTerrace.m
//  RunGame
//
//  Created by xuzepei on 9/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCTerrace.h"


@implementation RCTerrace

+ (id)terrace
{
	return [[[self alloc] initWithImage] autorelease];
}

- (id)initWithImage
{
    // Loading the Ship's sprite using a sprite frame name (eg the filename)
	if((self = [super initWithSpriteFrameName:@"terrace.png"]))
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

- (void)setPos:(CGPoint)pos
{
//    CGPoint position = pos;
//    self.position = position;
//    b2Vec2 positionVec2 = b2Vec2(position.x/PTM_RATIO,position.y/PTM_RATIO);
//    b2Body* body = [self getBody];
//    if(body)
//        body->SetTransform(positionVec2,0);
    
    CGPoint position = pos;
    self.position = position;
    b2Vec2 positionVec2 = b2Vec2(position.x/PTM_RATIO,position.y/PTM_RATIO);
    b2Body* body = [self getBody];
    if(body)
        body->SetTransform(positionVec2,0);
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
    CCActionInterval* moveBy = [CCMoveBy actionWithDuration:0.1f position:ccp(0,-5)];
    CCActionInterval* moveBack = [CCMoveBy actionWithDuration:0.1f position:ccp(0,5)];
    CCSequence* sequence = [CCSequence actions:moveBy,moveBack,nil];
    //[self runAction:sequence];
}

@end
