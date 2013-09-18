//
//  RCAchievementCell.h
//  BeatMole
//
//  Created by xuzepei on 8/14/13.
//
//

#import <UIKit/UIKit.h>
#import "RCAchievementCellContentView.h"

@interface RCAchievementCell : UITableViewCell

@property(nonatomic,retain)RCAchievementCellContentView* myContentView;

@property(assign)id delegate;

- (void)updateContent:(id)item height:(CGFloat)height isLast:(BOOL)isLast;

@end
