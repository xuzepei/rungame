//
//  PhysicsSprite.mm
//  RunGame
//
//  Created by xuzepei on 9/13/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import "PhysicsSprite.h"

// Needed PTM_RATIO
#import "HelloWorldLayer.h"

#pragma mark - PhysicsSprite
@implementation PhysicsSprite

- (void)setPhysicsBody:(b2Body *)body
{
	body_ = body;
}

// this method will only get called if the sprite is batched.
// return YES if the physics values (angles, position ) changed
// If you return NO, then nodeToParentTransform won't be called.
- (BOOL)dirty
{
	return YES;
}

// returns the transform matrix according the Chipmunk Body values
- (CGAffineTransform)nodeToParentTransform
{	
	b2Vec2 pos  = body_->GetPosition();
	
	float x = pos.x * PTM_RATIO;
	float y = pos.y * PTM_RATIO;
	
	if ( ignoreAnchorPointForPosition_ ) {
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	// Make matrix
	float radians = body_->GetAngle();
	float c = cosf(radians);
	float s = sinf(radians);
	
	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
		x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
		y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
	}
	
	// Rot, Translate Matrix
	transform_ = CGAffineTransformMake( c,  s,
									   -s,	c,
									   x,	y );	
	
	return transform_;
}

- (void)dealloc
{
    if(_fixture)
    {
        delete _fixture;
        _fixture = NULL;
    }
    
	[super dealloc];
}

- (b2Body*)getBody
{
    return body_;
}

- (void)setFixture:(b2Fixture*)fixture
{
    if(fixture != _fixture)
    {
        delete _fixture;
        _fixture = fixture;
    }
}

- (b2Fixture*)getFixture
{
    return _fixture;
}

- (CGSize)getBodySize
{
    return CGSizeMake(self.contentSize.width/PTM_RATIO, self.contentSize.height/PTM_RATIO);
}

@end
