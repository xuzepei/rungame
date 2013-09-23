//
//  RCBox2dMoveTo.m
//  RunGame
//
//  Created by xuzepei on 9/19/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCBox2dMoveTo.h"
#import "RCBox2dSprite.h"

@implementation RCBox2dMoveTo

+(id) actionWithDuration: (ccTime) t position: (CGPoint) p
{
	return [[[self alloc] initWithDuration:t position:p ] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) p
{
	if( (self=[super initWithDuration: t]) )
		endPosition_ = p;
    
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: endPosition_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	startPosition_ = [(CCNode*)target_ position];
	delta_ = ccpSub( endPosition_, startPosition_ );
}

- (void)update:(ccTime)t
{
    RCBox2dSprite* temp = (RCBox2dSprite*)target_;
	[temp setPos: ccp( (startPosition_.x + delta_.x * t ), (startPosition_.y + delta_.y * t ) )];
}

@end
