//
//  RCPauseLayer.h
//  RunGame
//
//  Created by xuzepei on 9/25/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RCPauseLayerDelegate <NSObject>

- (void)clickedBackButton:(id)token;
- (void)clickedResumeButton:(id)token;
- (void)clickedRestartButton:(id)token;

@end

@interface RCPauseLayer : CCLayer {
    
}

@property(assign)id delegate;

@end
