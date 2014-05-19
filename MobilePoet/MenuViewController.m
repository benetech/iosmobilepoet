//
//  ViewController.m
//  MobilePoet
//
//  Created by Joseph Maag on 5/19/14.
//
//

#import "MenuViewController.h"

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
	
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 60)];
    self.titleLabel.center = CGPointMake(self.view.center.x, 80);
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:34.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"Poet Mobile";
    [self.view addSubview:self.titleLabel];
    
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
