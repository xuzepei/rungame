//
//  RCAboutViewController.m
//  BeatMole
//
//  Created by xuzepei on 9/12/13.
//
//

#import "RCAboutViewController.h"
#import "RCTool.h"

@interface RCAboutViewController ()

@end

@implementation RCAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
    self.backButton = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImage* bgImage = [UIImage imageNamed:@"about_bg"];
    UIImageView* bgImageView = [[[UIImageView alloc] initWithImage:bgImage] autorelease];
    if([RCTool isIphone5])
        bgImageView.frame = CGRectMake(0, 0, 568, 320);
    else
        bgImageView.frame = CGRectMake(-44, 0, 568, 320);
    
    [self.view addSubview:bgImageView];
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

@end
