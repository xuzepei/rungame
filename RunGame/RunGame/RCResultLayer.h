//
//  RCResultLayer.h
//  RunGame
//
//  Created by xuzepei on 9/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RCResultLayerDelegate <NSObject>

- (void)clickedBackButton:(id)token;

@end

@interface RCResultLayer : CCLayer {
    
}

@property(assign)id delegate;
@property(nonatomic,retain)CCLabelAtlas* label0;
@property(nonatomic,retain)CCLabelAtlas* label1;
@property(nonatomic,retain)CCLabelAtlas* label2;

- (void)updateContent:(int)distance;

@end
