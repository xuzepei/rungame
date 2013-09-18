//
//  RCAchievementViewController.h
//  BeatMole
//
//  Created by xuzepei on 8/14/13.
//
//

#import <UIKit/UIKit.h>

@interface RCAchievementViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain)NSMutableArray* itemArray;
@property(nonatomic,retain)UITableView* tableView;
@property(nonatomic,retain)UIButton* backButton;

- (void)initTableView;
- (void)updateContent;

@end
