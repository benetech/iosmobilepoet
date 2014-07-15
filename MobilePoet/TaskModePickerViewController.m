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
    /*
     NSMutableAttributedString *backString = [[NSMutableAttributedString alloc]initWithString:@"< Back"];
     [backString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f] range:NSMakeRange(0, 1)];
     */
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    backButton.center = CGPointMake(25.0f, 40.0f);
    backButton.tintColor = [UIColor colorWithRed:0 green:28/255.0f blue:155/255.0f alpha:1.0f];
    backButton.alpha = 0;
    self.backButton = backButton;
    [self.view addSubview:self.backButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.backButton.alpha = 0;
}

-(void)viewDidAppear:(BOOL)animated
{
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.backButton.alpha = 1.0f;
    }completion:nil];
}

-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
