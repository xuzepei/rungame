//
//  CCLayer+CCLayer_Opaque.m
//  BeatMole
//
//  Created by xuzepei on 6/13/13.
//
//

#import "CCLayer+CCLayer_Opaque.h"

@implementation CCLayer (CCLayer_Opaque)

- (void)setOpacity:(float)opacity
{
    for(CCNode *node in [self children])
    {
        if([node conformsToProtocol:@protocol( CCRGBAProtocol)])
        {
            [(id<CCRGBAProtocol>) node setOpacity: opacity];
        }
    }
}

@end
