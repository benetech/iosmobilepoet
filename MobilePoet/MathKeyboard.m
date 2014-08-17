//
//  MathKeyboard.m
//  MobilePoet
//
//  Created by Joseph Maag on 5/20/14.
//  
//

#import "MathKeyboard.h"
#import "MathKeyboardKey.h"
#import "TaskViewController.h"
//TaskViewController is necessary to handle the help button

const CGFloat kPortaitKeyboardHeight = 216.0f;
const CGFloat kNormalButtonWidth = 25.0f;
const CGFloat kNormalButtonHeight = 36.0f;
const CGFloat kNormalButtonSpacing = 5.5f;
const CGFloat kBigButtonWidth = kNormalButtonWidth + 22.0f;

@interface MathKeyboard() <UIScrollViewDelegate>
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *buttonCharcters;
/* all characters on the keyboard */
@property (strong, nonatomic) NSArray *operationButtonCharcters;
/* only operation-type charcters (Have MathKeyboardKeyType values of MathKeyboardKeyTypeOperation) */
@property (strong, nonatomic) NSDictionary *buttonValues;
/* all asciimath values of each character, symbol, and function */
@property (strong, nonatomic) NSMutableArray *buttons;
/* all buttons on the keyboard */
@property (nonatomic) BOOL alreadyShowedAnimation;
/* Prevents keyboard animation from occuring more than once */
@property (nonatomic) int inOperationGuidanceMode;
/* Keeps track if guidance mode in enabled. If it is and the value is not 0, than the value also represents the number of parenthesis pairs in the operation */
@property (strong, nonatomic) UIView *cursorControlView;
/* Reference to the cursor control view with the buttons as subviews */
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIButton *leftCursorButton;
@property (strong, nonatomic) UIButton *rightCursorButton;
@property (nonatomic) BOOL cursorKeyAnimationEnabled;
/* This permits the cursor keys to animate out horizontally when the keyboard is dismissed */
@property (nonatomic) BOOL capsEnabled;
/* Capital letters enabled */
@property (nonatomic) BOOL capsLockEnabled;
/* Capital letters locked on enabled */
@property (nonatomic) MathKeyboardKey *capKey;
/* Capital key reference so that the selected state can be easily adjusted. */
@property (nonatomic) BOOL uiGuideModeEnabled;
/* UI guide is a feature in training mode where some UI elements are pointed out to the user. */
@end

@implementation MathKeyboard

#pragma mark - Setup

-(instancetype)initWithTextView:(UITextView *)textView withCharacters:(NSArray *)characters
{
    self = [super init];
    if (self) {
        _textView = textView;
        _buttonCharcters = characters;
        if (!characters) {
            _buttonCharcters = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"+", @"-", @"*", @"/", @"=", @"\u2260", @"<", @">", @"\u2264", @"\u2265", @"(", @")", @"[", @"]", @"^", @"_", @"\u00B1", @"\u00B0", @"%", @".", @"\u03C0", @"\u221E", @"!", @"\u221A", @"\u221B", @" \u207f\u2044x", @"x\u207f", @"logx", @"lnx", @"sinx", @"cosx", @"tanx", @"sin\u207B\u00B9x", @"cos\u207B\u00B9x", @"tan\u207B\u00B9x", @"sin\u00B2x", @"cos\u00B2x", @"tan\u00B2x", @"cscx", @"secx", @"cotx"];
            _operationButtonCharcters = @[@"\u221A", @"\u221B", @" \u207f\u2044x", @"x\u207f", @"sinx", @"cosx", @"tanx", @"sin\u207B\u00B9x", @"cos\u207B\u00B9x", @"tan\u207B\u00B9x", @"logx", @"lnx", @"cscx", @"secx", @"cotx", @"sin\u00B2x", @"cos\u00B2x", @"tan\u00B2x"];
            _buttonValues = @{@"+" : @"+", @"-" : @"-", @"*" : @"*", @"/" : @"/", @"=" : @"=", @"." : @".", @"(" : @"(", @")" : @")", @"[" : @"[", @"]" : @"]", @"<" : @"<", @">" : @">", @"\u2264" : @"<=", @"\u2265" : @">=",@"^" : @"^",  @"\u00B0" : @"^circ", @"\u2260" : @"!=", @"\u221A" : @"sqrt() ", @"\u221B" : @"sqrt^3() ", @"%" : @"%", @"\u03C0" : @"pi", @"!" : @"!", @" \u207f\u2044x" : @"()/() ", @"\u221E" : @"infty", @"x\u207f" : @"()^() ", @"\u00B1" : @"+-", @"space" : @" ", @"return" : @"\n", @"sinx" : @"sin() ", @"cosx" : @"cos() ", @"tanx" : @"tan() ", @"sin\u207B\u00B9x" : @"sin^-1() ", @"cos\u207B\u00B9x" : @"cos^-1() ", @"tan\u207B\u00B9x" : @"tan^-1() ", @"_" : @"_", @"logx" : @"log() ", @"lnx" : @"ln() ", @"cscx" : @"csc() ", @"secx" : @"sec() ", @"cotx" : @"cot() ", @"sin\u00B2x" : @"sin^2() ", @"cos\u00B2x" : @"cos^2() ", @"tan\u00B2x" : @"tan^2() "};
        }
        [self setUpKeyboard];
    }
    return self;
}

+(void)addMathKeyboardToTextView:(UITextView *)textView
{
    MathKeyboard *keyboard = [[MathKeyboard alloc]initWithTextView:textView withCharacters:nil];
    textView.inputView = keyboard;
}


-(void)setUpKeyboard
{
    /* Messy keyboard view construction */
    
    self.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - kPortaitKeyboardHeight, [[UIScreen mainScreen] bounds].size.width, kPortaitKeyboardHeight);
    _scrollView = [UIScrollView new];
    _scrollView.frame = CGRectMake(0, 0, self.frame.size.width, kPortaitKeyboardHeight - 50.0f);
    _scrollView.contentSize = CGSizeMake(self.frame.size.width * 3.0f, self.frame.size.height - kNormalButtonHeight * 2.0f);
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor lightGrayColor];
    _scrollView.pagingEnabled = YES;
    [self addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, 25.0f, 0)];
    _pageControl.center = CGPointMake(self.frame.size.width/2.0f, 9.0f);
    _pageControl.numberOfPages = 3;
    _pageControl.currentPage = 1;
    
    self.backgroundColor = [UIColor lightGrayColor];
    
    int row = 1;
    
    /*** Keyboard Section 1 (Alphabet) View Setup ***/
    
    /* Row 1 */
    NSArray *test = @[@"Q", @"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P", @"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L", @"Z", @"X", @"C", @"V", @"B", @"N", @"M"];
    for (int i = 0; i<10; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:MathKeyboardKeyTypeAlphanumeric andFrame:CGRectMake(11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), (kNormalButtonHeight * (row - 1)) + (row * 12.0f) + ((row-1) * 5.0f) + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:test[i] forState:UIControlStateNormal];
        button.layer.cornerRadius = 4.0f;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.scrollView addSubview:button];
    }
    
    /* Row 2 */
    row++;
    for (int i = 0; i<9; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:MathKeyboardKeyTypeAlphanumeric andFrame:CGRectMake(24.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), (kNormalButtonHeight * (row - 1)) + (row * 12.0f) + ((row-1) * 5.0f) + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 4.0f;
        [button setTitle:test[10+i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.scrollView addSubview:button];
    }
    
    /* Row 3 */
    row++;
    for (int i = 1; i<8; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:MathKeyboardKeyTypeAlphanumeric andFrame:CGRectMake(24.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), (kNormalButtonHeight * (row - 1)) + (row * 12.0f) + ((row-1) * 5.0f) + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 4.0f;
        [button setTitle:test[20+(i-2)] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.scrollView addSubview:button];
    }
    
    MathKeyboardKey *capitalizeKey = [[MathKeyboardKey alloc]initWithKeyType:MathKeyboardKeyTypeCapitalizeKey andFrame:CGRectMake(11.0f, (kNormalButtonHeight * (row - 1)) + (row * 12.0f) + ((row-1) * 5.0f) + 5.0f, kNormalButtonHeight, kNormalButtonHeight)];
    capitalizeKey.backgroundColor = [UIColor whiteColor];
    [capitalizeKey setBackgroundImage:[UIImage imageNamed:@"capitalizeKeyImage.png"] forState:UIControlStateNormal];
    [capitalizeKey setBackgroundImage:[UIImage imageNamed:@"capitalizeKeyHighlightedImage.png"] forState:UIControlStateSelected];
    capitalizeKey.layer.cornerRadius = 4.0f;
    [capitalizeKey addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttons addObject:capitalizeKey];
    self.capKey = capitalizeKey;
    [self.scrollView addSubview:capitalizeKey];

    
    /*** Keyboard Section 2 (Numbers and symbols) View Setup ***/
    
    /* Row 1 */
    row = 1;
    for (int i = 0; i<10; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:MathKeyboardKeyTypeAlphanumeric andFrame:CGRectMake(self.frame.size.width + 11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), (row * 17.0f) + ((row-1) * 10.0f), kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:self.buttonCharcters[i] forState:UIControlStateNormal];
        button.layer.cornerRadius = 4.0f;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.scrollView addSubview:button];
    }
    
    /* Row 2 */
    row++;
    for (int i = 0; i<10; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:MathKeyboardKeyTypeSymbol andFrame:CGRectMake(self.frame.size.width + 11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + (row * 12.0f) + ((row-1) * 5.0f) + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 4.0f;
        [button setTitle:self.buttonCharcters[10+i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.scrollView addSubview:button];
    }
    
    /* Row 3 */
    row++;
    for (int i = 0; i<10; i++) {
        NSString *currentKeyCharcter = self.buttonCharcters[20 + i];
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:MathKeyboardKeyTypeSymbol andFrame:CGRectMake(self.frame.size.width + 11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + kNormalButtonHeight + (row * 12.0f) + ((row-1) * 5.0f) + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 4.0f;
        [button setTitle:currentKeyCharcter forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.scrollView addSubview:button];
    }
    
    /*** Keyboard Section 3 (Everything else) View Setup ***/
    
    /* Row 1 */
    row = 1;
    for (int i = 0; i<21; i++) {
        if (30 + i < [self.buttonCharcters count]) {
            if (i < 9) {
                /* Row 1 */
                NSString *currentKeyCharcter = self.buttonCharcters[30 + i];
                MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:([self.operationButtonCharcters containsObject:currentKeyCharcter] ? MathKeyboardKeyTypeOperation : MathKeyboardKeyTypeSymbol)
                andFrame: CGRectMake((self.frame.size.width * 2) + ((kNormalButtonWidth+kNormalButtonSpacing)*i) - 5.0f,(row * 12.0f) + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];
                //adjust button position so the row is centered horizontally
                button.center = CGPointMake(button.center.x + kNormalButtonWidth, button.center.y);
                button.backgroundColor = [UIColor whiteColor];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                button.layer.cornerRadius = 4.0f;
                [button setTitle:currentKeyCharcter forState:UIControlStateNormal];
                if ([button.titleLabel.text isEqualToString:@"logx"]) {
                    //The string 'logn' is a bit longer than the other charcters, so make the key a little bigger
                    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width + 12.0f, button.frame.size.height);
                }else if (i == 8){
                    button.frame = CGRectMake(button.frame.origin.x + 12.0f, button.frame.origin.y, button.frame.size.width, button.frame.size.height);
                }else if ([button.titleLabel.text isEqualToString:@" \u207f\u2044x"]){
                    NSMutableAttributedString *fractionButtonText = [[NSMutableAttributedString alloc]initWithAttributedString:button.titleLabel.attributedText];
                    [fractionButtonText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(fractionButtonText.length - 1, 1)];
                    [fractionButtonText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0f] range:NSMakeRange(0, 1)];
                    button.titleLabel.attributedText = fractionButtonText;
                }
                [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [self.buttons addObject:button];
                [self.scrollView addSubview:button];

            }else if (i < 15){
                /* Row 2 */
                NSString *currentKeyCharcter = self.buttonCharcters[30 + i];
                MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:([self.operationButtonCharcters containsObject:currentKeyCharcter] ? MathKeyboardKeyTypeOperation : MathKeyboardKeyTypeSymbol) andFrame: CGRectMake((self.frame.size.width * 2) + 4.0f + ((kBigButtonWidth+kNormalButtonSpacing)*(i-9) + ([currentKeyCharcter isEqualToString:@"tan\u207B\u00B9x"] ? 2.0f : 0)), kNormalButtonHeight + (2 * 12.0f) + 5.0f + 5.0f,([currentKeyCharcter isEqualToString:@"cos\u207B\u00B9x"] ? kBigButtonWidth + 3.0f : kBigButtonWidth), kNormalButtonHeight)];
                button.backgroundColor = [UIColor whiteColor];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                button.layer.cornerRadius = 4.0f;
                [button setTitle:currentKeyCharcter forState:UIControlStateNormal];
                [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [self.buttons addObject:button];
                [self.scrollView addSubview:button];

            }else{
                 NSString *currentKeyCharcter = self.buttonCharcters[30 + i];
                MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:([self.operationButtonCharcters containsObject:currentKeyCharcter] ? MathKeyboardKeyTypeOperation : MathKeyboardKeyTypeSymbol) andFrame: CGRectMake((self.frame.size.width * 2) + 4.0f + ((kBigButtonWidth+kNormalButtonSpacing)*(i-15) + 2.0f),kNormalButtonHeight + kNormalButtonHeight + (3 * 12.0f) + ((3-1) * 5.0f) + 5.0f,kBigButtonWidth, kNormalButtonHeight)];
                button.backgroundColor = [UIColor whiteColor];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                button.layer.cornerRadius = 4.0f;
                [button setTitle:currentKeyCharcter forState:UIControlStateNormal];
                [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [self.buttons addObject:button];
                [self.scrollView addSubview:button];
            }

        }
    }
    
    /*** Bottom Row View Setup ***/
    
    row = 4;
    for (int i = 0; i<10; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:MathKeyboardKeyTypeSymbol andFrame:CGRectMake(11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + kNormalButtonHeight + kNormalButtonHeight + (row * 12.0f) + ((row-1) * 5.0f), kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 4.0f;

        if (i == 0) {
            /* help button */
            button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, (button.frame.size.width * 2.0f) + kNormalButtonSpacing, button.frame.size.height);
            [button setBackgroundColor:[UIColor colorWithRed:121/255.0f green:121/255.0f blue:121/255.0f alpha:1.0f]];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:@"help" forState:UIControlStateNormal];
            i = 1;
        }else if (i == 2) {
            /* space button */
            button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, (button.frame.size.width * 4.0f) + (kNormalButtonSpacing * 3), button.frame.size.height);
            [button setTitle:@"space" forState:UIControlStateNormal];
            i = 5;
        }else if (i == 6) {
            /* return key */
            button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, (button.frame.size.width * 2.0f) + (kNormalButtonSpacing * 2.0f), button.frame.size.height);
            [button setBackgroundColor:[UIColor colorWithRed:121/255.0f green:121/255.0f blue:121/255.0f alpha:1.0f]];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:@"return" forState:UIControlStateNormal];
        }else if (i == 8){
            /* backspace */
            button.frame = CGRectMake(button.frame.origin.x + kNormalButtonSpacing, button.frame.origin.y, button.frame.size.width + 10.0f, button.frame.size.height);
            [button setBackgroundColor:[UIColor colorWithRed:121/255.0f green:121/255.0f blue:121/255.0f alpha:1.0f]];
            [button setImage:[UIImage imageNamed:@"backspace.png"] forState:UIControlStateNormal];
            button.type = MathKeyboardKeyTypeDeleteKey;
        }else{
            continue;
        }
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self addSubview:button];
    }
        [self addSubview:_pageControl];
    
    /* Add cursor buttons in the inputAccessoryView */
    _cursorControlView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30.0f)];
    _cursorControlView.backgroundColor = [UIColor clearColor];
    
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(-5.0f, -2.0f, 35.0f, 33.0f)];
    leftButton.backgroundColor = [UIColor whiteColor];
    UIImageView *leftArrowImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"leftArrow.png"]];
    leftArrowImage.center = CGPointMake((leftButton.frame.size.width/2)+1, leftButton.frame.size.height/2);
    [leftButton addSubview:leftArrowImage];
    leftButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:25.0f];
    leftButton.layer.cornerRadius = 4.0f;
    leftButton.layer.borderColor = ([UIColor lightGrayColor].CGColor);
    leftButton.layer.borderWidth = 1.5f;
    leftButton.showsTouchWhenHighlighted = YES;
    [leftButton addTarget:self action:@selector(leftCursorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _leftCursorButton = leftButton;
    [_cursorControlView addSubview:_leftCursorButton];
    
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(_cursorControlView.frame.size.width - 30.0f, -2.0f, 35.0f, 33.0f)];
    rightButton.backgroundColor = [UIColor whiteColor];
    UIImageView *rightArrowImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"rightArrow.png"]];
    rightArrowImage.center = CGPointMake((rightButton.frame.size.width/2)-1, rightButton.frame.size.height/2);
    [rightButton addSubview:rightArrowImage];
    rightButton.layer.cornerRadius = 4.0f;
    rightButton.layer.borderColor = ([UIColor lightGrayColor].CGColor);
    rightButton.layer.borderWidth = 1.5f;
    rightButton.layer.cornerRadius = 4.0f;
    rightButton.showsTouchWhenHighlighted = YES;
    [rightButton addTarget:self action:@selector(rightCursorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _rightCursorButton = rightButton;
    [_cursorControlView addSubview:_rightCursorButton];
    self.textView.inputAccessoryView = _cursorControlView;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(animateOutCursorButtons:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resetCursorButtonPositionsAfterKeyboardIsOffScreen:) name:UIKeyboardDidHideNotification object:nil];
    
    _cursorKeyAnimationEnabled = YES;
   
}

-(void)animateIn
{
    self.leftCursorButton.center = CGPointMake(self.leftCursorButton.center.x - 50.0f, self.leftCursorButton.center.y);
    self.rightCursorButton.center = CGPointMake(self.rightCursorButton.center.x + 50.0f, self.rightCursorButton.center.y);
    
    /* Helps indicate you can swipe on the keyboard to get to other keys */
    self.scrollView.contentOffset = CGPointMake(self.frame.size.width + 120.0f, 0);
    [UIView animateWithDuration:1.0f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut  animations:^{
        self.scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
        self.leftCursorButton.center = CGPointMake(self.leftCursorButton.center.x + 50.0f, self.leftCursorButton.center.y);
        self.rightCursorButton.center = CGPointMake(self.rightCursorButton.center.x - 50.0f, self.rightCursorButton.center.y);
    }completion:^(BOOL finished){}];
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!self.alreadyShowedAnimation) {
        self.alreadyShowedAnimation = YES;
        [self animateIn];
    }
}

#pragma mark - Action

-(void)buttonTapped:(MathKeyboardKey *)button
{
    /* Button behavior is based on its type: */
    
    if (button.type == MathKeyboardKeyTypeDeleteKey){
        /* Backspace key */
        self.textView.text = self.textView.text.length > 0 ? [self.textView.text substringWithRange:NSMakeRange(0, self.textView.text.length -1)] : @"";
    }else if (button.type == MathKeyboardKeyTypeCapitalizeKey){
        /* Capitalize key */
        button.selected = !button.selected;
        /* Cap button selected == enabled */
        if (button.selected) {
            self.capsEnabled = YES;
        }else if(self.capsEnabled){
            self.capsEnabled = NO;
        }
    }else if (button.type == MathKeyboardKeyTypeAlphanumeric) {
        /* Alphanumeric copies the buttons character, and adjusts capitalization based on the 'caps' state */
        [self.textView insertText:(self.capsEnabled || self.capsLockEnabled) ? button.titleLabel.text : [button.titleLabel.text lowercaseString]];
        /* Disable caps */
        if (self.capsEnabled) {
            self.capsEnabled = NO;
            self.capKey.selected = NO;
        }
    }else if ([button.titleLabel.text isEqualToString:@"help"]){
        /* Get a reference to the parent TaskViewController */
        TaskViewController *taskViewController = (TaskViewController *)[self.textView.superview nextResponder];
        if ([taskViewController isKindOfClass:[TaskViewController class]]) {
            [taskViewController handleHelpButtonPressed];
        }else{
            //...shouldn't ever happen
        }
    }else
        [self.textView insertText:[self.buttonValues objectForKey:button.titleLabel.text]];
    
    if (button.type == MathKeyboardKeyTypeOperation) {
        /* If an operation key was pressed, adjust cursor based on the key and enable guidance mode if necessary */
        [self changeSelectedRangeforOperation:button.titleLabel.text];
        [self enableGuidanceModeForOperation:button.titleLabel.text];
    }

}

-(void)leftCursorButtonPressed:(id)sender
{
    if (!self.inOperationGuidanceMode) {
        if (self.textView.selectedRange.location != 0) {
            self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location - 1, 0);
        }
    }else{
        //In guidance mode
        [self guidanceModeButtonPressed:sender];
    }
}

-(void)rightCursorButtonPressed:(id)sender
{
    if (!self.inOperationGuidanceMode) {
        self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location + 1, 0);
    }else{
        //In guidance mode
        [self guidanceModeButtonPressed:sender];
    }
}

-(void)changeSelectedRangeforOperation:(NSString *)symbol
{
    /* Used for 'Operation' keys only */
    if ([symbol isEqualToString:@" \u207f\u2044x"] || [symbol isEqualToString: @"x\u207f"]) {
        // Fraction or exponent - x/y or x^n
        self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location - 5, 0);
    }else
        self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location - 2, 0);
}

#pragma mark Keyboard Notifications

-(void)animateOutCursorButtons:(NSNotification *)notification
{
    if (self.cursorKeyAnimationEnabled) {
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.leftCursorButton.center = CGPointMake(self.leftCursorButton.center.x - (self.leftCursorButton.frame.size.width), self.leftCursorButton.center.y);
            self.rightCursorButton.center = CGPointMake(self.rightCursorButton.center.x + (self.leftCursorButton.frame.size.width), self.rightCursorButton.center.y);
        }completion:nil];
    }else{
        self.cursorKeyAnimationEnabled = YES;
        /*  Parts of the cursor key's views hang off the side of the keyboard. Meaning their bounds exceed the bounds of the keyboard. So when the keyboard is dismissed while being pushed off a navigation stack, you can see the key hanging off the view as the nagivation controller animates it out. This prevents that by fading them out. */ 
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.leftCursorButton.alpha = 0;
            self.rightCursorButton.alpha = 0;
        }completion:^(BOOL finished){
            if (finished) {
                //self.leftCursorButton.alpha = 1.0;
                //self.rightCursorButton.alpha = 1.0;
                /* No alpha reset because the only reason the cursor key animation is ever disabled is if this keyboard's textview view is being pushed off the navigaton stack, so the keyboard instance will be freed */
            }
        }];
    }
}

-(void)resetCursorButtonPositionsAfterKeyboardIsOffScreen:(NSNotification *)notification
{
    self.leftCursorButton.center = CGPointMake(self.leftCursorButton.center.x + (self.leftCursorButton.frame.size.width), self.leftCursorButton.center.y);
    self.rightCursorButton.center = CGPointMake(self.rightCursorButton.center.x - (self.leftCursorButton.frame.size.width), self.rightCursorButton.center.y);

}

-(void)disableCursorKeyHorizontalAnimationForNextKeyboardDismissal
{
    self.cursorKeyAnimationEnabled = NO;
}

#pragma mark Guidance Mode

-(void)enableGuidanceModeForOperation:(NSString *)operationString
{
    /* if the operation starts with "()", than the operation is guranteed to have another pair of "()" (otherwise the operation would have just one pair of parenthesis at the beginning, which makes no sense). By identifying this, we can adjust guidance mode to guide the user through 1 or 2 sets of parenthesis. This result is stored in 'inOperationGuidanceMode'  */
    
    if (self.inOperationGuidanceMode) {
        /* Manage case where guidance mode is already enabled for an outer function */
        [self.textView.textStorage removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, [self.textView.text length])];
    }
    self.inOperationGuidanceMode = [self.buttonValues[operationString] hasPrefix:@"()"] ? 2 : 1;
    [self.textView.textStorage addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:1.0f green:256/255.0f blue:0 alpha:0.5f] range:NSMakeRange(self.textView.selectedRange.location-1, 2)];
    self.leftCursorButton.enabled = NO;
    
    //Swap arrow key's images
    UIImageView *leftArrowImage = self.leftCursorButton.subviews[0];
    leftArrowImage.image = [UIImage imageNamed:@"leftArrowDisabled.png"];
    UIImageView *rightArrowImage = self.rightCursorButton.subviews[0];
    rightArrowImage.image = [UIImage imageNamed:@"rightArrowHighlighted"];
    self.rightCursorButton.layer.borderColor = ([UIColor colorWithRed:0 green:0.5f blue:1.0f alpha:1.0f].CGColor);
}

-(void)guidanceModeButtonPressed:(UIButton *)button
{
    static int guidanceModeValue = 0;
    /* 'guidanceModeValue value keeps track of where the cursor is in the existing positions it can go to in guidance mode. Most buttons allow 3 locations: in the first set of parenthsis, the second pair of parenthesis, and outside the math function. First value is 0, second is 1, and the last is 2 */
    /* Using the 'inOperationGuidanceMode value, we can move the guidance mode up to the 2nd 'step' if there is only one pair of parenthesis (there are 3 max steps allowed - 1st is in the first set of parenthesis, 2nd is in the possible second pair of parenthesis, 3rd being outside the function which ends guidance mode) */
    if (guidanceModeValue == 0 && self.inOperationGuidanceMode == 1) {
        guidanceModeValue = 1;
    }
    
    if (button == self.leftCursorButton) {
        guidanceModeValue = guidanceModeValue != 0 ? guidanceModeValue-- : guidanceModeValue;
    }else{
        guidanceModeValue ++;
    }
    
    if (guidanceModeValue == 0) {
        /* step 0 */
        self.leftCursorButton.enabled = NO;
    }else if (guidanceModeValue == 1) {
        /* step 1 - remove existing highligts and add new ones */
        [self.textView.textStorage removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, [self.textView.text length])];
        [self.textView.textStorage addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:1.0f green:256/255.0f blue:0 alpha:0.5f] range:NSMakeRange(self.textView.selectedRange.location + 2, 2)];
        self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location + 3, 0);
        guidanceModeValue = 1.0f;
    }else if (guidanceModeValue == 2){
        /* step 2 - final step, no more guidance needed*/
        self.leftCursorButton.enabled = YES;
        self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location + 2, 0);
        guidanceModeValue = 0;
        [self disableGuidanceControl];
    }
}

-(void)disableGuidanceControl
{
    self.inOperationGuidanceMode = 0;
    [self.textView.textStorage removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, [self.textView.text length])];
    
    //Swap arrow key's images
    UIImageView *leftArrowImage = self.leftCursorButton.subviews[0];
    leftArrowImage.image = [UIImage imageNamed:@"leftArrow.png"];
    UIImageView *rightArrowImage = self.rightCursorButton.subviews[0];
    rightArrowImage.image = [UIImage imageNamed:@"rightArrow"];
    self.rightCursorButton.layer.borderColor = ([UIColor lightGrayColor].CGColor);
}

#pragma mark UI Guide Mode

-(void)enableUIGuideMode
{
    self.uiGuideModeEnabled = YES;
    self.userInteractionEnabled = NO;
    
    /* This view creates a yellow outline around the keyboard. I could of just used the keyboard view's 
     .layer.borderColor property, but then I can't animate it. */
    UIView *borderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    borderView.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height/2.0f);
    borderView.backgroundColor = [UIColor clearColor];
    borderView.layer.borderWidth = 5.0f;
    borderView.layer.borderColor = [UIColor yellowColor].CGColor;
    borderView.alpha = 0;
    borderView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    [self addSubview:borderView];
    

    /* Keyboard animations */
    [UIView animateWithDuration:0.6f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        borderView.alpha = 1.0f;
        borderView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.6f delay:0.3f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x - self.frame.size.width, self.scrollView.contentOffset.y);
        }completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.6f delay:0.3f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x + self.frame.size.width, self.scrollView.contentOffset.y);
                }completion:^(BOOL finished){
                    if (finished) {
                        [UIView animateWithDuration:0.6f delay:0.3f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x + self.frame.size.width, self.scrollView.contentOffset.y);
                        }completion:^(BOOL finished){
                            if (finished) {
                                [UIView animateWithDuration:0.6f delay:0.4f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x - self.frame.size.width, self.scrollView.contentOffset.y);
                                }completion:^(BOOL finished){
                                    if (finished) {
                                        self.userInteractionEnabled = YES;
                                    }
                                }];
                            }
                        }];
                    }
                }];
            }
        }];
    }];
}

-(void)disableUIGuideMode
{
    self.uiGuideModeEnabled = NO;
}

-(void)removeYellowBorderForUIGuide
{
    UIView *borderView = [self.subviews objectAtIndex:([self.subviews count]-1)];
    [UIView animateWithDuration:0.6f delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        borderView.alpha = 0;
        borderView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    }completion:^(BOOL finished){
        [borderView removeFromSuperview];
        
        /* The next step in the UI Guide is pointing out the arrow keys. So we'll highlight those. */
        [self makeYellowBorderOnArrowKeysForUIGuide];
    }];
}

-(void)makeYellowBorderOnArrowKeysForUIGuide
{
    UIView *leftArrowButtonBorderView = [[UIView alloc]initWithFrame:self.leftCursorButton.frame];
    UIView *rightArrowButtonBorderView = [[UIView alloc]initWithFrame:self.rightCursorButton.frame];
    leftArrowButtonBorderView.center = CGPointMake(self.leftCursorButton.frame.size.width/2.0f, self.leftCursorButton.frame.size.height/2.0f);
    rightArrowButtonBorderView.center = CGPointMake(self.rightCursorButton.frame.size.width/2.0f, self.rightCursorButton.frame.size.height/2.0f);
    leftArrowButtonBorderView.backgroundColor = [UIColor clearColor];
    rightArrowButtonBorderView.backgroundColor = [UIColor clearColor];
    leftArrowButtonBorderView.layer.borderWidth = 5.0f;
    rightArrowButtonBorderView.layer.borderWidth = 5.0f;
    leftArrowButtonBorderView.layer.cornerRadius = 4.0f;
    rightArrowButtonBorderView.layer.cornerRadius = 4.0f;
    leftArrowButtonBorderView.layer.borderColor = [UIColor yellowColor].CGColor;
    rightArrowButtonBorderView.layer.borderColor = [UIColor yellowColor].CGColor;
    leftArrowButtonBorderView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    rightArrowButtonBorderView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    leftArrowButtonBorderView.alpha = 0;
    rightArrowButtonBorderView.alpha = 0;
    [self.leftCursorButton addSubview:leftArrowButtonBorderView];
    [self.rightCursorButton addSubview:rightArrowButtonBorderView];
    
    [UIView animateWithDuration:0.6f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        leftArrowButtonBorderView.alpha = 1.0f;
        rightArrowButtonBorderView.alpha = 1.0f;
        leftArrowButtonBorderView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        rightArrowButtonBorderView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }completion:nil];
    
}

-(void)removeCursorKeysYellowBorderForUIGuide
{
    UIView *leftArrowButtonBorderView = [self.leftCursorButton.subviews objectAtIndex:([self.leftCursorButton.subviews count]-1)];
    UIView *rightArrowButtonBorderView = [self.rightCursorButton.subviews objectAtIndex:([self.rightCursorButton.subviews count]-1)];
    [leftArrowButtonBorderView removeFromSuperview];
    [rightArrowButtonBorderView removeFromSuperview];
}

-(void)animateCursorButtonsForUIGuide
{
    /* Arrow key animation */
    if (self.uiGuideModeEnabled) {
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.leftCursorButton.transform = CGAffineTransformMakeScale(1.4f, 1.4f);
            self.rightCursorButton.transform = CGAffineTransformMakeScale(1.4f, 1.4f);
        }completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.leftCursorButton.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                    self.rightCursorButton.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                }completion:nil];
            }
        }];
    }
}

#pragma mark ScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = (int)(self.scrollView.contentOffset.x/self.scrollView.frame.size.width + 0.5);
}

@end
