//
//  RCBindCell.h
//  BeatMole
//
//  Created by xuzepei on 5/29/13.
//
//

#import <UIKit/UIKit.h>

@protocol RCBindCellDelegate <NSObject>
@optional
- (void)willChangeBindStatus:(BOOL)wantBind type:(SHARE_TYPE)type;

@end

@interface RCBindCell : UITableViewCell
{
}

@property(nonatomic,retain)UISwitch* switchButton;
@property(nonatomic,retain)NSDictionary* bindInfo;
@property(assign)id<RCBindCellDelegate> delegate;
@property(nonatomic,retain)UILabel* valueLabel;
@property(assign)SHARE_TYPE type;

- (void)updateContent:(SHARE_TYPE)type;

@end
