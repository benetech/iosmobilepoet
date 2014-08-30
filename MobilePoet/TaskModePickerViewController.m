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
@property (weak, nonatomic) IBOutlet UIButton *randomButton;
@property (weak, nonatomic) IBOutlet UIButton *galleryButton;
@property (weak, nonatomic) IBOutlet UIButton *sourceButton;
@property (weak, nonatomic) IBOutlet UIButton *reviewButton;
@property (weak, nonatomic) IBOutlet UILabel *randomLabel;
@property (weak, nonatomic) IBOutlet UILabel *galleryLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;

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

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    /* Adjust buttons for 3.5 inch screen manually because as far as I know, autolayout in interface
     * builder cannot space the buttons evenly vertically along the screen. 
    */
    if ([self deviceHasThreePointFiveInchScreen]) {
        self.randomButton.center = CGPointMake(self.randomButton.center.x, self.randomButton.center.y - 15.0f);
        self.randomLabel.center = CGPointMake(self.randomLabel.center.x, self.randomLabel.center.y - 15.0f);
        self.galleryButton.center = CGPointMake(self.galleryButton.center.x, self.galleryButton.center.y - 35.0f);
        self.galleryLabel.center = CGPointMake(self.galleryLabel.center.x, self.galleryLabel.center.y - 35.0f);
        self.sourceButton.center = CGPointMake(self.sourceButton.center.x, self.sourceButton.center.y - 55.0f);
        self.sourceLabel.center = CGPointMake(self.sourceLabel.center.x, self.sourceLabel.center.y - 55.0f);
        self.reviewButton.center = CGPointMake(self.reviewButton.center.x, self.reviewButton.center.y - 75.0f);
        self.reviewLabel.center = CGPointMake(self.reviewLabel.center.x, self.reviewLabel.center.y - 75.0f);
    }
    
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

-(BOOL)deviceHasThreePointFiveInchScreen
{
    return !([UIScreen mainScreen].bounds.size.height == 568.0);
}

@end
