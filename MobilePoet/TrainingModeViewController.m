//
//  TrainingModeViewController.m
//  MobilePoet
//
//  Created by Joseph Maag on 6/29/14.
//
//

#import "TrainingModeViewController.h"
#import "MathKeyboard.h"


NSString * const HTMLFileName2 = @"asciimathhtml.html";
const CGFloat kImageCenterYPostion;
const CGFloat kPreviewCenterYPostion;

@interface TrainingModeViewController () <UITextViewDelegate, UIAlertViewDelegate, UIWebViewDelegate>
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UITextView *textInputView;
@property (nonatomic, strong) UIWebView *previewView;
@property (nonatomic) BOOL imageIsEnlarged;
/* used for the tap gesture to make the fetched image bigger */
@property (nonatomic, strong) UIImageView *currentImage;
/* currently shown test image */
@property (nonatomic) int currentImageID;
/* current image id */
@property(nonatomic, strong)NSMutableArray *submissionViewSubviews;
/* All subviews of the translation submission view */
@property (strong, nonatomic) UIView *introView;
@property (strong, nonatomic) UIView *navigationBarLabel;
@property (strong, nonatomic) NSArray *testImages;
/* Array of the names of every test image */
@property (strong, nonatomic) NSArray *testImagesCorrectMathMLTraslations;
@property (strong, nonatomic) NSArray *testImagesCorrectASCIIMathTraslations;
/* The correct asciimath translation of each test image. In order of the test images ID/index */
@property (strong, nonatomic) UILabel *beginButton;
@end

@implementation TrainingModeViewController

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.testImages = @[@"testimg1.jpg"];
    self.testImagesCorrectMathMLTraslations = @[@"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><msup><mrow><mi>tan<.mi><mn>270<.mn><.mrow><mo>&.x2218;<.mo><.msup><mo>=<.mo><mfrac><msup><mrow><mi>sin<.mi><mn>270<.mn><.mrow><mo>&.x2218;<.mo><.msup><msup><mrow><mi>cos<.mi><mn>270<.mn><.mrow><mo>&.x2218;<.mo><.msup><.mfrac><mo>=<.mo><mo>-<.mo><mfrac><mn>1<.mn><mn>0<.mn><.mfrac><.mstyle><.math>"];
    self.testImagesCorrectASCIIMathTraslations = @[@"tan270^circ = (sin270^circ)/(cos270^circ) = -1/0"];
    
    /* top buttons */
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    backButton.center = CGPointMake(30.0f, 40.0f);
    backButton.tintColor = [UIColor blueColor];
    backButton.alpha = 0;
    backButton.showsTouchWhenHighlighted = YES;
    self.backButton = backButton;
    [self.view addSubview:self.backButton];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [submitButton setTitle:@"Check" forState:UIControlStateNormal];
    [submitButton sizeToFit];
    [submitButton addTarget:self action:@selector(checkPressed:) forControlEvents:UIControlEventTouchUpInside];
    submitButton.center = CGPointMake(self.view.frame.size.width-35.0f, 40.0f);
    submitButton.tintColor = [UIColor blueColor];
    submitButton.alpha = 0;
    submitButton.showsTouchWhenHighlighted = YES;
    self.submitButton = submitButton;
    [self.view addSubview:self.submitButton];
    
    /* "Practice" label */
    UILabel *practiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100.0f, 25.0f)];
    practiceLabel.center = CGPointMake(self.view.center.x, submitButton.center.y);
    //practiceLabel.font = [UIFont fontWithName:@"Avenir" size:18.0f];
    practiceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f];
    practiceLabel.textAlignment = NSTextAlignmentCenter;
    practiceLabel.text = @"Practice";
    practiceLabel.alpha = 0;
    self.navigationBarLabel = practiceLabel;
    [self.view addSubview:self.navigationBarLabel];
    
    
    /* text view */
    self.textInputView = [[UITextView alloc]initWithFrame:(CGRect){CGPointZero, self.view.frame.size.width, 80.0f}];
    [MathKeyboard addMathKeyboardToTextView:self.textInputView];
    self.textInputView.font = [UIFont systemFontOfSize:15.0f];
    self.textInputView.center = CGPointMake(self.textInputView.center.x, self.view.frame.size.height - self.textInputView.inputView.frame.size.height - self.textInputView.frame.size.height/2);
    self.textInputView.alpha = 0;
    self.textInputView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textInputView.autocorrectionType = UITextAutocapitalizationTypeNone;
    self.textInputView.textAlignment = NSTextAlignmentCenter;
    self.textInputView.delegate = self;
    [self.view addSubview:self.textInputView];
    
    /* preview view */
    self.previewView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100.0f)];
    /* center is calculated after image is fetched */
    self.previewView.backgroundColor = [UIColor blackColor];
    self.previewView.hidden = YES;
    [self setupPreviewViewHtml];
    self.previewView.userInteractionEnabled = NO;
    self.previewView.delegate = self;
    [self.view addSubview:self.previewView];
    
    self.submissionViewSubviews = [NSMutableArray new];
    
    [self setUpIntroView];
}

-(void)setUpIntroView
{
    //the intro view is the first view that is seen that talks about what traing mode is
    UIView *introView = [[UIView alloc]initWithFrame:self.view.frame];
    UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200.0f, 50.0f)];
    titlelabel.center = CGPointMake(self.view.center.x, titlelabel.frame.size.height + 30.0f);
    titlelabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:23.0f];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.text = @"Training";
    [introView addSubview:titlelabel];
    
    UITextView *bodyTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 20.0f, 180.0f)];
    bodyTextView.center = CGPointMake(self.view.center.x, titlelabel.center.y + titlelabel.frame.size.height + bodyTextView.frame.size.height/2);
    bodyTextView.font = [UIFont fontWithName:@"Avenir" size:15.0f];
    bodyTextView.textAlignment = NSTextAlignmentCenter;
    bodyTextView.text = @"Here you can pratice writing asciimath and describing photos. You’ll be shown a few sample images and be told the accuracy of your math description.\n\n\nNone of the work you do will be submitted to the MathML Cloud servers.";
    [introView addSubview:bodyTextView];
    
    UILabel *beginButton = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45.0f)];
    beginButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height + beginButton.frame.size.height);
    beginButton.backgroundColor = [UIColor blueColor];
    beginButton.textColor = [UIColor whiteColor];
    beginButton.textAlignment = NSTextAlignmentCenter;
    beginButton.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    beginButton.text = @"Begin";
    beginButton.userInteractionEnabled = YES;
    [beginButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(beginButtonTapped:)]];
    self.beginButton = beginButton;
    
    self.introView = introView;
    [self.view addSubview:self.introView];
    [self.view addSubview:self.beginButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.beginButton.center = CGPointMake(self.beginButton.center.x, self.view.frame.size.height - 120.0f);
    }completion:nil];
    
}

-(void)setupPreviewViewHtml
{
    /* Setups html */
    NSString *tempDir = NSTemporaryDirectory();
    NSString *path = [tempDir stringByAppendingPathComponent:HTMLFileName2];
    NSString *htmlString = [self makeHtmlFromAsciimath:@""];
    [htmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    [self.previewView loadRequest:req];
}

-(UILabel *)makeBorderedButtonWithColor:(UIColor *)color andText:(NSString *)text
{
    UILabel *button = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45.0f)];
    button.backgroundColor = color;
    button.textColor = [UIColor whiteColor];
    button.textAlignment = NSTextAlignmentCenter;
    button.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    button.text = text;
    button.userInteractionEnabled = YES;
    
    return button;
}



#pragma mark Button actions

-(void)beginButtonTapped:(UITapGestureRecognizer *)gesture
{
    gesture.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.introView.center = CGPointMake(self.introView.center.x, self.introView.center.y - self.view.frame.size.height);
        self.beginButton.center = CGPointMake(self.beginButton.center.x, self.view.frame.size.height + self.beginButton.frame.size.height * 4);
    }completion:^(BOOL finished){
        if (finished) {
            [self.introView removeFromSuperview];
            self.introView = nil;
            [self fetchPic:nil];
        }
    }];
}

-(void)checkPressed:(UIButton *)button
{
    /* The user's description is checked by comparing their resulting MathML code, generated by MathJax, to the correct code
     The mathML is first generated, then checked in 'checkUserDescriptionWithMathML' where the result will also be handled.
     */
    
    if (![self.textInputView.text isEqualToString:@""]) {
        [self generateAndSendMathML];
    }else{
        /* no text entered */
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Empty Translation" message:@"You need to translate the image before you can submit it!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
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
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Congratulatory and Continue View

-(void)constructAndShowCongratulatoryAndContinueView
{
    /* Constructs, and animates, the 'Congratulatory view' when the 'check' button is pressed and their translation is correct. The user can then decide if they want to continue or not */
    
    /* Setup views. View center postions are set to their beginning position in the animation where they will be animated in */
    
    self.textInputView.editable = NO;
    self.backButton.enabled = NO;
    self.submitButton.enabled = NO;
    
    //Labels
    UILabel *confirmInstructionTextView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100.0f)];
    confirmInstructionTextView.center = CGPointMake(self.view.frame.size.width/2.0f, -(confirmInstructionTextView.frame.size.height/2.0f) + 20.0f);
    confirmInstructionTextView.numberOfLines = 0;
    confirmInstructionTextView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f];
    //confirmInstructionTextView.font = [UIFont fontWithName:@"Avenir-Black" size:20.0f];
    confirmInstructionTextView.textAlignment = NSTextAlignmentCenter;
    confirmInstructionTextView.text = @"Looks good!";
    [self.submissionViewSubviews removeAllObjects];
    [self.submissionViewSubviews addObject:confirmInstructionTextView];
    [self.view addSubview:confirmInstructionTextView];
    
    UILabel *imageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20.0f)];
    imageLabel.backgroundColor = [UIColor blueColor];
    
    
    UILabel *newImageButton = [self makeBorderedButtonWithColor:[UIColor blueColor] andText:@"New Image"];
    newImageButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height + newImageButton.frame.size.height);
    [newImageButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(newImagePressed:)]];
    [self.submissionViewSubviews addObject:newImageButton];
    [self.view addSubview:newImageButton];
    
    UILabel *mainMenuButton = [self makeBorderedButtonWithColor:[UIColor blueColor] andText:@"Main Menu"];
    mainMenuButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height + mainMenuButton.frame.size.height + 100.0f);
    [mainMenuButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mainMenuPressed:)]];
    [self.submissionViewSubviews addObject:mainMenuButton];
    [self.view addSubview:mainMenuButton];

    
    /* Animate congratulatory view */
    [UIView animateWithDuration:0.6f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        /* animate existing task subviews */
        self.currentImage.transform = CGAffineTransformScale(self.currentImage.transform, (self.view.frame.size.width- 50.0f)/self.currentImage.frame.size.width, (self.view.frame.size.width- 50.0f)/self.currentImage.frame.size.width);
        self.currentImage.center = CGPointMake(self.currentImage.center.x, self.currentImage.center.y + 100.0f);
        self.previewView.center = CGPointMake(self.previewView.center.x, self.previewView.center.y + 165.0f);
        self.textInputView.center = CGPointMake(self.textInputView.center.x, self.textInputView.center.y + 300.0f);
        self.textInputView.alpha = 0;
        
        confirmInstructionTextView.center = CGPointMake(confirmInstructionTextView.center.x, confirmInstructionTextView.center.y + confirmInstructionTextView.frame.size.height + 20.0f);
        
        self.submitButton.alpha = 0;
        self.backButton.alpha = 0;
        self.navigationBarLabel.alpha = 0;
        
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.6f delay:0.7f usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            /***old animation ***
            [UIView animateWithDuration:0.7f delay:0.7f usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            */
            
            self.previewView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            self.currentImage.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            self.previewView.center = CGPointMake(self.view.frame.size.width/2.0f, self.view.frame.size.height/2.0f);
            self.currentImage.center = CGPointMake(self.view.frame.size.width/2.0f, self.view.frame.size.height/2.0f);
            confirmInstructionTextView.center = CGPointMake(confirmInstructionTextView.center.x, confirmInstructionTextView.center.y - 200.0f);
            self.previewView.alpha = 0;
            self.currentImage.alpha = 0;
            
        }completion:^(BOOL finished){
            if (finished) {
                confirmInstructionTextView.text = @"Continue?";
                // Animate in continue view
                [UIView animateWithDuration:0.6f delay:0.0 usingSpringWithDamping:1.0f initialSpringVelocity:0.8f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    newImageButton.center = CGPointMake(newImageButton.center.x, self.view.center.y - 50.0f);
                    mainMenuButton.center = CGPointMake(mainMenuButton.center.x, self.view.center.y + 50.0f);
                    confirmInstructionTextView.center = CGPointMake(confirmInstructionTextView.center.x, confirmInstructionTextView.center.y + 200.0f);
                }completion:nil];
            }
        }];
    }];
}

-(void)newImagePressed:(UITapGestureRecognizer *)gesture
{
    [self animateAwayCongratulatoryAndContinueView:gesture];
}

-(void)mainMenuPressed:(UITapGestureRecognizer *)gesture
{
    [self animateAwayCongratulatoryAndContinueView:gesture];
}



-(void)animateAwayCongratulatoryAndContinueView:(UITapGestureRecognizer *)gesture
{
    /* Animate away continue view */
    
    /* Get references to all 'submission view' subviews */
    UILabel *continueTextView = self.submissionViewSubviews[0];
    UILabel *newImageButton = self.submissionViewSubviews[1];
    UILabel *mainMenuButton = self.submissionViewSubviews[2];

    
    /* Animate away submission subviews */
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        continueTextView.center = CGPointMake(continueTextView.center.x, continueTextView.center.y - 120.0f);
        newImageButton.center = CGPointMake(newImageButton.center.x, self.view.frame.size.height + newImageButton.frame.size.height);
        mainMenuButton.center = CGPointMake(mainMenuButton.center.x, self.view.frame.size.height + mainMenuButton.frame.size.height);
        
    }completion:^(BOOL finished){
        if (finished) {
            [continueTextView removeFromSuperview];
            [newImageButton removeFromSuperview];
            [mainMenuButton removeFromSuperview];
            [self.submissionViewSubviews removeAllObjects];
            /* set 'imageIsEnlarged' to 'NO' since the image has shrunk to its scaled size, regardless if the image was enlarged in the 'submission view' */
            self.imageIsEnlarged = NO;
            
            if (gesture.view == newImageButton){
                [self fetchPic:nil];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
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
            self.imageIsEnlarged = NO;
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
    [self resetSubviewsForNewImage];

    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:self.testImages[0]]];
    self.currentImage = image;
    self.currentImageID = 0;
    
    /* prepare image for animation */
    image.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    image.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    image.alpha = 0;
    image.layer.shadowOpacity = 0.3f;
    image.layer.shadowOffset = CGSizeMake(0,0);
    [self.view addSubview:image];
    
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
                self.previewView.alpha = 1.0f;
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
                    
                    [UIView animateWithDuration:0.5f animations:^{
                        self.navigationBarLabel.alpha = 1.0f;
                    }completion:nil];
                }
            }];
        }
    }];
}


-(void)resetSubviewsForNewImage
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
    NSString *path = [tempDir stringByAppendingPathComponent:HTMLFileName2];
    NSString *htmlString = [self makeHtmlFromAsciimath:userText];
    [htmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self.previewView reload];
}

-(NSString *)makeHtmlFromAsciimath:(NSString *)asciimath
{
    NSString *html1 = @"<html><head><script type='text/x-mathjax-config'>"
    "MathJax.Hub.Config({messageStyle: 'none', extensions: ['toMathML.js']});"
    "</script><script type='text/javascript' src = 'http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=AM_HTMLorMML-full'></script>"
    "<script> function toMathML(jax,callback) { var mml; try { mml = jax.root.toMathML(''); } catch(err) {"
            "if (!err.restart) {throw err} // an actual error"
    "return MathJax.Callback.After([toMathML,jax,callback],err.restart);"
    "} MathJax.Callback(callback)(mml);} </script>"
    "</head><body><div style='font-size: 130%; text-align: center;'>";
    /*
     NSString *html1 = @"<html><head><script type='text/x-mathjax-config'>MathJax.Hub.Config({messageStyle: 'none'});</script><script type='text/javascript' src = 'http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=AM_HTMLorMML-full'></script><style>body{background-color:black;}</style></head><body><div style='font-size: 130%; text-align: center; background-color:black; color:white;'>";
     */
    
    /*The following string is the same HTML as above except it sets the 'scale' in a mathjax configuration.*/
    /* It works, but the scaling takes about a second to take effect. If I use a div CSS (as done in the above string) then it takes effect immediately.
     
     NSString *foo = @"<html><head><script type='text/x-mathjax-config'>MathJax.Hub.Config({ 'HTML-CSS':{scale: 300}});</script><script type='text/javascript' src = 'http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=AM_HTMLorMML-full'></script></head><body>";
     */
    
    NSString *html2 = [html1 stringByAppendingString:asciimath];
    NSString *fullHtmlString = [html2 stringByAppendingString:@"</div></body></html>"];
    return fullHtmlString;
}


-(void)generateAndSendMathML
{
    /* The only way to get MathJax to return the resulting mathML code is to define a js function that does
     so, and then push it onto MathJax's callback queue.
     This makes getting that resulting MathML string into an NSString pretty much impossible.
     ... Except if you put that resulting code in a a fake page location url, and then extract the code in the UIWebView delegate.
     
     This method performs that js function, and the 'shouldStartLoadWithRequest' delegate method will extract the code.
     
     There are 2 string replacements in the js function. This is because those specific charcters stopped all the following charcters after that to not be copied into the fake address. A little confusing, but it's necessary to get the entirety of the MathML string into a fake address
     */
    
     [self.previewView stringByEvaluatingJavaScriptFromString:@"MathJax.Hub.Queue( function f() {var jax = MathJax.Hub.getAllJax(); if(jax.length = 1){var thing = jax[0].root.toMathML(\"\"); thing = thing.replace(/\\//g, \".\"); thing = thing.replace(\":\", \".\"); thing = thing.replace(/\\#/g, \".\"); window.location = \"fakeLocation://\".concat(thing);}})"];


}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* url = request.URL;
    if ([url.host hasPrefix:@"<math"] ) {
        /* This address is not legit, and is instead mathml code passed in from the 'generateMathML method'*/
        NSString *mathml = [url.host stringByReplacingOccurrencesOfString:@" " withString:@""];
        mathml = [mathml stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSLog(@"ML");
        NSLog(@"%@", mathml);
        [self checkUserDescriptionWithMathML:mathml];
        
        return NO;
    }
    return YES;
}

-(void)checkUserDescriptionWithMathML:(NSString *)mathml
{
    if ([mathml isEqualToString:self.testImagesCorrectMathMLTraslations[self.currentImageID]]) {
        [self constructAndShowCongratulatoryAndContinueView];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Incorrect Description" message:[NSString stringWithFormat: @"Your description does not seem to produce a similar math image. Here's a good possible ASCIIMath translation:\n\n%@", self.testImagesCorrectASCIIMathTraslations[self.currentImageID]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

@end
