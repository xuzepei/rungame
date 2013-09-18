//
//  RCSettingsViewController.h
//  BeatMole
//
//  Created by xuzepei on 5/29/13.
//
//

#import <UIKit/UIKit.h>
#import "RCBindCell.h"
#import <MessageUI/MessageUI.h>

@interface RCSettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,RCBindCellDelegate,MFMailComposeViewControllerDelegate>

@property(nonatomic,retain)UITableView* tableView;

- (void)initTableView;

@end
