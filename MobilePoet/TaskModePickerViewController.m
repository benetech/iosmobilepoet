//
//  TaskModePickerViewController.m
//  MobilePoet
//
//  Created by Joseph Maag on 6/12/14.
//
//

#import "TaskModePickerViewController.h"

@interface TaskModePickerViewController ()
@property (strong, nonatomic) UIButton *backButton;
@end

@implementation TaskModePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *backImage = [UIImage imageNamed:@"backToMenuButton.png"];
    [backButton setBackgroundImage:backImage forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    backButton.transform = CGAffineTransformMakeScale(55.0f/backButton.frame.size.width, 55.0f/backButton.frame.size.width);
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    backButton.center = CGPointMake(30.0f, 40.0f);
    backButton.alpha = 0;
    self.backButton = backButton;
    [self.view addSubview:self.backButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.backButton.alpha = 1;
    [self prepareAndExecuteBackButtonAnimation];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self checkForFirstLaunch];

}

-(void)prepareAndExecuteBackButtonAnimation
{
    self.backButton.center = CGPointMake(self.backButton.center.x - 70.0f, self.backButton.center.y);
    [UIView animateWithDuration:0.45f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backButton.center = CGPointMake(self.backButton.center.x + 70.0f, self.backButton.center.y);
    }completion:nil];
}

-(void)checkForFirstLaunch
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"hasDoneTrainingMode"]) {
        [self alertForTraining];
    }
}

-(void)alertForTraining
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"First Time?" message:@"If this is your first time describing images, its recommended you try training mode first to get familiar with your tools. You can access training mode from the main menu." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

-(void)backButtonPressed:(id)sender
{
    [UIView animateWithDuration:0.45f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backButton.center = CGPointMake(self.backButton.center.x - 70.0f, self.backButton.center.y);
    }completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
