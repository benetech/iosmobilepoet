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
/* used for the tap gesture to make the fetched image bigger */
@property (nonatomic, strong) UIImageView *currentImage;
/* currently fetched image */
@property(nonatomic, strong)NSMutableArray *submissionViewSubviews;
/* All subviews of the translation submission view */
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
    backButton.tintColor = [UIColor colorWithRed:29/255.0f green:42/255.0f blue:99/255.0f alpha:1.0f];
    backButton.alpha = 0;
    self.backButton = backButton;
    [self.view addSubview:self.backButton];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitButton sizeToFit];
    [submitButton addTarget:self action:@selector(submitPressed:) forControlEvents:UIControlEventTouchUpInside];
    submitButton.center = CGPointMake(self.view.frame.size.width-35.0f, 40.0f);
    submitButton.tintColor = [UIColor colorWithRed:29/255.0f green:42/255.0f blue:99/255.0f alpha:1.0f];
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
    
    self.submissionViewSubviews = [NSMutableArray new];
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
    self.textInputView.editable = NO;
    self.backButton.enabled = NO;
    self.submitButton.enabled = NO;
    
    [self constructAndShowSubmissionView];
    
}

-(void)decisionButtonPressed:(UITapGestureRecognizer *)gesture
{
    UILabel *button = (UILabel *)gesture.view;
    if ([button.text isEqualToString:@"Yes"]) {
        /* submit */;
    }else{
        [self removeSubmissionView];
    }
}

-(void)backButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
    /* current 'task' session shouldn't be released */
}

#pragma mark Submission View

-(void)constructAndShowSubmissionView
{
    /* Constructs, and animates, the submission view when the 'submit' buttun is pressed. The user is promted to decide if their translation is ready for submission */
    
    /* Setup views. View center postions are set to their beginning position in the animation where they will be animated in */
    //Labels
    UILabel *confirmInstructionTextView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100.0f)];
    confirmInstructionTextView.center = CGPointMake(self.view.frame.size.width/2.0f, -(confirmInstructionTextView.frame.size.height/2.0f) + 20.0f);
    confirmInstructionTextView.numberOfLines = 0;
    confirmInstructionTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    confirmInstructionTextView.textAlignment = NSTextAlignmentCenter;
    confirmInstructionTextView.text = @"Is your translation identical to the image?";
    [self.submissionViewSubviews removeAllObjects];
    [self.submissionViewSubviews addObject:confirmInstructionTextView];
    [self.view addSubview:confirmInstructionTextView];
    
    UILabel *imageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20.0f)];
    imageLabel.backgroundColor = [UIColor blueColor];
    
    //Buttons (as UILabels)
    const CGFloat decisionButtonHeight = 45.0f;
    const CGFloat yesButtonYCenterPosition = self.view.frame.size.height - decisionButtonHeight;
    const CGFloat noButtonYCenterPosition = self.view.frame.size.height - (decisionButtonHeight *  2.5f);
    
    UILabel *yesButton = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, decisionButtonHeight)];
    yesButton.center = CGPointMake(self.view.frame.size.width/2.0f, noButtonYCenterPosition + 150.0f);
    yesButton.backgroundColor = [UIColor colorWithRed:222/255.0f green:236/255.0f blue:222/255.0f alpha:1.0f];
    yesButton.textAlignment = NSTextAlignmentCenter;
    yesButton.textColor = [UIColor greenColor];
    yesButton.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    yesButton.text = @"Yes";
    [yesButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(decisionButtonPressed:)]];
    yesButton.userInteractionEnabled = YES;
    [self.submissionViewSubviews addObject:yesButton];
    
    UILabel *noButton = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, decisionButtonHeight)];
    noButton.center = CGPointMake(self.view.frame.size.width/2.0f, yesButtonYCenterPosition + 150.0f);
    noButton.backgroundColor = [UIColor colorWithRed:245/255.0f green:222/255.0f blue:222/255.0f alpha:1.0f];
    noButton.textAlignment = NSTextAlignmentCenter;
    noButton.textColor = [UIColor redColor];
    noButton.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    noButton.text = @"No";
    [noButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(decisionButtonPressed:)]];
    noButton.userInteractionEnabled = YES;
    [self.submissionViewSubviews addObject:noButton];
    
    [self.view addSubview:yesButton];
    [self.view addSubview:noButton];
    
    /* Animate in submission view */
    [UIView animateWithDuration:0.6f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        /* animate existing task subviews */
        self.currentImage.transform = CGAffineTransformScale(self.currentImage.transform, (self.view.frame.size.width- 50.0f)/self.currentImage.frame.size.width, (self.view.frame.size.width- 50.0f)/self.currentImage.frame.size.width);
        self.currentImage.center = CGPointMake(self.currentImage.center.x, self.currentImage.center.y + 100.0f);
        self.previewView.center = CGPointMake(self.previewView.center.x, self.previewView.center.y + 150.0f);
        self.textInputView.center = CGPointMake(self.textInputView.center.x, self.textInputView.center.y + 300.0f);
        self.textInputView.alpha = 0;
        
        /* animate in new submission subviews */
        confirmInstructionTextView.center = CGPointMake(confirmInstructionTextView.center.x, confirmInstructionTextView.center.y + confirmInstructionTextView.frame.size.height);
        yesButton.center = CGPointMake(yesButton.center.x, yesButtonYCenterPosition);
        noButton.center = CGPointMake(noButton.center.x, noButtonYCenterPosition);
        
        self.submitButton.alpha = 0;
        self.backButton.alpha = 0;
    }completion:^(BOOL finished){}];
}

-(void)removeSubmissionView
{
    /* Remove the submission/decision subview and go back to the taskViewController view */
    /* Calculate proper image scaling so the image fits properly in the UI */
    CGAffineTransform imageTransform;
    if (self.currentImage.frame.size.height > 100.0f){
        imageTransform = CGAffineTransformScale(self.currentImage.transform, 100.0f/self.currentImage.frame.size.height, 100.0f/self.currentImage.frame.size.height);
    }else{
        imageTransform = CGAffineTransformScale(self.currentImage.transform, (self.view.frame.size.width- 50.0f)/self.currentImage.frame.size.width, (self.view.frame.size.width- 50.0f)/self.currentImage.frame.size.width);
    }
    
    /* Get references to all 'submission view' subviews */
    UILabel *submissionTextView;
    UILabel *yesButton;
    UILabel *noButton;
    for (UILabel *subview in self.submissionViewSubviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            if ([subview.text isEqualToString: @"Yes"]) {
                yesButton = subview;
            }else if ([subview.text isEqualToString:@"No"]){
                noButton = subview;
            }else
                submissionTextView = subview;
        }
    }
    
    self.textInputView.editable = YES;
    [self.textInputView becomeFirstResponder];
    /* Enable task buttons */
    self.backButton.enabled = YES;
    self.submitButton.enabled = YES;
    
    [UIView animateWithDuration:0.6f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        /* Animate out submission view subviews and animate task view subviews back into place */
        self.previewView.center = CGPointMake(self.previewView.center.x, kPreviewCenterYPostion);
        self.currentImage.transform = imageTransform;
        self.currentImage.center = CGPointMake(self.currentImage.center.x, kImageCenterYPostion);
        self.textInputView.center = CGPointMake(self.textInputView.center.x, self.textInputView.center.y - 300.0f);
        self.textInputView.alpha = 1.0f;
        self.backButton.alpha = 1.0f;
        self.submitButton.alpha = 1.0f;
        
        submissionTextView.center = CGPointMake(submissionTextView.center.x, submissionTextView.center.y - 120.0f);
        yesButton.center = CGPointMake(yesButton.center.x, yesButton.center.y + 150.0f);
        noButton.center = CGPointMake(noButton.center.x, noButton.center.y + 150.0f);
        
    }completion:^(BOOL finished){
        if (finished) {
            [submissionTextView removeFromSuperview];
            [yesButton removeFromSuperview];
            [noButton removeFromSuperview];
            [self.submissionViewSubviews removeAllObjects];
            /* set 'imageIsEnlarged' to 'NO' since the image has shrunk to its scaled size, regardless if the image was enlarged in the 'submission view' */
            self.imageIsEnlarged = NO;
        }
    }];
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
        
    }completion:^(BOOL finished){}];
    
}

-(void)dragImage:(UIPanGestureRecognizer *)gesture
{
    static int originalImageCenterY;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        originalImageCenterY = gesture.view.center.y;
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        gesture.view.center = CGPointMake(gesture.view.center.x, gesture.view.center.y + [gesture translationInView:self.view].y);
        [gesture setTranslation:CGPointZero inView:self.view];
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled){
        [UIView animateWithDuration:0.7f delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            gesture.view.center = CGPointMake(gesture.view.center.x, originalImageCenterY);
        }completion:^(BOOL finished){}];
    }
}

#pragma mark System

-(void)fetchPic:(id)sender
{
    /* This will evetually handle fetching pictures from the mathml cloud servers. For now this will simulate that using local pics */
    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"testimg3.jpg"]];
    self.currentImage = image;
    
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
