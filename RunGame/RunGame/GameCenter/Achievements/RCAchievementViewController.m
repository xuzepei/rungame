//
//  RCAchievementViewController.m
//  BeatMole
//
//  Created by xuzepei on 8/14/13.
//
//

#import "RCAchievementViewController.h"
#import "RCTool.h"
#import "RCAchievementCell.h"
#import "RCAchievement.h"
#import "Achievement.h"

@interface RCAchievementViewController ()

@end

@implementation RCAchievementViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _itemArray = [[NSMutableArray alloc] init];
        
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backButton.frame = CGRectMake(0,0, 60, 60);
        [self.backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
        [self.backButton setImage:[UIImage imageNamed:@"back_button_selected"] forState:UIControlStateHighlighted];
        [self.backButton addTarget:self action:@selector(clickedBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.backButton];
    
    }
    return self;
}

- (void)dealloc
{
    self.itemArray = nil;
    self.tableView = nil;
    self.backButton = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImage* bgImage = [UIImage imageNamed:@"achievement_bg"];
    UIImageView* bgImageView = [[[UIImageView alloc] initWithImage:bgImage] autorelease];
    if([RCTool isIphone5])
        bgImageView.frame = CGRectMake(0, 0, 568, 320);
    else
        bgImageView.frame = CGRectMake(-44, 0, 568, 320);

    [self.view addSubview:bgImageView];
    
    [self initTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickedBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
    self.navigationController.navigationBarHidden = YES;
    
    [DIRECTOR resume];
}

- (void)updateContent
{
    NSArray* array = [RCAchievement getAchievements];
    if([array count])
    {
        [_itemArray removeAllObjects];
        [_itemArray addObjectsFromArray:array];
        
        [_tableView reloadData];
    }
}

#pragma mark - UITableView

- (CGFloat)getCellHeight:(Achievement*)item
{
    if(nil == item)
        return 0.0;
    
    CGFloat height = 30.0;
    NSString* title = item.name;
    if([title length])
    {
        CGSize size = [title sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)];
        height += MAX(size.height, 20.0);
    }
    
    NSString* desc = item.desc;
    if([desc length])
    {
        CGSize size = [desc sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)];
        height += MAX(size.height, 20.0);
    }
    
    return MAX(height,80.0);
}

- (void)initTableView
{
    if(nil == _tableView)
    {
        //init table view
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(([RCTool getScreenSize].height - 400)/2.0,60,400,[RCTool getScreenSize].width - 80)
                                                  style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.opaque = NO;
        _tableView.backgroundView = nil;
        _tableView.dataSource = self;
        //_tableView.separatorColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
	
	[self.view addSubview:_tableView];
    
    [_tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (id)getCellDataAtIndexPath: (NSIndexPath*)indexPath
{
    if(indexPath.row >= [_itemArray count])
        return nil;
    
    return [_itemArray objectAtIndex: indexPath.row];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Achievement* item = (Achievement*)[self getCellDataAtIndexPath:indexPath];
    return [self getCellHeight:item];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"cellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell == nil)
    {
        cell = [[[RCAchievementCell alloc] initWithStyle: UITableViewCellStyleDefault
                                       reuseIdentifier: cellId] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    Achievement* item = (Achievement*)[self getCellDataAtIndexPath: indexPath];
    if(item)
    {
        RCAchievementCell* temp = (RCAchievementCell*)cell;
        [temp updateContent:item height:[self getCellHeight:item] isLast:NO];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

@end
