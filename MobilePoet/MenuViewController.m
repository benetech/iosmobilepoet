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
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@end

@implementation MenuViewController

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    /* UI elements */
    UIView *titleBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 130.0f)];
    titleBackground.backgroundColor = [UIColor colorWithRed:0 green:28/255.0f blue:125/255.0f alpha:1.0f];
    [self.view addSubview:titleBackground];
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
    
    //Setup for intro animation
    
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
