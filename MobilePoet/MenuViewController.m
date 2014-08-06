//
//  ViewController.m
//  MobilePoet
//
//  Created by Joseph Maag on 5/19/14.
//
//

#import "MenuViewController.h"
#import "TaskViewController.h"

@interface MenuViewController ()
@property(nonatomic, strong) UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *beginButton;
@property (weak, nonatomic) IBOutlet UIButton *trainingModeButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (strong, nonatomic) UIView *titleBackground;
@property (nonatomic) BOOL alreadyBeenOnScreen;
@end

@implementation MenuViewController

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    /* UI elements */
    UIView *titleBackground = [[UIView alloc]initWithFrame:CGRectMake(0, -20.0f, self.view.frame.size.width, 150.0f)];
    titleBackground.backgroundColor = [UIColor colorWithRed:0 green:28/255.0f blue:125/255.0f alpha:1.0f];
    self.titleBackground = titleBackground;
    [self.view addSubview:self.titleBackground];
    //move buttons up 10 points if the titleBackground is not used
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300.0f, 60.0f)];
    self.titleLabel.center = CGPointMake(self.view.center.x, 80.0f);
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:34.0f];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"Poet Mobile";
    [self.view addSubview:self.titleLabel];
    
    /* All other views are defined in the storyboard */
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!self.alreadyBeenOnScreen) {
        //Setup for intro animation
        self.beginButton.center = CGPointMake(self.beginButton.center.x, self.beginButton.center.y + 300.0f);
        self.trainingModeButton.center = CGPointMake(self.trainingModeButton.center.x, self.trainingModeButton.center.y + 300.0f);
        self.helpButton.center = CGPointMake(self.helpButton.center.x, self.helpButton.center.y + 300.0f);
        self.aboutButton.center = CGPointMake(self.aboutButton.center.x, self.aboutButton.center.y + 300.0f);
        
        self.titleBackground.center = CGPointMake(self.titleBackground.center.x, self.titleBackground.center.y - 130.0f);
        self.titleLabel.center = CGPointMake(self.titleLabel.center.x, self.titleLabel.center.y - 130.0f);
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.alreadyBeenOnScreen) {
        self.alreadyBeenOnScreen = YES;
        [UIView animateWithDuration:0.7f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.beginButton.center = CGPointMake(self.beginButton.center.x, self.beginButton.center.y - 300.0f);
            self.trainingModeButton.center = CGPointMake(self.trainingModeButton.center.x, self.trainingModeButton.center.y - 300.0f);
            self.helpButton.center = CGPointMake(self.helpButton.center.x, self.helpButton.center.y - 300.0f);
            self.aboutButton.center = CGPointMake(self.aboutButton.center.x, self.aboutButton.center.y - 300.0f);
            self.titleBackground.center = CGPointMake(self.titleBackground.center.x, self.titleBackground.center.y + 130.0f);
            self.titleLabel.center = CGPointMake(self.titleLabel.center.x, self.titleLabel.center.y + 130.0f);

        }completion:nil];
    }
}

#pragma mark - Button actions

- (IBAction)beginButtonPressed:(id)sender {
}

- (IBAction)trainingModeButtonPressed:(id)sender {
}

- (IBAction)helpButtonPressed:(id)sender {
}

- (IBAction)aboutButtonPressed:(id)sender {
}

- (IBAction)signInButtonPressed:(id)sender {
}

@end
