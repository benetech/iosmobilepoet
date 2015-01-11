//
//  TrainingModeViewController.m
//  MobilePoet
//
//  Created by Joseph Maag on 6/29/14.
//
//

#import "TrainingModeViewController.h"
#import "MathKeyboard.h"
#import "HelpViewController.h"


NSString * const HTMLFileName2 = @"asciimathhtml.html";
const CGFloat kImageCenterYPostion;
const CGFloat kPreviewCenterYPostion;
/* Adjusted constants for iPhone 4 and 4s 3.5 inch screens */
const CGFloat kImageCenterYPostionForThreePointFiveInchScreen;
const CGFloat kPreviewCenterYPostionForThreePointFiveInchScreen;

@interface TrainingModeViewController () <UITextViewDelegate, UIAlertViewDelegate, UIWebViewDelegate>
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UITextView *textInputView;
/* Main textview that the user types in their ASCIIMath in */
@property (nonatomic, strong) UIWebView *previewView;
@property (nonatomic) BOOL imageIsEnlarged;
/* used for the tap gesture to make the fetched image bigger */
@property (nonatomic, strong) UIImageView *currentImage;
/* currently shown test image */
@property (nonatomic) int currentImageID;
/* current image id / represents the index position of the current image in the image array */
@property(nonatomic, strong)NSMutableArray *submissionViewSubviews;
/* All subviews of the translation submission view */
@property (strong, nonatomic) UIView *introView;
/* introview contains the subviews that make up the intro view, which is the first view shown that talks about what training mode is */
@property (strong, nonatomic) UIView *navigationBarLabel;
@property (strong, nonatomic) NSArray *practiceImageNames;
/* The names of every pratice image */
@property (strong, nonatomic) NSArray *practiceImagesCorrectMathMLTraslations;
/* The correct MathML representation of each practice image. */
/* Each object in the array is an array of acceptable mathml translations for the image with the same image id as the index */
@property (strong, nonatomic) NSArray *practiceImagesCorrectASCIIMathTraslations;
/* A possible correct asciimath translation of each test image. In order of the test images ID/index */
@property (strong, nonatomic) UILabel *beginButton;
@property (strong, nonatomic) NSTimer *mathJaxLoadingTimer;
/* Is used to recognize if mathjax is taking too long generate mathML */
@property (strong, nonatomic) NSArray *longLoadingTimeViews;
/* A set of views that are shown when mathjax has not returned a mathml result in one second */
@property (strong, nonatomic) UILabel *previewViewLabel;
/* Label that says "(Preview)" when nothing is typed in the textview */
@property (strong, nonatomic) UIButton *introBackButton;
@property (strong, nonatomic) NSMutableArray *uiGuideViews;
/* Contains all views that make up the UI Guide, which only shows up when the user first enters training mode. */
/* The UI Guide points out important UI elements to the user */
@property (nonatomic) BOOL showedUIGuide;
@property (nonatomic) BOOL presentedHelpViewController;
/* Keeps track of if the HelpViewController was just presented/dismissed. */
@end

@implementation TrainingModeViewController

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpPracticeImageData];
    
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
    [submitButton setTitle:@"Check" forState:UIControlStateNormal];
    [submitButton sizeToFit];
    [submitButton addTarget:self action:@selector(checkPressed:) forControlEvents:UIControlEventTouchUpInside];
    submitButton.center = CGPointMake(self.view.frame.size.width-35.0f, 40.0f);
    submitButton.tintColor = [UIColor colorWithRed:0 green:30/255.0f blue:168/255.0f alpha:1.0f];
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
    self.textInputView = [[UITextView alloc]initWithFrame:(CGRect){CGPointZero, self.view.frame.size.width, [self deviceHasThreePointFiveInchScreen] ? 65.0f : 80.0f}];
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
    self.previewView.delegate = self;
    [self.view addSubview:self.previewView];
    
    /* Displaying the help menu when 'help' is pressed on the keyboard is handled by here, triggered by a notification */
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleHelpButtonPressed:) name:@"helpButtonPressed" object:nil];
    
    [self setUpIntroView];
    
    /* Check whether this is the users first time trying training mode. If so we'll show the UI Guide and disable the submit button */
    [self checkWhetherToShowUIGuide];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.presentedHelpViewController) {
        self.presentedHelpViewController = NO;
        [self.textInputView becomeFirstResponder];
        return;
    }
    /* Animate in begin button */
    [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.beginButton.center = CGPointMake(self.beginButton.center.x, self.view.frame.size.height - 120.0f);
    }completion:nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareAndExecuteBackButtonAnimation];
}

-(void)prepareAndExecuteBackButtonAnimation
{
    self.introBackButton.center = CGPointMake(self.introBackButton.center.x - 70.0f, self.introBackButton.center.y);
    [UIView animateWithDuration:0.45f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.introBackButton.center = CGPointMake(self.introBackButton.center.x + 70.0f, self.introBackButton.center.y);
    }completion:nil];
}

-(void)setUpPracticeImageData
{
    self.practiceImageNames = @[@"practiceImage3.jpg", @"practiceimage2.jpg", @"practiceimage1.jpg", @"practiceImage4.jpg", @"practiceimage5.jpg"];
    self.practiceImagesCorrectMathMLTraslations = @[
        /* Image 1 */
        @[@"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><msup><mi>x<.mi><mn>2<.mn><.msup><mo>+<.mo><mn>4<.mn><msup><mi>y<.mi><mn>2<.mn><.msup><mo>-<.mo><mn>36<.mn><mo>=<.mo><mn>0<.mn><.mstyle><.math>",
          @"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><msup><mrow><mo>(<.mo><mi>x<.mi><mo>)<.mo><.mrow><mrow><mn>2<.mn><.mrow><.msup><mo>+<.mo><mn>4<.mn><msup><mrow><mo>(<.mo><mi>y<.mi><mo>)<.mo><.mrow><mrow><mn>2<.mn><.mrow><.msup><mo>-<.mo><mn>36<.mn><mo>=<.mo><mn>0<.mn><.mstyle><.math>",
          @"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><msup><mrow><mo>(<.mo><mi>x<.mi><mo>)<.mo><.mrow><mrow><mn>2<.mn><.mrow><.msup><mo>+<.mo><mn>4<.mn><msup><mi>y<.mi><mn>2<.mn><.msup><mo>-<.mo><mn>36<.mn><mo>=<.mo><mn>0<.mn><.mstyle><.math>",
          @"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><msup><mi>x<.mi><mn>2<.mn><.msup><mo>+<.mo><mn>4<.mn><msup><mrow><mo>(<.mo><mi>y<.mi><mo>)<.mo><.mrow><mrow><mn>2<.mn><.mrow><.msup><mo>-<.mo><mn>36<.mn><mo>=<.mo><mn>0<.mn><.mstyle><.math>"],
        /* Image 2 */
        @[@"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><mi>C<.mi><mo>=<.mo><msqrt><mrow><msup><mi>A<.mi><mn>2<.mn><.msup><mo>+<.mo><msup><mi>B<.mi><mn>2<.mn><.msup><.mrow><.msqrt><.mstyle><.math>",
          @"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><mi>C<.mi><mo>=<.mo><msqrt><mrow><msup><mrow><mo>(<.mo><mi>A<.mi><mo>)<.mo><.mrow><mrow><mn>2<.mn><.mrow><.msup><mo>+<.mo><msup><mrow><mo>(<.mo><mi>B<.mi><mo>)<.mo><.mrow><mrow><mn>2<.mn><.mrow><.msup><.mrow><.msqrt><.mstyle><.math>"],
        /* Image 3 */
        @[@"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><msup><mrow><mi>tan<.mi><mn>270<.mn><.mrow><mo>&.x2218;<.mo><.msup><mo>=<.mo><mfrac><msup><mrow><mi>sin<.mi><mn>270<.mn><.mrow><mo>&.x2218;<.mo><.msup><msup><mrow><mi>cos<.mi><mn>270<.mn><.mrow><mo>&.x2218;<.mo><.msup><.mfrac><mo>=<.mo><mo>-<.mo><mfrac><mn>1<.mn><mn>0<.mn><.mfrac><.mstyle><.math>",
          @"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><mrow><mi>tan<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><mo>=<.mo><mfrac><mrow><mi>sin<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><mrow><mi>cos<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><.mfrac><mo>=<.mo><mo>-<.mo><mfrac><mn>1<.mn><mn>0<.mn><.mfrac><.mstyle><.math>",
          @"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><mrow><mi>tan<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><mo>=<.mo><mrow><mo>(<.mo><mfrac><mrow><mi>sin<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><mrow><mi>cos<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><.mfrac><mo>)<.mo><.mrow><mo>=<.mo><mo>-<.mo><mfrac><mn>1<.mn><mn>0<.mn><.mfrac><.mstyle><.math>",
          @"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><mrow><mi>tan<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><mo>=<.mo><mfrac><mrow><mi>sin<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><mrow><mi>cos<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><.mfrac><mo>=<.mo><mfrac><mrow><mo>-<.mo><mn>1<.mn><.mrow><mrow><mn>0<.mn><.mrow><.mfrac><.mstyle><.math>",
          @"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><mrow><mi>tan<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><mo>=<.mo><mrow><mo>(<.mo><mfrac><mrow><mi>sin<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><mrow><mi>cos<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><.mfrac><mo>)<.mo><.mrow><mo>=<.mo><mfrac><mrow><mo>-<.mo><mn>1<.mn><.mrow><mrow><mn>0<.mn><.mrow><.mfrac><.mstyle><.math>",
          @"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><mrow><mi>tan<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><mo>=<.mo><mfrac><mrow><mrow><mi>sin<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><.mrow><mrow><mrow><mi>cos<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><.mrow><.mfrac><mo>=<.mo><mo>-<.mo><mfrac><mn>1<.mn><mn>0<.mn><.mfrac><.mstyle><.math>",
          @"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><mrow><mi>tan<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><mo>=<.mo><mfrac><mrow><mrow><mi>sin<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><.mrow><mrow><mrow><mi>cos<.mi><mrow><mo>(<.mo><msup><mn>270<.mn><mo>&.x2218;<.mo><.msup><mo>)<.mo><.mrow><.mrow><.mrow><.mfrac><mo>=<.mo><mfrac><mrow><mo>-<.mo><mn>1<.mn><.mrow><mrow><mn>0<.mn><.mrow><.mfrac><.mstyle><.math>"],
        /* Image 4 */
        @[@"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><mrow><mi>sin<.mi><mn>4<.mn><.mrow><mi>x<.mi><mo>+<.mo><mrow><mi>sin<.mi><mn>2<.mn><.mrow><mi>x<.mi><mo>=<.mo><mn>0<.mn><.mstyle><.math>",
          @"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><mrow><mi>sin<.mi><mrow><mo>(<.mo><mn>4<.mn><mi>x<.mi><mo>)<.mo><.mrow><.mrow><mo>+<.mo><mrow><mi>sin<.mi><mrow><mo>(<.mo><mn>2<.mn><mi>x<.mi><mo>)<.mo><.mrow><.mrow><mo>=<.mo><mn>0<.mn><.mstyle><.math>"],
        /* Image 5 */
        @[@"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><mn>2<.mn><mi>&.x3C0;<.mi><mi>n<.mi><mo>&.xB1;<.mo><mfrac><mi>&.x3C0;<.mi><mn>2<.mn><.mfrac><.mstyle><.math>",
          @"<mathxmlns=\"http...www.w3.org.1998.Math.MathML\"><mstyledisplaystyle=\"true\"><mn>2<.mn><mi>&.x3C0;<.mi><mi>n<.mi><mo>&.xB1;<.mo><mfrac><mrow><mi>&.x3C0;<.mi><.mrow><mrow><mn>2<.mn><.mrow><.mfrac><.mstyle><.math>"]];
    self.practiceImagesCorrectASCIIMathTraslations = @[
        @"x^2 + 4y^2 - 36 = 0",
        @"C = sqrt(A^2 + B^2)",
        @"tan270^circ = (sin270^circ)/(cos270^circ) = -1/0",
        @"sin(4x) + sin(2x) = 0",
        @"2pin +- pi/2"];
    
    /* Set the current image id property to -1 to prepare it for setting */
    self.currentImageID = -1;
}

-(void)setUpIntroView
{
    //the intro view is the first view that is seen that talks about what traing mode is
    UIView *introView = [[UIView alloc]initWithFrame:self.view.frame];
    UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200.0f, 50.0f)];
    titlelabel.center = CGPointMake(self.view.center.x, titlelabel.frame.size.height + 50.0f);
    titlelabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:23.0f];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.text = @"Training";
    [introView addSubview:titlelabel];
    
    UITextView *bodyTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 20.0f, 180.0f)];
    bodyTextView.center = CGPointMake(self.view.center.x, titlelabel.center.y + titlelabel.frame.size.height + ([self deviceHasThreePointFiveInchScreen] ? bodyTextView.frame.size.height/3 : bodyTextView.frame.size.height/2));
    bodyTextView.font = [UIFont fontWithName:@"Avenir" size:15.0f];
    bodyTextView.textAlignment = NSTextAlignmentCenter;
    bodyTextView.text = @"Here you can practice writing ASCIIMath and describing images. You’ll be shown a few sample images and be told the accuracy of your math description.\n\n\nNone of the work you do will be submitted to the MathML Cloud servers.";
    bodyTextView.userInteractionEnabled = NO;
    [introView addSubview:bodyTextView];
    
    UILabel *beginButton = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45.0f)];
    beginButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height + beginButton.frame.size.height);
    beginButton.backgroundColor = [UIColor colorWithRed:0 green:38/255.0f blue:221/255.0f alpha:1.0f];
    beginButton.textColor = [UIColor whiteColor];
    beginButton.textAlignment = NSTextAlignmentCenter;
    beginButton.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    beginButton.text = @"Begin";
    beginButton.userInteractionEnabled = YES;
    [beginButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(beginButtonTapped:)]];
    self.beginButton = beginButton;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *backImage = [UIImage imageNamed:@"backToMenuButton.png"];
    [backButton setBackgroundImage:backImage forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    backButton.transform = CGAffineTransformMakeScale(55.0f/backButton.frame.size.width, 55.0f/backButton.frame.size.width);
    [backButton addTarget:self action:@selector(introBackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    backButton.center = CGPointMake(30.0f, 40.0f);
    [introView addSubview:backButton];
    self.introBackButton = backButton;
    
    self.introView = introView;
    [self.view addSubview:self.introView];
    [self.view addSubview:self.beginButton];
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

-(UILabel *)previewViewLabel{
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

-(void)checkWhetherToShowUIGuide
{
    /* Using nsuserdefaults... */
    if (!self.showedUIGuide) {
        self.submitButton.enabled = NO;
    }
}

-(NSMutableArray *)uiGuideViews
{
    if (!_uiGuideViews) {
        _uiGuideViews = [NSMutableArray new];
    }
    return _uiGuideViews;
}

#pragma mark UI Guide View

/*** Training Mode UI Introduction Guide ***/

/* UI Guide is the animated, sort of slide show, shown when the user first tries training mode. */

-(void)setUpAndShowUIGuide
{
    /* The UIGuide only shows when the user first uses training mode. It points out particular UI elements that are important. 
     It is not its own 'view' but is instead a collection of subviews added and removed from the trainingModeViewController view to create an animated slideshow of sorts. */
    UIView *darkView = [[UIView alloc]initWithFrame:self.view.frame];
    darkView.backgroundColor = [UIColor blackColor];
    darkView.alpha = 0;
    [self.view addSubview:darkView];
    /* self.uiGuideViews will hold all of the subviews that are shown */
    [self.uiGuideViews addObject:darkView];
    
    UITextView *keyboardDialogTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 130.0f)];
    keyboardDialogTextView.editable = NO;
    keyboardDialogTextView.backgroundColor = [UIColor clearColor];
    keyboardDialogTextView.center = CGPointMake(self.view.center.x, -keyboardDialogTextView.frame.size.height);
    keyboardDialogTextView.textColor = [UIColor whiteColor];
    keyboardDialogTextView.textAlignment = NSTextAlignmentCenter;
    keyboardDialogTextView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    keyboardDialogTextView.text = @"You can scroll the keyboard left and right to access other keys on the keyboard.";
    [self.view addSubview:keyboardDialogTextView];
    [self.uiGuideViews addObject:keyboardDialogTextView];
    
    UILabel *okButton = [self makeBorderedButtonWithColor:[UIColor blueColor] andText:@"Ok"];
    okButton.center = CGPointMake(darkView.center.x, darkView.frame.size.height + okButton.frame.size.height);
    [okButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(okButtonPressedForKeyboardDialog:)]];
    [self.view addSubview:okButton];
    [self.uiGuideViews addObject:okButton];
    
    [UIView animateWithDuration:0.5f animations:^{
        darkView.alpha = 0.9f;
    }completion:^(BOOL finished){
        if (finished) {
            [UIView animateWithDuration:0.7f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                keyboardDialogTextView.center = CGPointMake(keyboardDialogTextView.center.x, [self deviceHasThreePointFiveInchScreen] ? darkView.center.y - 115.0f : darkView.center.y - 100.0f);
                okButton.center = CGPointMake(okButton.center.x, [self deviceHasThreePointFiveInchScreen] ? darkView.center.y - 50.0f : darkView.center.y - 20.0f);
            }completion:^(BOOL finished){
                if (finished) {
                    MathKeyboard *keyboard = (MathKeyboard *)self.textInputView.inputView;
                    [keyboard enableUIGuideMode];
                }
            }];
        }
    }];
}

/* The next few methods prefixed with "okbutton" will handle each next step in the ui guide walkthorugh */
/* Each of the methods represents the completion of a guide dialog, or essentially pressing 'next slide' during a slideshow */

-(void)okButtonPressedForKeyboardDialog:(id)sender
{
    /* Show arrow cursor keys dialog */
    
    /* Get a reference to the guide subviews */
    UITextView *dialogTextView;
    UILabel *okButton;
    UIView *darkView;
    for (UIView *uiGuideView in self.uiGuideViews) {
        if ([uiGuideView isKindOfClass:[UITextView class]]) {
            dialogTextView = (UITextView *)uiGuideView;
        }else if ([uiGuideView isMemberOfClass:[UILabel class]]){
            okButton = (UILabel *)uiGuideView;
        }else{
            darkView = uiGuideView;
        }
    }
    MathKeyboard *keyboard = (MathKeyboard *)self.textInputView.inputView;
    
    if (dialogTextView) {
        /* If all went well with finding the references, continue with the guide */
        
        //Animate away ok button and dialog textview. Tell the keyboard to animate away the yellow border
        [keyboard removeYellowBorderForUIGuide];
        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            okButton.center = CGPointMake(okButton.center.x, okButton.center.y + 350.0f);
            dialogTextView.center = CGPointMake(self.view.center.x, -dialogTextView.frame.size.height);

        }completion:^(BOOL finished){
            if (finished) {
                [okButton removeGestureRecognizer:okButton.gestureRecognizers[0]];
                [okButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(okButtonPressedForArrowKeys:)]];
                dialogTextView.text = @"The arrow keys on top of the keyboard can be used to move the cursor.";
            
                //Animate back ok button and text view
                [UIView animateWithDuration:0.7f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    dialogTextView.center = CGPointMake(dialogTextView.center.x, [self deviceHasThreePointFiveInchScreen] ? darkView.center.y - 115.0f : darkView.center.y - 100.0f);
                    okButton.center = CGPointMake(okButton.center.x, [self deviceHasThreePointFiveInchScreen] ? darkView.center.y - 50.0f : darkView.center.y - 20.0f);
                }completion:^(BOOL finished){
                    [keyboard animateCursorButtonsForUIGuide];
                }];
            }
            
        }];
        
    }
}

-(void)okButtonPressedForArrowKeys:(id)sender
{
    /* Show math preview view dialog */
    
    UITextView *dialogTextView;
    UILabel *okButton;
    UIView *darkView;
    for (UIView *uiGuideView in self.uiGuideViews) {
        if ([uiGuideView isKindOfClass:[UITextView class]]) {
            dialogTextView = (UITextView *)uiGuideView;
        }else if ([uiGuideView isMemberOfClass:[UILabel class]]){
            okButton = (UILabel *)uiGuideView;
        }else{
            darkView = uiGuideView;
        }
    }
    if (dialogTextView) {
        [self.textInputView resignFirstResponder];
        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            dialogTextView.center = CGPointMake(dialogTextView.center.x, -dialogTextView.frame.size.height);
            okButton.center = CGPointMake(okButton.center.x, okButton.center.y + 350.0f);
        }completion:^(BOOL finished){
            /* Remove yellow border from cursor keys on the keyboard */
            MathKeyboard *keyboard = (MathKeyboard *)self.textInputView.inputView;
            [keyboard removeCursorKeysYellowBorderForUIGuide];
            /* Remove existing textviews, reset ok button selector */
            [dialogTextView removeFromSuperview];
            [okButton removeGestureRecognizer:okButton.gestureRecognizers[0]];
            [okButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(okButtonPressedForPreviewViewDialog:)]];
            [self.uiGuideViews removeObject:dialogTextView];
            
            /* Make new textview */
            UITextView *previewDialogTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100.0f)];
            previewDialogTextView.backgroundColor = [UIColor clearColor];
            previewDialogTextView.center = CGPointMake(previewDialogTextView.center.x,self.view.frame.size.height + previewDialogTextView.frame.size.height + 50.0f);
            previewDialogTextView.textColor = [UIColor whiteColor];
            previewDialogTextView.textAlignment = NSTextAlignmentCenter;
            previewDialogTextView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
            previewDialogTextView.text = @"When you type your math, the preview view will show a live preview of the math interpretation.";
            [self.view addSubview:previewDialogTextView];
            [self.uiGuideViews addObject:previewDialogTextView];
            
            [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                darkView.frame = CGRectMake(0, self.previewView.frame.origin.y + self.previewView.frame.size.height + 60.0f, darkView.frame.size.width, darkView.frame.size.height);
            }completion:^(BOOL finished){
                [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    previewDialogTextView.center = CGPointMake(previewDialogTextView.center.x, self.view.frame.size.height - ([self deviceHasThreePointFiveInchScreen] ? previewDialogTextView.frame.size.height + 50.0f : previewDialogTextView.frame.size.height + 70.0f));
                    okButton.center = CGPointMake(okButton.center.x, self.view.frame.size.height - 70.0f);
                }completion:^(BOOL finished){
                    if (finished) {
                        [self triggerFakeTyping];
                    }
                }];
            }];
            
        }];
    }
}

-(void)okButtonPressedForPreviewViewDialog:(id)sender
{
    /* Show the goal dialog */
    
    UITextView *dialogTextView;
    UILabel *okButton;
    UIView *darkView;
    for (UIView *uiGuideView in self.uiGuideViews) {
        if ([uiGuideView isKindOfClass:[UITextView class]]) {
            dialogTextView = (UITextView *)uiGuideView;
        }else if ([uiGuideView isMemberOfClass:[UILabel class]]){
            okButton = (UILabel *)uiGuideView;
        }else{
            darkView = uiGuideView;
        }
    }
    if (dialogTextView) {
        /* Create the arrow */
        UIImageView *arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"UIGuideArrow.png"]];
        arrow.center = CGPointMake(self.view.center.x, ((self.previewView.frame.origin.y - self.currentImage.frame.origin.y)/3) + self.currentImage.frame.origin.y + self.currentImage.frame.size.height - ([self deviceHasThreePointFiveInchScreen] ? 7.0f : 0));
        arrow.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        arrow.alpha = 1;
        [self.uiGuideViews addObject:arrow];
        
        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            dialogTextView.center = CGPointMake(dialogTextView.center.x,self.view.frame.size.height + dialogTextView.frame.size.height + 250.0f);
            okButton.center = CGPointMake(okButton.center.x, okButton.center.y + 350.0f);
        }completion:^(BOOL finished){
            [okButton removeGestureRecognizer:okButton.gestureRecognizers[0]];
            [okButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(okButtonPressedForGoalDialog:)]];
            dialogTextView.text = @"Your goal is to write a mathematical description similar to the image.\nMake sure the preview view and the image above it are identical.";
                [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    dialogTextView.center = CGPointMake(dialogTextView.center.x, self.view.frame.size.height - ([self deviceHasThreePointFiveInchScreen] ? dialogTextView.frame.size.height + 60.0f : dialogTextView.frame.size.height + 80.0f));
                    okButton.center = CGPointMake(okButton.center.x, self.view.frame.size.height - 70.0f);
                }completion:^(BOOL finished){
                    if (finished) {
                        [self.view addSubview:arrow];
                        [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                            arrow.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
                        }completion:^(BOOL finished){
                            if (finished) {
                                [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                                    arrow.transform = [self deviceHasThreePointFiveInchScreen] ? CGAffineTransformMakeScale( 0.8f, 0.8f) : CGAffineTransformMakeScale( 1.0f, 1.0f);
                                }completion:nil];
                            }
                        }];
                    }
                }];
            
        }];
    }
}

-(void)okButtonPressedForGoalDialog:(id)sender
{
    /* Show the get started dialog */
    
    UITextView *dialogTextView;
    UILabel *okButton;
    UIView *darkView;
    UIImageView *arrow;
    for (UIView *uiGuideView in self.uiGuideViews) {
        if ([uiGuideView isKindOfClass:[UITextView class]]) {
            dialogTextView = (UITextView *)uiGuideView;
        }else if ([uiGuideView isMemberOfClass:[UILabel class]]){
            okButton = (UILabel *)uiGuideView;
        }else if ([uiGuideView isMemberOfClass:[UIImageView class]]){
            arrow = (UIImageView *)uiGuideView;
        }else{
            darkView = uiGuideView;
        }
    }
    if (dialogTextView) {
        /* Animte away arrow */
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            arrow.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        }completion:^(BOOL finished){
            [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                arrow.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                arrow.alpha = 0;
            }completion:^(BOOL finished){
                [arrow removeFromSuperview];
                [self.uiGuideViews removeObject:arrow];
            }];
        }];
        /* The usual animating to the next step (the last step) */
        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            dialogTextView.center = CGPointMake(dialogTextView.center.x,self.view.frame.size.height + dialogTextView.frame.size.height + 250.0f);
            okButton.center = CGPointMake(okButton.center.x, okButton.center.y + 350.0f);
        }completion:^(BOOL finished){
            [okButton removeGestureRecognizer:okButton.gestureRecognizers[0]];
            [okButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(okButtonPressedForGetStartedDialog:)]];
            dialogTextView.text = @"Now it's time to get practicing.\nLets get started!";
            [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                dialogTextView.center = CGPointMake(dialogTextView.center.x, self.view.frame.size.height - ([self deviceHasThreePointFiveInchScreen] ? dialogTextView.frame.size.height + 40.0f : dialogTextView.frame.size.height + 60.0f));
                okButton.center = CGPointMake(okButton.center.x, self.view.frame.size.height - 70.0f);
            }completion:^(BOOL finished){
                if (finished) {
                    [self.view addSubview:arrow];
                    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                        arrow.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
                    }completion:^(BOOL finished){
                        if (finished) {
                            [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                                arrow.transform = CGAffineTransformMakeScale( 1.0f, 1.0f);
                            }completion:nil];
                        }
                    }];
                }
            }];
            
        }];
    }
}

-(void)okButtonPressedForGetStartedDialog:(id)sender
{
    UITextView *dialogTextView;
    UILabel *okButton;
    UIView *darkView;
    for (UIView *uiGuideView in self.uiGuideViews) {
        if ([uiGuideView isKindOfClass:[UITextView class]]) {
            dialogTextView = (UITextView *)uiGuideView;
        }else if ([uiGuideView isMemberOfClass:[UILabel class]]){
            okButton = (UILabel *)uiGuideView;
        }else{
            darkView = uiGuideView;
        }
    }
    if (dialogTextView) {
        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            dialogTextView.center = CGPointMake(dialogTextView.center.x, -dialogTextView.frame.size.height);
            dialogTextView.alpha = 0;
            okButton.center = CGPointMake(okButton.center.x, okButton.center.y + 350.0f);
        }completion:^(BOOL finished){
            self.textInputView.text = @"";
            [self textViewDidChange:self.textInputView];
            [self.textInputView becomeFirstResponder];
            [UIView animateWithDuration:0.3f delay:0 options:0 animations:^{
                darkView.frame = CGRectMake(0, self.view.frame.size.height, darkView.frame.size.width, darkView.frame.size.height);
                darkView.alpha = 0;
            }completion:^(BOOL finished){
                if (finished) {
                    [dialogTextView removeFromSuperview];
                    [okButton removeFromSuperview];
                    [darkView removeFromSuperview];
                    [self.uiGuideViews removeAllObjects];
                    
                    MathKeyboard *keyboard = (MathKeyboard *)self.textInputView.inputView;
                    [keyboard disableUIGuideMode];
                    self.showedUIGuide = YES;
                    self.submitButton.enabled = YES;
                    
                    [self markThatUserHasAccessedTrainingMode];
                }
            }];
        }];
    }
}

-(void)triggerFakeTyping
{
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(typeNextFakeCharcter:) userInfo:nil repeats:YES];
}

-(void)typeNextFakeCharcter:(NSTimer *)timer
{
    static int iterationCount = 0;
    if (iterationCount == 19) {
        /* This should be reset if the ui guide is shown more than once. It never will, but juts in case */
        iterationCount = 0;
    }
    const NSString *fakeText = @"x^2 + 4y^2 - 36 = 0";
    self.textInputView.text = [fakeText substringWithRange:NSMakeRange(0, iterationCount + 1)];
    iterationCount++;
    if (iterationCount == [fakeText length]) {
        [timer invalidate];
        [self textViewDidChange:self.textInputView];
    }
}

-(void)markThatUserHasAccessedTrainingMode
{
    /* Mark that the user has done training mode so we stop alerting them about it */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"hasDoneTrainingMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Button actions

-(void)beginButtonTapped:(UITapGestureRecognizer *)gesture
{
    gesture.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.introView.center = CGPointMake(self.introView.center.x, self.introView.center.y - self.view.frame.size.height);
        self.beginButton.center = CGPointMake(self.beginButton.center.x, self.view.frame.size.height + self.beginButton.frame.size.height * 4);
    }completion:^(BOOL finished){
        if (finished) {
            [self.introView removeFromSuperview];
            self.introView = nil;
            [self.beginButton removeFromSuperview];
            self.beginButton = nil;
            [self fetchAndAnimateInNewPic:nil];
        }
    }];
}

-(void)checkPressed:(UIButton *)button
{
    /* The user's description is checked by comparing their resulting MathML code, generated by MathJax, to the correct code
     The mathML is first generated, then checked in 'checkUserDescriptionWithMathML' where the result will also be handled.
     */
    if (!self.showedUIGuide) {
        /* UI guide going on */
        return;
    }
    
    if (![self.textInputView.text isEqualToString:@""]) {
        self.submitButton.enabled = NO;
        [self generateAndSendMathML];
    }else{
        /* no text entered */
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Empty Translation" message:@"Try translating it first!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)backButtonPressed:(UIButton *)button
{
    /* Remove self from view */
    MathKeyboard *keyboard = (MathKeyboard *)self.textInputView.inputView;
    [keyboard disableCursorKeyHorizontalAnimationForNextKeyboardDismissal];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)introBackButtonPressed:(UIButton *)button
{
    [UIView animateWithDuration:0.45f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.introBackButton.center = CGPointMake(self.introBackButton.center.x - 70.0f, self.introBackButton.center.y);
    }completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Congratulatory and Continue View

-(void)constructAndShowCongratulatoryAndContinueView
{
    /* Constructs, and animates, the 'Congratulatory view' when the 'check' button is pressed and their translation is correct. The user can then decide if they want to continue or not */
    
    /* Setup views. View center postions are set to their beginning position in the animation where they will be animated in */
    
    self.textInputView.editable = NO;
    self.backButton.enabled = NO;
    self.submitButton.enabled = NO;
    
    if (!self.submissionViewSubviews) {
        self.submissionViewSubviews = [NSMutableArray new];
    }
    
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
    
    
    UILabel *newImageButton = [self makeBorderedButtonWithColor:[UIColor colorWithRed:0 green:38/255.0f blue:221/255.0f alpha:1.0f] andText:@"New Image"];
    newImageButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height + newImageButton.frame.size.height);
    [newImageButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(newImagePressed:)]];
    [self.submissionViewSubviews addObject:newImageButton];
    [self.view addSubview:newImageButton];
    
    UILabel *mainMenuButton = [self makeBorderedButtonWithColor:[UIColor colorWithRed:0 green:38/255.0f blue:221/255.0f alpha:1.0f] andText:@"Main Menu"];
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
        self.previewView.layer.shadowOpacity = 0;
        
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
                [self fetchAndAnimateInNewPic:nil];
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

#pragma mark Image Fetch

-(void)fetchAndAnimateInNewPic:(id)sender
{
    [self resetSubviewsForNewImage];
    [self selectNewImage];
    
    UIImageView *image = self.currentImage;
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
            CGAffineTransform imageTransform = [self scaleTransformForTaskImage:image];
            
            /* animate image to the top */
            [UIView animateWithDuration:0.9f delay:0.2f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                image.transform = imageTransform;
                image.center = CGPointMake(image.center.x, ([self deviceHasThreePointFiveInchScreen] ? kImageCenterYPostionForThreePointFiveInchScreen : kImageCenterYPostion));
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
                        self.navigationBarLabel.alpha = 1.0f;
                    }completion:^(BOOL finished){
                        if (finished) {
                            if (!self.showedUIGuide) {
                                [self setUpAndShowUIGuide];
                                self.showedUIGuide = YES;
                            }
                        }
                    }];
                }
            }];
        }
    }];
}

-(void)selectNewImage
{
    /* Selects a new image and sets the current image and current image id.
        The image is selected by simply incrementing the current image id by 1, and using that as the index of the image in the 'practiceImages' array. */
    
    if (self.currentImageID == ([self.practiceImageNames count]-1)) {
        self.currentImageID = -1;
    }
    self.currentImageID++;
    self.currentImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:self.practiceImageNames[self.currentImageID]]];
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

#pragma mark Helpers

-(CGAffineTransform)scaleTransformForTaskImage:(UIView *)image
{
    /* Calculate proper image scaling so the image fits properly in the main UI. Assuming any image size is possible */
    /* The max height of an image before it's too big for the ui is 100.0. If It's bigger than that, then it will be scaled smaller until it is at most 100 points in height. */
    CGAffineTransform imageTransform;
    if (image.frame.size.height > 100.0f){
        // Image is too big
        imageTransform = CGAffineTransformScale(image.transform, 100.0f/image.frame.size.height, 100.0f/image.frame.size.height);
    }else{
        // Image is an ideal size, meaning it's below the max height
        imageTransform = CGAffineTransformScale(image.transform, (self.view.frame.size.width- 50.0f)/image.frame.size.width, (self.view.frame.size.width- 50.0f)/image.frame.size.width);
        
        if ((image.frame.size.height * imageTransform.a) > 100.0f){
            // if the previous transform makes the height too big, scale it down
            imageTransform = CGAffineTransformScale(image.transform, 100.0f/image.frame.size.height, 100.0f/image.frame.size.height);
        }
    }
    
    return imageTransform;
    
}

-(CGAffineTransform)scaleTransformForTaskImageThatTheUserScaledViaThePinchGesture:(UIView *)image
{
    /* Same as the above method, except scales are based of the images current transform. Basicly 'CGAffineTransformMakeScale' instead of 'CGAffineTransformScale' */
    
    CGAffineTransform imageTransform;
    if (image.frame.size.height > 100.0f){
        // Image is too big
        imageTransform = CGAffineTransformMakeScale(100.0f/image.frame.size.height, 100.0f/image.frame.size.height);
    }else{
        // Image is an ideal size, meaning it's below the max height
        imageTransform = CGAffineTransformMakeScale((self.view.frame.size.width- 50.0f)/image.frame.size.width, (self.view.frame.size.width- 50.0f)/image.frame.size.width);
        
        if ((image.frame.size.height * imageTransform.a) > 100.0f){
            // if the previous transform makes the height too big, scale it down
            imageTransform = CGAffineTransformMakeScale(100.0f/image.frame.size.height, 100.0f/image.frame.size.height);
        }
    }
    
    return imageTransform;
    
}

-(BOOL)deviceHasThreePointFiveInchScreen
{
    return !([UIScreen mainScreen].bounds.size.height == 568.0);
}

-(UILabel *)makeBorderedButtonWithColor:(UIColor *)color andText:(NSString *)text
{
    /* Makes a general rectangular colored UILabel that is used as a button */
    UILabel *button = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45.0f)];
    button.backgroundColor = color;
    button.textColor = [UIColor whiteColor];
    button.textAlignment = NSTextAlignmentCenter;
    button.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    button.text = text;
    button.userInteractionEnabled = YES;
    return button;
}

-(void)handleHelpButtonPressed:(NSNotification *)notification
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
    
    /* iOS 8 inserts % symbols for some ASCII characters, so the strings must be slightly different for the webview
     * to accept and correctly parse it
     */
    NSString *version = [[UIDevice currentDevice]systemVersion];
    if ([version hasPrefix:@"7"]) {
        [self.previewView stringByEvaluatingJavaScriptFromString:@"MathJax.Hub.Queue( function f() {var jax = MathJax.Hub.getAllJax(); if(jax.length = 1){var thing = jax[0].root.toMathML(\"\"); thing = thing.replace(/\\//g, \".\"); thing = thing.replace(\":\", \".\"); thing = thing.replace(/\\#/g, \".\"); window.location = \"fakeLocation://\".concat(thing);}})"];
    }else{
        [self.previewView stringByEvaluatingJavaScriptFromString:@"MathJax.Hub.Queue( function f() {var jax = MathJax.Hub.getAllJax(); if(jax.length = 1){var thing = jax[0].root.toMathML(\"\"); thing = thing.replace(/\\//g, \".\"); thing = thing.replace(\":\", \".\"); thing = thing.replace(/\\#/g, \".\"); window.location = \"fakeLocation:/\".concat(thing);}})"];
    }
    
    //NSTimer *loadingTimer = [NSTimer  scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(mathMLStillLoadingAfterOneSecond:) userInfo:nil repeats:NO];
    //self.mathJaxLoadingTimer = loadingTimer;
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* url = request.URL;
    
    /* The 2nd 'if' condition below is needed because iOS 8 replaces some ASCII characters with percent symbols.
     * This makes the URL parts indistiguishable, with the 'host' or 'base'
     */
    if ([url.host hasPrefix:@"<math"] || [url.absoluteString hasPrefix:@"fakelocation:/%3Cmath"] ) {
        /* This address is not legit, and is instead mathml code passed in from the 'generateMathML' method*/
        NSString *mathml;
        /* iOS 8 replaces some ASCII characters with percent symbols. They need to be replaced,
         * and the host needs to be identified manually by substring'ing it
         */
         NSString *version = [[UIDevice currentDevice]systemVersion];
        if (![version hasPrefix:@"7"]) {
            NSMutableString *urlString = [[NSMutableString alloc]initWithString:[url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
            NSString *hostString = [urlString substringWithRange:NSMakeRange(14, [urlString length]-14)];
            mathml = [hostString stringByReplacingOccurrencesOfString:@" " withString:@""];
        }else{
            mathml = [url.host stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        
        mathml = [mathml stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [self checkUserDescriptionWithMathML:mathml];
        
        return NO;
    }
    return YES;
}

-(void)checkUserDescriptionWithMathML:(NSString *)mathml
{
    
    [self.mathJaxLoadingTimer invalidate];
    self.submitButton.enabled = YES;
    /* Deal with the 'long loading views', if they've been added to the previewView */
    if ([self.previewView.subviews count] > 1) {
        UIView *indicator = self.longLoadingTimeViews[0];
        [indicator removeFromSuperview];
    }
    
    NSArray *acceptableMathmlTranslations = self.practiceImagesCorrectMathMLTraslations[self.currentImageID];
    for (NSString *correctmathml in acceptableMathmlTranslations) {
        if ([mathml isEqualToString:correctmathml]) {
            [self constructAndShowCongratulatoryAndContinueView];
            return;
        }
    }
    /* If the mathml doesn't match any acceptable mathml... */
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Incorrect Description" message:[NSString stringWithFormat: @"Your description does not seem to produce a similar math image. Here's a good possible ASCIIMath translation:\n\n%@", self.practiceImagesCorrectASCIIMathTraslations[self.currentImageID]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    
}

-(void)mathMLStillLoadingAfterOneSecond:(NSTimer *)timer
{
    /*Triggered when mathjax has not returned any results after one second */
    if (!self.longLoadingTimeViews) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.frame = CGRectMake(0, 0, 50.0f, 50.0f);
        activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.previewView.frame.size.height/2);
        self.longLoadingTimeViews = @[activityIndicator];
    }
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)self.longLoadingTimeViews[0];
    [self.previewView addSubview:indicator];
    if ([indicator isKindOfClass:[UIActivityIndicatorView class]]) {
        [indicator startAnimating];
    }
}


@end
