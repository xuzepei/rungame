//
//  RCBindCell.m
//  BeatMole
//
//  Created by xuzepei on 5/29/13.
//
//

#import "RCBindCell.h"
#import "CUShareCenter.h"
#import "CUSinaShareClient.h"
#import "CUTencentShareClient.h"
#import "RCTool.h"

@implementation RCBindCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		_switchButton = [[UISwitch alloc] initWithFrame:CGRectMake([RCTool getScreenSize].height - 100,7,80,40)];
        if (0 > SYSTEM_VERSION - 5.0) {
            _switchButton.frame = CGRectMake([RCTool getScreenSize].height - 120, 7, 80, 40);
        }
		[_switchButton addTarget:self 
					action:@selector(switchValueDidChange:) 
		  forControlEvents:UIControlEventValueChanged];
		[self addSubview: _switchButton];
        
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 300, 40)];
        _valueLabel.font = [UIFont systemFontOfSize:14];
        _valueLabel.textColor = [UIColor grayColor];
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.lineBreakMode = UILineBreakModeTailTruncation;
        
        [self addSubview: _valueLabel];
    }
    
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}


- (void)dealloc {
	
	self.switchButton = nil;
    self.bindInfo = nil;
    self.delegate = nil;
    self.valueLabel = nil;
    
    [super dealloc];
}

- (void)switchValueDidChange:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(willChangeBindStatus:type:)])
    {
        [_delegate willChangeBindStatus:_switchButton.on type:self.type];
    }
}

- (void)updateContent:(SHARE_TYPE)type
{
    self.type = type;
    
    //NSString* name = @"";
    BOOL isBinded = NO;
    NSString* nickname = @"";
    NSString* imageName = @"";
    
    if(SHT_SINA == type)
    {
        imageName = @"sina_icon";
        
        CUShareCenter* sinaShare = (CUShareCenter*)[CUShareCenter sharedInstanceWithType:CUSHARE_SINA];
        
        if([sinaShare isBind])
        {
            nickname = [sinaShare.shareClient nickname];
            isBinded= YES;
        }
        else
        {
            isBinded = NO;
        }
    }
    else if(SHT_QQ == type)
    {
        imageName = @"qq_icon";
        
        CUShareCenter* qqShare = (CUShareCenter*)[CUShareCenter sharedInstanceWithType:CUSHARE_QQ];
        
        if([qqShare isBind])
        {
            nickname = [qqShare.shareClient nickname];
            isBinded = YES;
        }
        else
        {
            isBinded = NO;
        }
    }

    if(0 == [nickname length])
        nickname = @"";
    _valueLabel.text = nickname;
    //self.detailTextLabel.text = nickname;
    
    _switchButton.on = isBinded;
    
    self.imageView.image = [UIImage imageNamed:imageName];
}

@end
