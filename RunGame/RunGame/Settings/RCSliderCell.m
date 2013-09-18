//
//  RCSliderCell.m
//  VoiceTranslator
//
//  Created by xuzepei on 7/4/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCSliderCell.h"
#import "RCTool.h"

@implementation RCSliderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		_slider = [[UISlider alloc] initWithFrame:CGRectMake(120,0,320,44)];
        [self addSubview:_slider];
        
        [_slider addTarget:self
					action:@selector(progressDidChange:)
		  forControlEvents:UIControlEventValueChanged];	
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}


- (void)dealloc {
	
	self.slider = nil;
    
    [super dealloc];
}

- (void)updateContent:(SLIDER_TYPE)type
{
    self.type = type;
    
    if(SLT_BK_VOLUME == self.type)
    {
        self.textLabel.text = @"背景音量";
        _slider.minimumValue = 0.0;
        _slider.maximumValue = 1.0;
        _slider.value = [RCTool getBKVolume];
    }
    else if(SLT_EFFECT_VOLUME == self.type)
    {
        self.textLabel.text = @"效果音量";
        _slider.minimumValue = 0.0;
        _slider.maximumValue = 1.0;
        _slider.value = [RCTool getEffectVolume];
    }
    
}

- (IBAction)progressDidChange:(UISlider*)sender
{
    UISlider* slider = (UISlider*)sender;
    
    if(SLT_BK_VOLUME == self.type)
    {
        [RCTool setBKVolume:slider.value];
    }
    else if(SLT_EFFECT_VOLUME == self.type)
    {
        [RCTool setEffectVolume:slider.value];
    }
}

@end
