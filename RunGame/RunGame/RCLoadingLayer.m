//
//  RCLoadingLayer.m
//  RCGame
//
//  Created by xuzepei on 4/27/13.
//
//

#import "RCLoadingLayer.h"


@implementation RCLoadingLayer

+ (CCScene*)goToScene:(SCENE_TYPE)targetSceneType
{
    CCScene* scene = [CCScene node];
    RCLoadingLayer* layer = [[[RCLoadingLayer alloc] initWithSceneType:targetSceneType] autorelease];
    [scene addChild:layer];
    
    return scene;
}

- (id)initWithSceneType:(SCENE_TYPE)targetSceneType
{
    if(self = [super init])
    {
        _targetSceneType = targetSceneType;
        
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"载入中..." fontName:@"Marker Felt"
                                               fontSize:40];
        CGSize size = WIN_SIZE;
        label.position = CGPointMake(size.width / 2.0, size.height /2.0);
        [self addChild:label];
        
        [self scheduleOnce:@selector(doTransition:) delay:1];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)doTransition:(ccTime)delta
{
    CCScene* scene = nil;
    switch (_targetSceneType) {
        case ST_BEATMOLE:
        {
            //scene = [RCBeatMoleScene node];
            break;
        }
        default:
            break;
    }
    
    if(scene)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccWHITE]];
    }
}

@end
