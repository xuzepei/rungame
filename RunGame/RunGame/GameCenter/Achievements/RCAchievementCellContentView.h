//
//  RCAchievementCellContentView.h
//  BeatMole
//
//  Created by xuzepei on 8/14/13.
//
//

#import <UIKit/UIKit.h>
#import "Achievement.h"

@interface RCAchievementCellContentView : UIView

@property(nonatomic, retain)Achievement* item;
@property(nonatomic, retain)NSString* imageUrl;
@property(nonatomic, retain)UIImage* image;
@property(nonatomic, assign)id delegate;
@property(nonatomic, assign)BOOL selected;
@property(assign)BOOL isLast;

- (void)updateContent:(id)item isLast:(BOOL)isLast;

@end
