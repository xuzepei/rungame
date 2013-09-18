//
//  RCSliderCell.h
//  VoiceTranslator
//
//  Created by xuzepei on 7/4/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCSliderCell : UITableViewCell

@property(nonatomic,retain)UISlider* slider;
@property(assign)SLIDER_TYPE type;

- (void)updateContent:(SLIDER_TYPE)type;

@end
