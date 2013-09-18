//
//  RCSettingsViewController.m
//  BeatMole
//
//  Created by xuzepei on 5/29/13.
//
//

#import "RCSettingsViewController.h"
#import "RCTool.h"
#import "CUShareCenter.h"
#import "RCSliderCell.h"
#import "SimpleAudioEngine.h"

@interface RCSettingsViewController ()

@end

@implementation RCSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.tableView = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.tableView)
        [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"设置";
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(clickedBackButton:)] autorelease];
    
    [self initTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    self.tableView = nil;
}

- (void)clickedBackButton:(id)sender
{
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:[RCTool getEffectVolume]];
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:[RCTool getBKVolume]];
    
    [DIRECTOR resume];

}

#pragma mark - UITableView

- (void)initTableView
{
    if(nil == _tableView)
    {
        //init table view
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,[RCTool getScreenSize].height,[RCTool getScreenSize].width - NAVIGATION_BAR_HEIGHT)
                                                  style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
	
	[self.view addSubview:_tableView];
    
    [_tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(0 == section)
        return 2;
    else if(1 == section)
        return 2;
    else if(2 == section)
        return 2;
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(0 == section)
    {
        return @"控制";
    }
    else if(1 == section)
    {
        return @"分享";
    }
    else if(2 == section)
    {
        return @"其他";
    }
    
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(2 == section)
        return 40.0;
    
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId0 = @"cellId0";
    static NSString *cellId1 = @"cellId1";
    static NSString *cellId2 = @"cellId2";
    static NSString *cellId3 = @"cellId3";
    static NSString *cellId4 = @"cellId4";
    static NSString *cellId5 = @"cellId5";
    
    UITableViewCell *cell = nil;

    if(0 == indexPath.section)
    {
        if(0 == indexPath.row)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellId0];
            if (cell == nil)
            {
                cell = [[[RCSliderCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                          reuseIdentifier: cellId0] autorelease];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"背景音量";
            }
            
            RCSliderCell* temp = (RCSliderCell*)cell;
            [temp updateContent:SLT_BK_VOLUME];
        }
        else if(1 == indexPath.row)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellId0];
            if (cell == nil)
            {
                cell = [[[RCSliderCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                            reuseIdentifier: cellId0] autorelease];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"效果音量";
            }
            
            RCSliderCell* temp = (RCSliderCell*)cell;
            [temp updateContent:SLT_EFFECT_VOLUME];
        }
    }
    else if(1 == indexPath.section)
    {
        if(0 == indexPath.row)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellId2];
            if (cell == nil)
            {
                cell = [[[RCBindCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                          reuseIdentifier: cellId2] autorelease];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"新浪微博";
            }
            
            RCBindCell* temp = (RCBindCell*)cell;
            temp.delegate = self;
            [temp updateContent:SHT_SINA];
            
        }
        else if(1 == indexPath.row)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellId3];
            if (cell == nil)
            {
                cell = [[[RCBindCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                          reuseIdentifier: cellId3] autorelease];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"腾讯微博";
            }
            
            RCBindCell* temp = (RCBindCell*)cell;
            temp.delegate = self;
            [temp updateContent:SHT_QQ];
        }
    }
    else if(2 == indexPath.section)
    {
        if(0 == indexPath.row)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellId4];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                          reuseIdentifier: cellId4] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"新手帮助";
            }
            
        }
        else if(1 == indexPath.row)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellId5];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                          reuseIdentifier: cellId5] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"意见反馈";
            }
        }
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if(2 == indexPath.section)
    {
        if(0 == indexPath.row)
        {
        }
        else if(1 == indexPath.row)
        {
            [self feedback];
        }
    }
}

#pragma mark - Bind

- (void)willChangeBindStatus:(BOOL)wantBind type:(SHARE_TYPE)type
{
    if(wantBind)
    {
        if(SHT_SINA == type)
        {
            CUShareCenter* sinaShare = [CUShareCenter sharedInstanceWithType:CUSHARE_SINA];
            
            if(NO == [sinaShare isBind])
            {
                [sinaShare bind:self];
            }
        }
        else
        {
            CUShareCenter* qqShare = [CUShareCenter sharedInstanceWithType:CUSHARE_QQ];
            
            if(NO == [qqShare isBind])
            {
                [qqShare bind:self];
            }
        }
    }
    else
    {
        if(SHT_SINA == type)
        {
            CUShareCenter* sinaShare = [CUShareCenter sharedInstanceWithType:CUSHARE_SINA];
            
            if([sinaShare isBind])
            {
                [sinaShare unBind];
            }
        }
        else
        {
            CUShareCenter* qqShare = [CUShareCenter sharedInstanceWithType:CUSHARE_QQ];
            
            if([qqShare isBind])
            {
                [qqShare unBind];
            }
        }
    }
    
    [self.tableView reloadData];
}

- (void)feedback
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
//            mailComposeViewController.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
            mailComposeViewController.mailComposeDelegate = self;
            
            
            NSMutableString* subject = [[[NSMutableString alloc] init] autorelease];
            [subject appendString:@"来自补兵达人的意见反馈 "];
            NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            [subject appendFormat:@"版本号:%@",version];
            [subject appendFormat:@",系统:iOS %.2f",[RCTool systemVersion]];
            
            [subject appendFormat:@",设备类型:%d",UI_USER_INTERFACE_IDIOM()];
            
            [mailComposeViewController setSubject:subject];
            
            [mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"master@rumtel.com"]];
            
            NSMutableString *mailContent = [[NSMutableString alloc] init];
            [mailContent appendString:@"如果您有什么问题或意见，请让我们知道。我们会尽快给您答复。"];
            
            [mailComposeViewController setMessageBody:mailContent isHTML:NO];
            [mailContent release];
            [self presentModalViewController:mailComposeViewController animated:YES];
            [mailComposeViewController release];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
    
    if(MFMailComposeResultSent == result)
    {
        [RCTool showAlert:@"提示" message:@"邮件发送成功！"];
    }
}

@end
