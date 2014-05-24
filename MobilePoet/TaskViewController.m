//
//  TaskViewController.m
//  MobilePoet
//
//  Created by Joseph Maag on 5/21/14.
//
//

#import "TaskViewController.h"
#import "MathKeyboard.h"

@interface TaskViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UITextView *textInputView;
@property (nonatomic, strong) UIWebView *previewView;
@end

@implementation TaskViewController

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* top Buttons */
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    backButton.center = CGPointMake(30.0f, 40.0f);
    backButton.alpha = 0;
    self.backButton = backButton;
    [self.view addSubview:self.backButton];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitButton sizeToFit];
    [submitButton addTarget:self action:@selector(submitPressed:) forControlEvents:UIControlEventTouchUpInside];
    submitButton.center = CGPointMake(self.view.frame.size.width-35.0f, 40.0f);
    submitButton.alpha = 0;
    self.submitButton = submitButton;
    [self.view addSubview:self.submitButton];
    
    
    /* text view */
    self.textInputView = [[UITextView alloc]initWithFrame:(CGRect){CGPointZero, self.view.frame.size.width, 80.0f}];
    [MathKeyboard addMathKeyboardToTextView:self.textInputView];
    self.textInputView.font = [UIFont systemFontOfSize:15.0f];
    self.textInputView.center = CGPointMake(self.textInputView.center.x, self.view.frame.size.height - self.textInputView.inputView.frame.size.height - self.textInputView.frame.size.height/2);
    self.textInputView.alpha = 0;
    [self.view addSubview:self.textInputView];
    
    /* preview view */
    self.previewView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100.0f)];
    /* center is calculated after image is fetched */
    self.previewView.backgroundColor = [UIColor blackColor];
    self.previewView.hidden = YES;
    [self.view addSubview:self.previewView];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:self.activityIndicator];
    
    
    /* Fake delay to simulate server fetch of image */
    [self performSelector:@selector(fetchPic:) withObject:nil afterDelay:1.0f];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Button actions

-(void)submitPressed:(UIButton *)button
{
    
}

-(void)backButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
    /* current 'task' session shouldn't be released */
}

#pragma mark System

-(void)fetchPic:(id)obj
{
    /* This will evetually handle fetching pictures from the mathml cloud servers. For now this will simulate that using local pics */
    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"testimg1.jpg"]];
    
    /* prepare image for animation */
    image.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    image.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    image.alpha = 0;
    image.layer.shadowOpacity = 0.3f;
    image.layer.shadowOffset = CGSizeMake(0,0);
    [self.view addSubview:image];
    
    /* remove activity indicator */
    [UIView animateWithDuration:0.5f animations:^{
        self.activityIndicator.alpha = 0;
        self.activityIndicator.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    }completion:^(BOOL finished){
        if (finished) {
            [self.activityIndicator stopAnimating];
            [self.activityIndicator removeFromSuperview];
            self.activityIndicator.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            self.activityIndicator.alpha = 1.0f;
            
            /* animate in image */
            [UIView animateWithDuration:0.8f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                image.transform = CGAffineTransformScale(image.transform,(self.view.frame.size.width/image.frame.size.width) - 0.5f, (self.view.frame.size.width/image.frame.size.width) - 0.5f);
                image.alpha = 1.0f;
            }completion:^(BOOL finished){
                if (finished) {
                    
                    /* animate image to the top */
                    [UIView animateWithDuration:0.9f delay:0.2f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                        image.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                        image.center = CGPointMake(image.center.x, 100.f);
                        self.backButton.alpha = 1.0f;
                        self.textInputView.alpha = 1.0f;
                        self.submitButton.alpha = 1.0f;
                    }completion:^(BOOL finished){
                        if (finished) {
                            /* calculate position of the preview view */
                            self.previewView.center = CGPointMake(self.view.frame.size.width/2, (image.frame.origin.y + image.frame.size.height + self.previewView.frame.size.height/2 + 25.0f));
                            self.previewView.hidden = NO;
                            
                            [self.textInputView becomeFirstResponder];
                            [image addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enlargeImage:)]];
                            image.userInteractionEnabled = YES;
                        }
                    }];
                }
            }];
        }
    }];
    
    
}

-(void)enlargeImage:(UITapGestureRecognizer *)gesture
{
    UIView *image = gesture.view;
    [UIView animateWithDuration:0.3f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        /* Image is scaled so that it's width is the size of the width of the screen */
         image.transform = CGAffineTransformScale(image.transform,(self.view.frame.size.width/image.frame.size.width)-0.1f, (self.view.frame.size.width/image.frame.size.width)-0.1f);
        
    }completion:^(BOOL finished){
        if (finished) {
            ;
        }
    }];
    
}


@end
