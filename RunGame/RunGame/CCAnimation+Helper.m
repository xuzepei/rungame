//
//  CCAnimation+Helper.m
//  RCGame
//
//  Created by xuzepei on 5/13/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CCAnimation+Helper.h"

@implementation CCAnimation (Helper)

// Creates an animation from single files.
+ (CCAnimation*)animationWithFile:(NSString*)name frameCount:(int)frameCount delay:(float)delay
{
	// load the animation frames as textures and create the sprite frames
	NSMutableArray* frames = [NSMutableArray arrayWithCapacity:frameCount];
	for (int i = 0; i < frameCount; i++)
	{
		// Assuming all animation files are named "nameX.png" with X being a consecutive number starting with 0.
		NSString* file = [NSString stringWithFormat:@"%@%i.png", name, i];
		CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:file];
        
		// Assuming that image file animations always use the whole image for each animation frame.
		CGSize texSize = texture.contentSize;
		CGRect texRect = CGRectMake(0, 0, texSize.width, texSize.height);
		CCSpriteFrame* frame = [CCSpriteFrame frameWithTexture:texture rect:texRect];
		
		[frames addObject:frame];
	}
	
	// create an animation object from all the sprite animation frames
	return [CCAnimation animationWithSpriteFrames:frames delay:delay];
}

// Creates an animation from sprite frames.
+ (CCAnimation*)animationWithFrame:(NSString*)frame frameCount:(int)frameCount delay:(float)delay
{
	// load the ship's animation frames as textures and create a sprite frame
	NSMutableArray* frames = [NSMutableArray arrayWithCapacity:frameCount];
	for (int i = 0; i < frameCount; i++)
	{
		NSString* file = [NSString stringWithFormat:@"%@%i.png", frame, i];
		CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		CCSpriteFrame* frame = [frameCache spriteFrameByName:file];
		[frames addObject:frame];
	}
	
	// return an animation object from all the sprite animation frames
	return [CCAnimation animationWithSpriteFrames:frames delay:delay];
}

// Creates an animation from sprite frames.
+ (CCAnimation*)animationWithFrame:(NSString*)frame indexArray:(NSArray*)indexArray delay:(float)delay
{
	// load the ship's animation frames as textures and create a sprite frame
	NSMutableArray* frames = [NSMutableArray arrayWithCapacity:[indexArray count]];
	for (NSString* index in indexArray)
	{
		NSString* file = [NSString stringWithFormat:@"%@%@.png", frame,index];
		CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		CCSpriteFrame* frame = [frameCache spriteFrameByName:file];
		[frames addObject:frame];
	}
	
	// return an animation object from all the sprite animation frames
	return [CCAnimation animationWithSpriteFrames:frames delay:delay];
}

+ (CCAnimation*)animationWithFile:(NSString*)filename itemSize:(CGSize)itemSize delay:(float)delay
{
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: filename];
    
    CGSize imageSize = [texture contentSizeInPixels];
    CCAnimation* animation = [CCAnimation animation];
    animation.delayPerUnit = delay;
    
    int count = (int)(imageSize.width / itemSize.width);
    for(int i = 0; i < count; i++)
    {
        [animation addSpriteFrameWithTexture:texture rect:CGRectMake(i*itemSize.width, 0, itemSize.width, itemSize.height)];
    }
    
    return animation;
}

@end

