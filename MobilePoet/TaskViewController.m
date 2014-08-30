//
//  TaskViewController.m
//  MobilePoet
//
//  Created by Joseph Maag on 5/21/14.
//
//

#import "TaskViewController.h"
#import "MathKeyboard.h"
#import "HelpViewController.h"
#import "GalleryViewController.h"

typedef NS_ENUM(NSInteger, ImageSelectionMode){
    ImageSelectionModeRandom,
    /* Random endless images */
    ImageSelectionModeSpecificImage
    /* For a specific image chosen by the user earlier on */
};

NSString * const HTMLFileName = @"asciimathhtml.html";
const CGFloat kImageCenterYPostion = 110.0f;
const CGFloat kPreviewCenterYPostion = 220.0f;
/* Adjusted constants for iPhone 4 and 4s 3.5 inch screens */
const CGFloat kImageCenterYPostionForThreePointFiveInchScreen = 90.0f;
const CGFloat kPreviewCenterYPostionForThreePointFiveInchScreen = 168.0f;

@interface TaskViewController () <UITextViewDelegate, UIAlertViewDelegate>
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
@property (nonatomic) ImageSelectionMode mode;
/* Either shows continous random images or a specific image. Default mode is Random*/
@property (nonatomic) BOOL guidanceModeEnabled;
/* Guidance mode is handled by the keyboard, but the textView's (self.textInputView) delegate is handled by TaskViewController */
/* To restrict the textview's user interaction during guidance mode, the bool is required to know if its enabled */
@property (nonatomic) MathKeyboard *mathKeyboard;
@property (strong, nonatomic) UILabel *previewViewLabel;
/* This label identifies the preview view as a preview view before the user begins typing */
@property (strong, nonatomic) NSMutableArray *randomImages;
@property (nonatomic) BOOL presentedHelpViewController;
/* Keeps track on if the HelpViewController was just presented/dismissed. */
@end

@implementation TaskViewController

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* top buttons */
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    backButton.center = CGPointMake(30.0f, 40.0f);
    backButton.tintColor = [UIColor colorWithRed:0 green:30/255.0f blue:168/255.0f alpha:1.0f];
    backButton.alpha = 0;
    backButton.showsTouchWhenHighlighted = YES;
    self.backButton = backButton;
    [self.view addSubview:self.backButton];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitButton sizeToFit];
    [submitButton addTarget:self action:@selector(submitPressed:) forControlEvents:UIControlEventTouchUpInside];
    submitButton.center = CGPointMake(self.view.frame.size.width-35.0f, 40.0f);
    submitButton.tintColor = [UIColor colorWithRed:0 green:30/255.0f blue:168/255.0f alpha:1.0f];
    submitButton.alpha = 0;
    submitButton.showsTouchWhenHighlighted = YES;
    self.submitButton = submitButton;
    [self.view addSubview:self.submitButton];
    
    
    /* text view */
    self.textInputView = [[UITextView alloc]initWithFrame:(CGRect){CGPointZero, self.view.frame.size.width, [self deviceHasThreePointFiveInchScreen] ? 65.0f : 80.0f }];
    [MathKeyboard addMathKeyboardToTextView:self.textInputView];
    self.textInputView.font = [UIFont systemFontOfSize:15.0f];
    self.textInputView.center = CGPointMake(self.textInputView.center.x, self.view.frame.size.height - self.textInputView.inputView.frame.size.height - self.textInputView.frame.size.height/2);
    self.textInputView.alpha = 0;
    self.textInputView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textInputView.autocorrectionType = UITextAutocapitalizationTypeNone;
    self.textInputView.textAlignment = NSTextAlignmentCenter;
    self.textInputView.userInteractionEnabled = NO;
    self.textInputView.delegate = self;
    [self.view addSubview:self.textInputView];
    
    /* preview view */
    self.previewView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, ([self deviceHasThreePointFiveInchScreen] ? 58.0f : 65.0f))];
    self.previewView.center = CGPointMake(self.view.frame.size.width/2.0f, ([self deviceHasThreePointFiveInchScreen] ? kPreviewCenterYPostionForThreePointFiveInchScreen : kPreviewCenterYPostion));
    self.previewView.backgroundColor = [UIColor blackColor];
    self.previewView.layer.shadowOpacity = 0;
    self.previewView.layer.shadowOffset = CGSizeMake(0,0);
    self.previewView.hidden = YES;
    [self setupPreviewViewHtml];
    self.previewView.userInteractionEnabled = NO;
    [self.view addSubview:self.previewView];
    
    [self.view addSubview:self.activityIndicator];
    
    self.mode = ImageSelectionModeRandom;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.presentedHelpViewController) {
        self.presentedHelpViewController = NO;
        [self.textInputView becomeFirstResponder];
        return;
    }
    if (self.mode == ImageSelectionModeRandom) {
        [self.activityIndicator startAnimating];
        /* Fake delay to simulate server fetch of image */
        [self performSelector:@selector(fetchPic:) withObject:nil afterDelay:1.0f];
    }else{
        [self animateInWithExistingTaskImageAlreadySet];
    }
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

-(void)setTask:(UIImageView *)image
{
    self.currentImage = image;
    [self.view addSubview:image];
    self.mode = ImageSelectionModeSpecificImage;
}

-(void)reloadRandomImages
{
    for (int i = 1; i < 14; i++) {
        [self.randomImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"randomImage%d.jpg", i]]];
    }
}

-(MathKeyboard *)mathKeyboard
{
    if (!_mathKeyboard) {
        _mathKeyboard = (MathKeyboard *)self.textInputView.inputView;
    }
    return _mathKeyboard;
}

-(UILabel *)previewViewLabel
{
    if (!_previewViewLabel) {
        _previewViewLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100.0f, 20.0f)];
        _previewViewLabel.backgroundColor = [UIColor clearColor];
        _previewViewLabel.center = CGPointMake(_previewView.frame.size.width/2, _previewView.frame.size.height/2);
        _previewViewLabel.alpha = 0;
        _previewViewLabel.textColor = [UIColor lightGrayColor];
        _previewViewLabel.textAlignment = NSTextAlignmentCenter;
        _previewViewLabel.text = @"Preview";
        [_previewView addSubview:_previewViewLabel];
    }
    return _previewViewLabel;
}

-(UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    }
    return _activityIndicator;
}

-(NSMutableArray *)randomImages
{
    if (!_randomImages) {
        _randomImages = [NSMutableArray new];
        for (int i = 1; i < 14; i++) {
            [_randomImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"randomImage%d.jpg", i]]];
        }
    }
    return _randomImages;
}

#pragma mark Button actions

-(void)submitPressed:(UIButton *)button
{
    if (![self.textInputView.text isEqualToString:@""]) {
        self.textInputView.editable = NO;
        self.backButton.enabled = NO;
        self.submitButton.enabled = NO;
        [self constructAndShowSubmissionView];
    }else{
        /* no text entered */
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Empty Translation" message:@"You need to translate the image before you can submit it!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)decisionButtonPressed:(UITapGestureRecognizer *)gesture
{
    UILabel *button = (UILabel *)gesture.view;
    if ([button.text isEqualToString:@"Yes"]) {
        /* Submit */;
        [self animateAwaySubmissionViewAndSubmitDescription];
    }else{
        /* Go back to the task view */
        [self removeSubmissionViewAndGoBackToTaskView];
    }
}

-(void)backButtonPressed:(UIButton *)button
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Leave Image" message:@"Are you sure you want to abandon this image?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.delegate = self;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        MathKeyboard *keyboard = (MathKeyboard *)self.textInputView.inputView;
        [keyboard disableCursorKeyHorizontalAnimationForNextKeyboardDismissal];
        if (self.mode == ImageSelectionModeSpecificImage) {
            [self.textInputView resignFirstResponder];
            [UIView animateWithDuration:0.3f delay:0 options:0 animations:^{
                self.textInputView.alpha = 0;
                self.previewView.alpha = 0;
                self.backButton.alpha = 0;
                self.submitButton.alpha = 0;
                self.currentImage.alpha = 0;
            }completion:^(BOOL finished){
                if (finished) {
                    [self.navigationController popViewControllerAnimated:NO];
                }
            }];
        }else
            [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Submission View

-(void)constructAndShowSubmissionView
{
    /* Constructs, and animates, the 'submission view' when the 'submit' button is pressed. The user is promted to decide if their translation is ready for submission */
    
    /* Setup views. View center postions are set to their beginning position in the animation where they will be animated in */
    //Labels
    
    if (!self.submissionViewSubviews) {
        self.submissionViewSubviews = [NSMutableArray new];
    }
    UILabel *confirmInstructionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100.0f)];
    confirmInstructionLabel.center = CGPointMake(self.view.frame.size.width/2.0f, -(confirmInstructionLabel.frame.size.height/2.0f) + 20.0f);
    confirmInstructionLabel.numberOfLines = 0;
    confirmInstructionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    //confirmInstructionTextView.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f];
    confirmInstructionLabel.textAlignment = NSTextAlignmentCenter;
    confirmInstructionLabel.text = @"Is your translation identical to the image?";
    [self.submissionViewSubviews removeAllObjects];
    [self.submissionViewSubviews addObject:confirmInstructionLabel];
    [self.view addSubview:confirmInstructionLabel];
    
    UILabel *imageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20.0f)];
    imageLabel.backgroundColor = [UIColor blueColor];
    
    //Buttons (as UILabels)
    const CGFloat decisionButtonHeight = 45.0f;
    const CGFloat noButtonYCenterPosition = self.view.frame.size.height - decisionButtonHeight;
    const CGFloat yesButtonYCenterPosition = self.view.frame.size.height - (decisionButtonHeight *  2.5f);
    
    UILabel *yesButton = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, decisionButtonHeight)];
    yesButton.center = CGPointMake(self.view.frame.size.width/2.0f, noButtonYCenterPosition + 150.0f);
    yesButton.backgroundColor = [UIColor colorWithRed:10/255.0f green:191/255.0f blue:0/255.0f alpha:1.0f];
    yesButton.textAlignment = NSTextAlignmentCenter;
    yesButton.textColor = [UIColor whiteColor];
    yesButton.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    yesButton.text = @"Yes";
    [yesButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(decisionButtonPressed:)]];
    yesButton.userInteractionEnabled = YES;
    [self.submissionViewSubviews addObject:yesButton];
    
    UILabel *noButton = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, decisionButtonHeight)];
    noButton.center = CGPointMake(self.view.frame.size.width/2.0f, yesButtonYCenterPosition + 150.0f);
    noButton.backgroundColor = [UIColor colorWithRed:194/255.0f green:4/255.0f blue:0/255.0f alpha:1.0f];;
    noButton.textAlignment = NSTextAlignmentCenter;
    noButton.textColor = [UIColor whiteColor];
    noButton.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    noButton.text = @"No";
    [noButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(decisionButtonPressed:)]];
    noButton.userInteractionEnabled = YES;
    [self.submissionViewSubviews addObject:noButton];
    
    [self.view addSubview:yesButton];
    [self.view addSubview:noButton];
    
    /* Make scale for images */
    CGAffineTransform scale = CGAffineTransformScale(self.currentImage.transform, (self.view.frame.size.width- 50.0f)/self.currentImage.frame.size.width, (self.view.frame.size.width- 50.0f)/self.currentImage.frame.size.width);
    if ((self.currentImage.frame.size.height/self.currentImage.transform.a) * scale.a > 200.0f) {
        /* If the height of the image is still too big, make the height 200 points, which is the maximum height limit for the image in a submission view */
        scale = CGAffineTransformScale(self.currentImage.transform, 200.0f/self.currentImage.frame.size.height, 200.0f/self.currentImage.frame.size.height);
    }
    
    /* Animate in submission view */
    [UIView animateWithDuration:0.6f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        /* animate existing task subviews */
        self.currentImage.transform = scale;
        self.currentImage.center = CGPointMake(self.currentImage.center.x, self.currentImage.center.y + 100.0f);
        self.previewView.center = CGPointMake(self.previewView.center.x, self.previewView.center.y + 130.0f);
        self.textInputView.center = CGPointMake(self.textInputView.center.x, self.textInputView.center.y + 300.0f);
        self.textInputView.alpha = 0;
        self.previewView.layer.shadowOpacity = 0;
        self.submitButton.alpha = 0;
        self.backButton.alpha = 0;
        
        /* animate in new submission subviews */
        confirmInstructionLabel.center = CGPointMake(confirmInstructionLabel.center.x, confirmInstructionLabel.center.y + confirmInstructionLabel.frame.size.height);
        yesButton.center = CGPointMake(yesButton.center.x, yesButtonYCenterPosition);
        noButton.center = CGPointMake(noButton.center.x, noButtonYCenterPosition);

    }completion:nil];
}

-(void)removeSubmissionViewAndGoBackToTaskView
{
    /* Remove the submission/decision subview and go back to the taskViewController view */
    
    /* Calculate proper image scaling so the image fits properly in the UI */
    CGAffineTransform imageTransform = [self scaleTransformForTaskImage:self.currentImage];
    
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
    
    /* Animate out submission view subviews and animate task view subviews back into place */
    [UIView animateWithDuration:([self deviceHasThreePointFiveInchScreen] ? 0.7f : 0.6f) delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.previewView.center = CGPointMake(self.previewView.center.x, ([self deviceHasThreePointFiveInchScreen] ? kPreviewCenterYPostionForThreePointFiveInchScreen : kPreviewCenterYPostion));
        self.currentImage.transform = imageTransform;
        self.currentImage.center = CGPointMake(self.currentImage.center.x, ([self deviceHasThreePointFiveInchScreen] ? kImageCenterYPostionForThreePointFiveInchScreen : kImageCenterYPostion));
        self.textInputView.center = CGPointMake(self.textInputView.center.x, self.textInputView.center.y - 300.0f);
        self.textInputView.alpha = 1.0f;
        self.backButton.alpha = 1.0f;
        self.submitButton.alpha = 1.0f;
        self.previewView.layer.shadowOpacity = 0.2f;
        
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

-(void)animateAwaySubmissionViewAndSubmitDescription
{
    /* Animate away 'submission' subviews, and task image and mathml preview */
    
    /* Get references to all 'submission view' subviews */
    UILabel *submissionTextView;
    UILabel *yesButton;
    UILabel *noButton;
    for (UILabel *subview in self.submissionViewSubviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            if ([subview.text isEqualToString: @"Yes"]) {
                yesButton = subview;
            }else if ([subview.text isEqualToString: @"No"]){
                noButton = subview;
            }else
                submissionTextView = subview;
        }
    }
    
    /* Animate away submission subviews */
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
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
    
    /* Animate away task views */
    [UIView animateWithDuration:0.8f delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.previewView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.currentImage.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.previewView.center = CGPointMake(self.view.frame.size.width/2.0f, self.view.frame.size.height/2.0f);
        self.currentImage.center = CGPointMake(self.view.frame.size.width/2.0f, self.view.frame.size.height/2.0f);
        self.previewView.alpha = 0;
        self.currentImage.alpha = 0;
        
    }completion:^(BOOL finished){
        if (finished) {
            [self submitImageAndMathmlToCloud];
        }
    }];
    
}

#pragma mark Image Gestures

-(void)enlargeImage:(UITapGestureRecognizer *)gesture
{
    UIView *image = gesture.view;
    [UIView animateWithDuration:0.3f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (self.imageIsEnlarged) {
            image.transform = [self scaleTransformForTaskImage:image];
            self.imageIsEnlarged = NO;
        }else{
            /* Image is scaled so that it's width is just slightly less than the width of the screen */
            image.transform = CGAffineTransformScale(image.transform,(self.view.frame.size.width/image.frame.size.width)-0.1f, (self.view.frame.size.width/image.frame.size.width)-0.1f);
            self.imageIsEnlarged = YES;
        }
        
    }completion:nil];
    
}

-(void)pinchImage:(UIPinchGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged) {
        gesture.view.transform = CGAffineTransformScale(gesture.view.transform, gesture.scale, gesture.scale);
        gesture.scale = 1.0f;
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled){

            /* Image is not enlarged (aka tapped), so scale the image to its original size if its current
             size is less than its original */
        CGAffineTransform originalScale = [self scaleTransformForTaskImageThatTheUserScaledViaThePinchGesture:gesture.view];
        if (gesture.view.frame.size.width < (gesture.view.frame.size.width * originalScale.a)) {
            /* If image width is less than its ideal width, scale it up */
            originalScale = [self scaleTransformForTaskImage:gesture.view];
            [UIView animateWithDuration:0.3f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                gesture.view.transform = originalScale;
            }completion:^(BOOL finished){
                if (finished) {
                    if (self.imageIsEnlarged) {
                        self.imageIsEnlarged = NO;
                    }
                }
            }];
        }
    }
    
}

-(void)dragImage:(UIPanGestureRecognizer *)gesture
{
    /* Drags along the Y axis always animate back to the original Y center when the gesture ends */
    static int originalImageCenterY;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        originalImageCenterY = gesture.view.center.y;
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        gesture.view.center = CGPointMake(gesture.view.center.x + [gesture translationInView:self.view].x, gesture.view.center.y + [gesture translationInView:self.view].y);
        [gesture setTranslation:CGPointZero inView:self.view];
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled){
        /* Drags along the X axis won't animate back to the screens center when the gesture ends, except when less than 50 points of the image are on screen */
        if ((gesture.view.frame.origin.x >= (self.view.frame.size.width - 50.0f)) || ((gesture.view.frame.origin.x + gesture.view.frame.size.width) <= 50.0f)) {
            [UIView animateWithDuration:0.7f delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                gesture.view.center = CGPointMake(self.view.center.x, originalImageCenterY);
            }completion:nil];
        }else{
            [UIView animateWithDuration:0.7f delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            gesture.view.center = CGPointMake(gesture.view.center.x, originalImageCenterY);
            }completion:nil];
        }
    }
}

#pragma mark Image/Task Loading and Fetching

-(void)fetchPic:(id)sender
{
    /* For ImageSelectionModeRandom type only */
    [self resetSubviewsForNewImageFetch];
    /* This will evetually handle fetching pictures from the mathml cloud servers. For now this will simulate that using local pics */
    if ([self.randomImages count] == 0) {
        /* If all the random images have been described, reload them all again */
        [self reloadRandomImages];
    }
    /* choose random image */
    NSInteger randomIndex = arc4random_uniform([self.randomImages count]);
    UIImageView *image = [[UIImageView alloc]initWithImage:[self.randomImages objectAtIndex:randomIndex]];
    [self.randomImages removeObjectAtIndex:randomIndex];
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
            [self resetActivityIndicatorScale];
            
            /* animate in image */
            [UIView animateWithDuration:0.8f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                image.transform = CGAffineTransformScale(image.transform,(self.view.frame.size.width/image.frame.size.width) - 0.5f, (self.view.frame.size.width/image.frame.size.width) - 0.5f);
                image.alpha = 1.0f;
            }completion:^(BOOL finished){
                if (finished) {
                    
                    /* Calculate proper image scaling so the image fits properly in the UI. Assuming any image size is possible */
                    CGAffineTransform imageTransform = [self scaleTransformForTaskImage:image];
                    /* If the image is scaled up a lot, reduce shadow size becuase its also scaled up */
                    if (imageTransform.a > 2.0f) {
                        image.layer.shadowOpacity = 0.25f;
                        image.layer.shadowRadius = 2.5f;
                    }
                    
                    /* animate image to the top */
                    [UIView animateWithDuration:0.9f delay:0.2f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                        image.transform = imageTransform;
                        image.center = CGPointMake(image.center.x,([self deviceHasThreePointFiveInchScreen] ? kImageCenterYPostionForThreePointFiveInchScreen : kImageCenterYPostion));
                        self.backButton.alpha = 1.0f;
                        self.textInputView.alpha = 1.0f;
                        self.submitButton.alpha = 1.0f;
                        self.previewView.alpha = 1.0f;
                    }completion:^(BOOL finished){
                        if (finished) {
                            /* calculate position of the preview view. It's y position in the ui is predefined and constant. */
                            //self.previewView.center = CGPointMake(self.view.frame.size.width/2, (image.frame.origin.y + image.frame.size.height + self.previewView.frame.size.height/2 + 50.0f));
                            self.previewView.center = CGPointMake(self.view.frame.size.width/2, ([self deviceHasThreePointFiveInchScreen] ? kPreviewCenterYPostionForThreePointFiveInchScreen : kPreviewCenterYPostion));
                            self.previewView.hidden = NO;
                            
                            [self.textInputView becomeFirstResponder];
                            [image addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enlargeImage:)]];
                            [image addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragImage:)]];
                            [image addGestureRecognizer:[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchImage:)]];
                            image.userInteractionEnabled = YES;
                            
                            
                            
                            /* Animate in preview shadow */
                            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
                            anim.fromValue = [NSNumber numberWithFloat:0];
                            anim.toValue = [NSNumber numberWithFloat:0.2f];
                            anim.duration = 0.5f;
                            [self.previewView.layer addAnimation:anim forKey:@"shadowOpacity"];
                            self.previewView.layer.shadowOffset = CGSizeMake(0, 2.0f);
                            self.previewView.layer.shadowRadius = 5.0f;
                            self.previewView.layer.shadowOpacity = 0.2f;
                            
                            self.previewViewLabel.hidden = NO;
                            [UIView animateWithDuration:0.5f animations:^{
                                self.previewViewLabel.alpha = 1.0f;
                            }completion:nil];
                        }
                    }];
                }
            }];
        }
    }];
    
}

-(void)animateInWithExistingTaskImageAlreadySet
{
    /* This is called when a TaskViewController is pushed when an image is already chosen and is already on screen (AKA the mode is 'ImageSelectionModeSpecificImage' ) */
    UIImageView *image = self.currentImage;
    /* Calculate proper image scaling so the image fits properly in the UI. Assuming any image size is possible */
    CGAffineTransform imageTransform = [self scaleTransformForTaskImage:image];
    /* If the image is scaled up a lot, reduce shadow size becuase its also scaled up */
    if (imageTransform.a > 2.0f) {
        image.layer.shadowOpacity = 0.25f;
        image.layer.shadowRadius = 2.5f;
    }
    
    self.previewView.center = CGPointMake(self.view.frame.size.width/2, ([self deviceHasThreePointFiveInchScreen] ? kPreviewCenterYPostionForThreePointFiveInchScreen : kPreviewCenterYPostion));
    self.previewView.hidden = NO;
    self.previewView.alpha = 1.0f;
    [self.textInputView becomeFirstResponder];
    
    /* animate image to the top */
    [UIView animateWithDuration:0.7f delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        image.transform = imageTransform;
        image.center = CGPointMake(image.center.x,([self deviceHasThreePointFiveInchScreen] ? kImageCenterYPostionForThreePointFiveInchScreen : kImageCenterYPostion));
        self.backButton.alpha = 1.0f;
        self.textInputView.alpha = 1.0f;
        self.submitButton.alpha = 1.0f;
    }completion:^(BOOL finished){
        if (finished) {
            [image addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enlargeImage:)]];
            [image addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragImage:)]];
            [image addGestureRecognizer:[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchImage:)]];
            image.userInteractionEnabled = YES;
        }
    }];
    
    /* Animate in preview shadow (this happens simultaneously as the above animation) */
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    anim.fromValue = [NSNumber numberWithFloat:0];
    anim.toValue = [NSNumber numberWithFloat:0.2f];
    anim.duration = 0.5f;
    [self.previewView.layer addAnimation:anim forKey:@"shadowOpacity"];
    self.previewView.layer.shadowOffset = CGSizeMake(0, 2.0f);
    self.previewView.layer.shadowRadius = 5.0f;
    self.previewView.layer.shadowOpacity = 0.2f;
    
    self.previewViewLabel.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.previewViewLabel.alpha = 1.0f;
    }completion:nil];
    
    
}

-(void)resetSubviewsForNewImageFetch
{
    self.previewView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    [self updatePreviewViewWithText:@""];
    
    self.currentImage.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    self.currentImage.alpha = 1.0;
    [self.currentImage removeFromSuperview];
    self.currentImage = nil;
    
    self.textInputView.text = @"";
    self.textInputView.editable = YES;
    self.textInputView.center = CGPointMake(self.textInputView.center.x, self.view.frame.size.height - self.textInputView.inputView.frame.size.height - self.textInputView.frame.size.height/2);
    self.backButton.enabled = YES;
    self.submitButton.enabled = YES;
}

#pragma mark Description Submiting

-(void)submitImageAndMathmlToCloud
{
    /* This will eventually give the user feedback when the image is or is not submitted */
    [self showActivityIndicator];
    /* Fake network activty timer */
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(showSubmitSuccessfulView:) userInfo:nil repeats:NO];
    
}

-(void)showSubmitSuccessfulView:(NSTimer *)timer
{
    UIImageView *checkmark = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"submitSuccessfulCheck2.png"]];
    /* prepare for animation */
    checkmark.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    checkmark.center = self.view.center;
    
    UILabel *submitSuccessfulLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100.0f)];
    submitSuccessfulLabel.center = CGPointMake(self.view.frame.size.width/2.0f, -(submitSuccessfulLabel.frame.size.height/2.0f) + 20.0f);
    submitSuccessfulLabel.numberOfLines = 0;
    submitSuccessfulLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f];
    submitSuccessfulLabel.textAlignment = NSTextAlignmentCenter;
    submitSuccessfulLabel.text = @"Description Submitted Successfully";
    [self.view addSubview:submitSuccessfulLabel];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.activityIndicator.alpha = 0;
        self.activityIndicator.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    }completion:^(BOOL finished){
        [self.activityIndicator removeFromSuperview];
        [self resetActivityIndicatorScale];
        
        /* Animate in label */
        [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            submitSuccessfulLabel.center = CGPointMake(submitSuccessfulLabel.center.x, checkmark.center.y/2.0f);
        }completion:nil];
        
        /* Animate in checkmark simultaneously */
        [self.view addSubview:checkmark];
        [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            checkmark.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        }completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.6f delay:0 usingSpringWithDamping:0.45f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    checkmark.transform = CGAffineTransformMakeScale( 1.0f, 1.0f);
                }completion:^(BOOL finished){
                    if (finished) {
                        [self removeSubmitSuccessfulViewWithImage:checkmark andTextLabel:submitSuccessfulLabel];
                    }
                }];
            }
        }];
        
    }];
}

-(void)removeSubmitSuccessfulViewWithImage:(UIImageView *)image andTextLabel:(UILabel *)label
{
    /* image == checkmark image */
    [UIView animateWithDuration:0.2f delay:0.6f options:UIViewAnimationOptionCurveEaseOut animations:^{
        image.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            image.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            label.center = CGPointMake(label.center.x, -(label.frame.size.height/2.0f) + 20.0f);
        }completion:^(BOOL finished){
            if (finished) {
                [image removeFromSuperview];
                [label removeFromSuperview];
                [self redirectToNextImageFetchAfterSubmitSuccessViewWasShown];
            }
        }];
    }];
    
}

-(void)redirectToNextImageFetchAfterSubmitSuccessViewWasShown
{
    /* What happens next is determined by the mode */
    /* For now if we're in random mode, just gonna load another image */
    if (self.mode == ImageSelectionModeRandom) {
        [self showActivityIndicator];
        [self performSelector:@selector(fetchPic:) withObject:nil afterDelay:0.5];
    }else{
        /* Specific Image */
        UIViewController *superViewController = [[self.navigationController viewControllers]objectAtIndex:[[self.navigationController viewControllers]count]-2];
        if ([superViewController isMemberOfClass:[GalleryViewController class]]) {
            GalleryViewController *gallery = (GalleryViewController *)superViewController;
            [gallery removePreviouslySelectedImage];
        }
        [self.navigationController popViewControllerAnimated:NO];
    }
}

#pragma mark Helpers

-(void)showActivityIndicator
{
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

-(void)resetActivityIndicatorScale
{
    [self.activityIndicator stopAnimating];
    self.activityIndicator.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    self.activityIndicator.alpha = 1.0f;
}

-(BOOL)deviceHasThreePointFiveInchScreen
{
    return !([UIScreen mainScreen].bounds.size.height == 568.0);
}

-(CGAffineTransform)scaleTransformForTaskImage:(UIView *)image
{
    /* Calculate proper image scaling so the image fits properly in the main UI. Assuming any image size is possible */
    /* The max height of an image before it's too big for the 4 inch screen ui is 100.0. If It's bigger than that, then it will be scaled smaller until it is at most 100 points in height. */
    /* The max height for 3.5 inch screens is 85 */
    CGAffineTransform imageTransform;
    
    if ([self deviceHasThreePointFiveInchScreen]) {
        const CGFloat maxImageHeight = 70.0f;
        if (image.frame.size.height > maxImageHeight){
            // Image is too big
            imageTransform = CGAffineTransformScale(image.transform, maxImageHeight/image.frame.size.height, maxImageHeight/image.frame.size.height);
        }else{
            // Image is an ideal size, meaning it's below the max height
            imageTransform = CGAffineTransformScale(image.transform, (self.view.frame.size.width- 50.0f)/image.frame.size.width, (self.view.frame.size.width- 50.0f)/image.frame.size.width);
            
            if (((image.frame.size.height/image.transform.a) * imageTransform.a) > maxImageHeight){
                // if the previous transform makes the height too big, scale it down
                imageTransform = CGAffineTransformScale(image.transform, maxImageHeight/image.frame.size.height, maxImageHeight/image.frame.size.height);
            }
        }
    }else{
        const CGFloat maxImageHeight = 100.0f;
        if (image.frame.size.height > maxImageHeight){
            // Image is too big
            imageTransform = CGAffineTransformScale(image.transform, maxImageHeight/image.frame.size.height, maxImageHeight/image.frame.size.height);
        }else{
            // Image is an ideal size, meaning it's below the max height
            imageTransform = CGAffineTransformScale(image.transform, (self.view.frame.size.width- 50.0f)/image.frame.size.width, (self.view.frame.size.width- 50.0f)/image.frame.size.width);

            if (((image.frame.size.height/image.transform.a) * imageTransform.a) > maxImageHeight){
                // if the previous transform makes the height too big, scale it down
                imageTransform = CGAffineTransformScale(image.transform, maxImageHeight/image.frame.size.height, maxImageHeight/image.frame.size.height);
            }
        }
    }
    NSLog(@"%f %f %f", imageTransform.a, imageTransform.b, imageTransform.c);
    return imageTransform;

}

-(CGAffineTransform)scaleTransformForTaskImageThatTheUserScaledViaThePinchGesture:(UIView *)image
{
    /* Same as the above method, except scales are based of the images current transform. Basicly 'CGAffineTransformMakeScale' instead of 'CGAffineTransformScale' */

    CGAffineTransform imageTransform;
    
    if ([self deviceHasThreePointFiveInchScreen]) {
        const CGFloat maxImageHeight = 70.0f;
        if (image.frame.size.height > maxImageHeight){
            // Image is too big
            imageTransform = CGAffineTransformMakeScale(maxImageHeight/image.frame.size.height, maxImageHeight/image.frame.size.height);
        }else{
            // Image is an ideal size, meaning it's below the max height
            imageTransform = CGAffineTransformMakeScale((self.view.frame.size.width- 50.0f)/image.frame.size.width, (self.view.frame.size.width- 50.0f)/image.frame.size.width);
            
            if ((image.frame.size.height * imageTransform.a) > maxImageHeight){
                // if the previous transform makes the height too big, scale it down
                imageTransform = CGAffineTransformMakeScale(maxImageHeight/image.frame.size.height, maxImageHeight/image.frame.size.height);
            }
        }

    }else{
        const CGFloat maxImageHeight = 100.0f;
        if (image.frame.size.height > maxImageHeight){
            // Image is too big
            imageTransform = CGAffineTransformMakeScale(maxImageHeight/image.frame.size.height, maxImageHeight/image.frame.size.height);
        }else{
            // Image is an ideal size, meaning it's below the max height
            imageTransform = CGAffineTransformMakeScale((self.view.frame.size.width- 50.0f)/image.frame.size.width, (self.view.frame.size.width- 50.0f)/image.frame.size.width);
            
            if ((image.frame.size.height * imageTransform.a) > maxImageHeight){
                // if the previous transform makes the height too big, scale it down
                imageTransform = CGAffineTransformMakeScale(maxImageHeight/image.frame.size.height, maxImageHeight/image.frame.size.height);
            }
        }
    }
    
    return imageTransform;
    
}

-(void)handleHelpButtonPressed
{
    /* Presents the helpviewcontroller if the help button is pressed, because a view (the keyboard) can not do this */
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HelpViewController *helpViewController = (HelpViewController *)[storyboard instantiateViewControllerWithIdentifier:@"help"];
    [helpViewController adjustForModalPresentation];

    [self presentViewController:helpViewController animated:YES completion:nil];
    self.presentedHelpViewController = YES;
}

#pragma mark TextView and Preview View

-(void)textViewDidChange:(UITextView *)textView
{
    /* Refresh the MathML preview everytime a new charcter is typed */
    [self updatePreviewViewWithText:textView.text];
    
    
    if (![self.textInputView.text isEqualToString:@""]) {
        /*
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        anim.fromValue = [NSNumber numberWithFloat:0];
        anim.toValue = [NSNumber numberWithFloat:0.2f];
        anim.duration = 0.5f;
        [self.previewView.layer addAnimation:anim forKey:@"shadowOpacity"];
        self.previewView.layer.shadowOffset = CGSizeMake(0, 3.0f);
        self.previewView.layer.shadowRadius = 5.0f;
        self.previewView.layer.shadowOpacity = 0.2f;
         */
        [UIView animateWithDuration:0.5f animations:^{
            self.previewViewLabel.alpha = 0;
        }completion:^(BOOL finished){
            if (finished) {
                self.previewViewLabel.hidden = YES;
            }
        }];
        
    }else{
        self.previewViewLabel.hidden = NO;
        [UIView animateWithDuration:0.5f animations:^{
            self.previewViewLabel.alpha = 1.0f;
        }completion:nil];
    }
     
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
    NSString *html1 = [self deviceHasThreePointFiveInchScreen] ?
    @"<html><head><script type='text/x-mathjax-config'>MathJax.Hub.Config({messageStyle: 'none'});</script><script type='text/javascript' src = 'http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=AM_HTMLorMML-full'></script></head><body><div style='font-size: 110%; text-align: center;'>" :
    @"<html><head><script type='text/x-mathjax-config'>MathJax.Hub.Config({messageStyle: 'none'});</script><script type='text/javascript' src = 'http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=AM_HTMLorMML-full'></script></head><body><div style='font-size: 130%; text-align: center;'>";
        
    /*The following string is the same HTML as above except it sets the 'scale' in a mathjax configuration.*/
    /* It works, but the scaling takes about a second to take effect. If I use a div CSS (as done in the above string) then it takes effect immediately.
    
     NSString *foo = @"<html><head><script type='text/x-mathjax-config'>MathJax.Hub.Config({ 'HTML-CSS':{scale: 300}});</script><script type='text/javascript' src = 'http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=AM_HTMLorMML-full'></script></head><body>";
     */
    
    NSString *html2 = [html1 stringByAppendingString:asciimath];
    NSString *fullHtmlString = [html2 stringByAppendingString:@"</div></body></html>"];
    return fullHtmlString;
}

/* Guidance mode occurs when a 'MathKeyboardKeyTypeOperation' type key is pressed on the MathKeyboard.
 * These keys are like functions and require input (such as the square root key - sqrt(input)).
 * When guidance mode occurs, a yellow highlight is shown inside the parenthesis of the 'MathKeyboardKeyTypeOperation' value
 * The cursor arrow keys on the MathKeyboard are restricted to exiting the "function". When the user moves the cursor out of the
 * "functions" parenthesis, guidance mode ends, removing the highlight and allowing the arrow keys to freely move the cursor again
 */
-(void)enableGuidanceMode
{
    self.guidanceModeEnabled = YES;
}

-(void)disableGuidanceMode
{
    self.guidanceModeEnabled = NO;
}

@end
