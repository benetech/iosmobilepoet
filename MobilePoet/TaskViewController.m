//
//  TaskViewController.m
//  MobilePoet
//
//  Created by Joseph Maag on 5/21/14.
//
//

#import "TaskViewController.h"
#import "MathKeyboard.h"

NSString * const HTMLFileName = @"userhtml.html";
const CGFloat kImageCenterYPostion = 110.0f;
const CGFloat kPreviewCenterYPostion = 220.0f;

@interface TaskViewController () <UITextViewDelegate>
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UITextView *textInputView;
@property (nonatomic, strong) UIWebView *previewView;
@property (nonatomic) BOOL imageIsEnlarged;
//used for the tap gesture to make the fetched image bigger
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
    self.textInputView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textInputView.autocorrectionType = UITextAutocapitalizationTypeNone;
    self.textInputView.delegate = self;
    [self.view addSubview:self.textInputView];
    
    /* preview view */
    self.previewView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100.0f)];
    /* center is calculated after image is fetched */
    self.previewView.backgroundColor = [UIColor blackColor];
    self.previewView.hidden = YES;
    [self setupPreviewViewHtml];
    self.previewView.userInteractionEnabled = NO;
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

-(void)setupPreviewViewHtml
{
    /* Setups html */
    NSString *tempDir = NSTemporaryDirectory();
    NSString *path = [tempDir stringByAppendingPathComponent:HTMLFileName];
    NSString *htmlString = [self makeHtmlFromAsciimath:@""];
    [htmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    [self.previewView loadRequest:req];
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

#pragma mark Gestures

-(void)enlargeImage:(UITapGestureRecognizer *)gesture
{
    UIView *image = gesture.view;
    [UIView animateWithDuration:0.3f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (self.imageIsEnlarged) {
            /* Image has already been enlarged, so scale it back to its original size. This is the same way the image's original scaling is calulcuted when its first scaled to fit in the ui. */
            CGAffineTransform imageTransform;
            if (image.frame.size.height > 100.0f){
                // Image is too big
                imageTransform = CGAffineTransformScale(image.transform, 100.0f/image.frame.size.height, 100.0f/image.frame.size.height);
            }else{
                // Image is an ideal size, meaning it's below the max height
                imageTransform = CGAffineTransformScale(image.transform, (self.view.frame.size.width- 50.0f)/image.frame.size.width, (self.view.frame.size.width- 50.0f)/image.frame.size.width);
            }
            image.transform = imageTransform;
            self.imageIsEnlarged  =NO;
        }else{
            /* Image is scaled so that it's width is just slightly less than the width of the screen */
            image.transform = CGAffineTransformScale(image.transform,(self.view.frame.size.width/image.frame.size.width)-0.1f, (self.view.frame.size.width/image.frame.size.width)-0.1f);
            self.imageIsEnlarged = YES;
        }
        
    }completion:^(BOOL finished){
        if (finished) {
            ;
        }
    }];
    
}

-(void)dragImage:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged) {
        gesture.view.center = CGPointMake(gesture.view.center.x, gesture.view.center.y + [gesture translationInView:self.view].y);
        [gesture setTranslation:CGPointZero inView:self.view];
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled){
        [UIView animateWithDuration:0.7f delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            gesture.view.center = CGPointMake(gesture.view.center.x, kImageCenterYPostion);
        }completion:^(BOOL finished){
            
        }];
    }
}

#pragma mark System

-(void)fetchPic:(id)sender
{
    /* This will evetually handle fetching pictures from the mathml cloud servers. For now this will simulate that using local pics */
    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"testimg2.jpg"]];
    
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
                    
                    /* Calculate proper image scaling so the image fits properly in the UI. Assuming any image size is possible */
                    /* The max height of an image before it's too big for the ui is 100.0. If It's bigger than that, then it will be scaled smaller until it is at most 100 points in height. */
                    CGAffineTransform imageTransform;
                    if (image.frame.size.height > 100.0f){
                        // Image is too big
                        imageTransform = CGAffineTransformScale(image.transform, 100.0f/image.frame.size.height, 100.0f/image.frame.size.height);
                    }else{
                        // Image is an ideal size, meaning it's below the max height
                        imageTransform = CGAffineTransformScale(image.transform, (self.view.frame.size.width- 50.0f)/image.frame.size.width, (self.view.frame.size.width- 50.0f)/image.frame.size.width);
                    }
 
                    
                    /* animate image to the top */
                    [UIView animateWithDuration:0.9f delay:0.2f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                        image.transform = imageTransform;
                        image.center = CGPointMake(image.center.x, kImageCenterYPostion);
                        self.backButton.alpha = 1.0f;
                        self.textInputView.alpha = 1.0f;
                        self.submitButton.alpha = 1.0f;
                    }completion:^(BOOL finished){
                        if (finished) {
                            
                            /* calculate position of the preview view. It's y position in the ui is predefined and constant. */
                            //self.previewView.center = CGPointMake(self.view.frame.size.width/2, (image.frame.origin.y + image.frame.size.height + self.previewView.frame.size.height/2 + 50.0f));
                            self.previewView.center = CGPointMake(self.view.frame.size.width/2, kPreviewCenterYPostion);
                            self.previewView.hidden = NO;
                            
                            [self.textInputView becomeFirstResponder];
                            [image addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enlargeImage:)]];
                            [image addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragImage:)]];
                            image.userInteractionEnabled = YES;
                        }
                    }];
                }
            }];
        }
    }];
    
    
}

#pragma mark TextView and Preview View

-(void)textViewDidChange:(UITextView *)textView
{
    /* Refresh the MathML preview everytime a new charcter is typed */
    [self updatePreviewViewWithText:textView.text];
}

-(void)updatePreviewViewWithText:(NSString *)text
{
    /* Updates the preview view with whatever ASCIIMath is in the textview */
    NSString *userText = [NSString stringWithFormat:@"<p>`%@`<p>", text];
    NSString *tempDir = NSTemporaryDirectory();
    NSString *path = [tempDir stringByAppendingPathComponent:HTMLFileName];
    NSString *htmlString = [self makeHtmlFromAsciimath:userText];
    [htmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self.previewView reload];
}

-(NSString *)makeHtmlFromAsciimath:(NSString *)asciimath
{
    NSString *html1 = @"<html><head><script type='text/x-mathjax-config'>MathJax.Hub.Config({messageStyle: 'none'});</script><script type='text/javascript' src = 'http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=AM_HTMLorMML-full'></script></head><body><div style='font-size: 130%; text-align: center;'>";
    
    //<style>body{background-color:black;}</style>
    
    /*The following string is the same HTML as above except it sets the 'scale' in a mathjax configuration.*/
    /* It works, but the scaling takes about a second to take effect. If I use a div CSS (as done in the above string) then it takes effect immediately.
    
     NSString *foo = @"<html><head><script type='text/x-mathjax-config'>MathJax.Hub.Config({ 'HTML-CSS':{scale: 300}});</script><script type='text/javascript' src = 'http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=AM_HTMLorMML-full'></script></head><body>";
     */
    
    NSString *html2 = [html1 stringByAppendingString:asciimath];
    NSString *fullHtmlString = [html2 stringByAppendingString:@"</div></body></html>"];
    return fullHtmlString;

}





@end