//
//  MathKeyboard.m
//  MobilePoet
//
//  Created by Joseph Maag on 5/20/14.
//  
//

#import "MathKeyboard.h"
#import "MathKeyboardKey.h"

const CGFloat kPortaitKeyboardHeight = 216.0f;
const CGFloat kNormalButtonWidth = 30.f - 5.0f;
const CGFloat kNormalButtonHeight = 36.f;
const CGFloat kNormalButtonSpacing = 7.5f - 2.0f;
const CGFloat kBigButtonWidth = kNormalButtonWidth + 22.0f;

@interface MathKeyboard() <UIScrollViewDelegate>
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *buttonCharcters;
/* all characters on the keyboard */
@property (strong, nonatomic) NSArray *operationButtonCharcters;
/* only operation-type charcters (Have MathKeyboardKeyType values of MathKeyboardKeyTypeOperation) */
@property (strong, nonatomic) NSDictionary *buttonValues;
/* all asciimath values of each character */
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
            _buttonCharcters = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"+", @"-", @"*", @"/", @"=", @"\u2260", @"<", @">", @"\u2264", @"\u2265", @"(", @")", @"[", @"]", @".", @"^", @"\u00B1", @"\u00B0", @"%", @"\u03C0", @"\u221E", @"!", @"\u221A", @"\u221B", @"x\u2044y", @"x\u207f", @"logx", @"lnx", @"sinx", @"cosx", @"tanx", @"sin.x", @"cos.x", @"tan.x"];
            _operationButtonCharcters = @[@"\u221A", @"\u221B", @"x\u2044y", @"x\u207f", @"sinx", @"cosx", @"tanx"];
            _buttonValues = @{@"0" : @"0", @"1" : @"1", @"2" : @"2", @"3" : @"3", @"4" : @"4", @"5" : @"5", @"6" : @"6", @"7" : @"7", @"8" : @"8", @"9" : @"9", @"+" : @"+", @"-" : @"-", @"*" : @"*", @"/" : @"/", @"=" : @"=", @"." : @".", @"(" : @"(", @")" : @")", @"[" : @"[", @"]" : @"]", @"<" : @"<", @">" : @">", @"\u2264" : @"<=", @"\u2265" : @">=",@"^" : @"^",  @"\u00B0" : @"degree", @"\u2260" : @"!=", @"\u221A" : @"sqrt() ", @"\u221B" : @"sqrt^3() ", @"%" : @"%", @"\u03C0" : @"pi", @"!" : @"!", @"x\u2044y" : @"()/() ", @"\u221E" : @"infty", @"x\u207f" : @"()^() ", @"\u00B1" : @"+-", @"space" : @" ", @"return" : @"\n", @"sinx" : @"sin() ", @"cosx" : @"cos() ", @"tanx" : @"tan() "};
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
    /* This is pretty messy, but it's just for testing the button layout. It will be improved once keyboard specifications are solidified over time */
    
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
    _pageControl.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height - 54.0f);
    _pageControl.numberOfPages = 3;
    _pageControl.currentPage = 1;
    
    self.backgroundColor = [UIColor lightGrayColor];
    
    int row = 1;
    
    /*** Keyboard Section 1 (Alphabet) View Setup ***/
    
    /* Row 1 */
    NSArray *test = @[@"Q", @"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P", @"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L", @"Z", @"X", @"C", @"V", @"B", @"N", @"M"];
    for (int i = 0; i<10; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithFrame:CGRectMake(11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), (kNormalButtonHeight * (row - 1)) + (row * 12.0f) + ((row-1) * 5.0f), kNormalButtonWidth, kNormalButtonHeight)];
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
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithFrame:CGRectMake(24.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), (kNormalButtonHeight * (row - 1)) + (row * 12.0f) + ((row-1) * 5.0f), kNormalButtonWidth, kNormalButtonHeight)];
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
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithFrame: CGRectMake(24.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), (kNormalButtonHeight * (row - 1)) + (row * 12.0f) + ((row-1) * 5.0f), kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 4.0f;
        [button setTitle:test[20+(i-2)] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.scrollView addSubview:button];
    }

    
    /*** Keyboard Section 2 (Numbers and symbols) View Setup ***/
    
    /* Row 1 */
    row = 1;
    for (int i = 0; i<10; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:MathKeyboardKeyTypeAlphanumeric andFrame:CGRectMake(self.frame.size.width + 11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), (row * 12.0f) + ((row-1) * 5.0f), kNormalButtonWidth, kNormalButtonHeight)];
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
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:MathKeyboardKeyTypeSymbol andFrame:CGRectMake(self.frame.size.width + 11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + (row * 12.0f) + ((row-1) * 5.0f), kNormalButtonWidth, kNormalButtonHeight)];
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
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:MathKeyboardKeyTypeSymbol andFrame:CGRectMake(self.frame.size.width + 11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + kNormalButtonHeight + (row * 12.0f) + ((row-1) * 5.0f), kNormalButtonWidth, kNormalButtonHeight)];
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
    for (int i = 0; i<15; i++) {
        if (30 + i < [self.buttonCharcters count]) {
            if (i < 8) {
                /* Row 1 */
                NSString *currentKeyCharcter = self.buttonCharcters[30 + i];
                MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:([self.operationButtonCharcters containsObject:currentKeyCharcter] ? MathKeyboardKeyTypeOperation : MathKeyboardKeyTypeSymbol)
                andFrame: CGRectMake((self.frame.size.width * 2) + 11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i),(row * 12.0f), kNormalButtonWidth, kNormalButtonHeight)];
                //adjust button position so the row is centered horizontally
                button.center = CGPointMake(button.center.x + kNormalButtonWidth, button.center.y);
                button.backgroundColor = [UIColor whiteColor];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                button.layer.cornerRadius = 4.0f;
                [button setTitle:currentKeyCharcter forState:UIControlStateNormal];
                if ([button.titleLabel.text isEqualToString:@"logx"]) {
                    //The string 'logn' is a bit longer than the other charcters, so make the key a little bigger
                    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width + 12.0f, button.frame.size.height);
                }else if (i == 7){
                    button.frame = CGRectMake(button.frame.origin.x + 12.0f, button.frame.origin.y, button.frame.size.width, button.frame.size.height);
                }
                [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [self.buttons addObject:button];
                [self.scrollView addSubview:button];

            }else{
                /* Row 2 */
                NSString *currentKeyCharcter = self.buttonCharcters[30 + i];
                MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:([self.operationButtonCharcters containsObject:currentKeyCharcter] ? MathKeyboardKeyTypeOperation : MathKeyboardKeyTypeSymbol) andFrame: CGRectMake((self.frame.size.width * 2) + 5.0f + ((kBigButtonWidth+kNormalButtonSpacing)*(i-8)), kNormalButtonHeight + (2 * 12.0f) + 5.0f, kBigButtonWidth, kNormalButtonHeight)];
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
            [button setTitle:@"return" forState:UIControlStateNormal];
        }else if (i == 8){
            /* backspace */
            button.frame = CGRectMake(button.frame.origin.x + kNormalButtonSpacing, button.frame.origin.y, button.frame.size.width + 10.0f, button.frame.size.height);
            [button setTitle:@"backspace" forState:UIControlStateNormal];
            button.type = MathKeyboardKeyTypeOperation;
        }else{
            continue;
        }
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self addSubview:button];
    }
        [self addSubview:_pageControl];
    
    
    /* Add cursor buttons in the inputAccessoryView */
    _cursorControlView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
    _cursorControlView.backgroundColor = [UIColor clearColor];
    
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30.0f, 33.0f)];
    leftButton.backgroundColor = [UIColor lightGrayColor];
    leftButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:25.0f];
    [leftButton setTitle:@"<" forState:UIControlStateNormal];
    leftButton.layer.cornerRadius = 4.0f;
    leftButton.layer.borderWidth = 3.0f;
    leftButton.layer.borderColor = ([UIColor lightGrayColor].CGColor);
    [leftButton addTarget:self action:@selector(leftCursorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _leftCursorButton = leftButton;
    [_cursorControlView addSubview:_leftCursorButton];
    
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(_cursorControlView.frame.size.width - 30.0f, 0, 30.0f, 33.0f)];
    rightButton.backgroundColor = [UIColor lightGrayColor];
    rightButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:25.0f];
    [rightButton setTitle:@">" forState:UIControlStateNormal];
    rightButton.layer.cornerRadius = 3.0f;
    [rightButton addTarget:self action:@selector(rightCursorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _rightCursorButton = rightButton;
    [_cursorControlView addSubview:_rightCursorButton];
    self.textView.inputAccessoryView = _cursorControlView;

   
}

-(void)animateIn
{
    /* Helps indicate you can swipe on the keyboard to get to other keys */
    self.scrollView.contentOffset = CGPointMake(self.frame.size.width + 120.0f, 0);
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        self.scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
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
    /* Test if the key is the backspace key */
    if ([button.titleLabel.text isEqualToString:@"backspace"] && (self.textView.selectedRange.length == 0)){
        self.textView.text = self.textView.text.length > 0 ? [self.textView.text substringWithRange:NSMakeRange(0, self.textView.text.length -1)] : @"";
        return;
    }
    /* Backspace was not pressed... */
    if (button.type == MathKeyboardKeyTypeAlphanumeric) {
        [self.textView insertText:[button.titleLabel.text lowercaseString]];
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
    if ([symbol isEqualToString:@"x\u2044y"] || [symbol isEqualToString: @"x\u207f"]) {
        // Fraction or exponent - x/y or x^n
        self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location - 5, 0);
    }else
        self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location - 2, 0);
}

#pragma mark Guidance Mode

-(void)enableGuidanceModeForOperation:(NSString *)operationString
{
    /* if the operation starts with "()", than the operation is guranteed to have another pair of "()" (otherwise the operation would have just one pair of parenthesis at the beginning, which makes no sense ). By identifying this, we can adjust guidance mode to guide the user through 1 or 2 sets of parenthesis. This result is stored in 'inOperationGuidanceMode'  */
    
    self.inOperationGuidanceMode = [self.buttonValues[operationString] hasPrefix:@"()"] ? 2 : 1;
    [self.textView.textStorage addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:1.0f green:256/255.0f blue:0 alpha:0.5f] range:NSMakeRange(self.textView.selectedRange.location-1, 2)];
    
    [UIView animateWithDuration:0.5f animations:^{
        [self.leftCursorButton setTitleColor:[UIColor colorWithRed:0 green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.leftCursorButton setTitleColor:[UIColor colorWithRed:95/255.0f green:117/255.0f blue:158/255.0f alpha:1.0f] forState:UIControlStateDisabled];
        [self.rightCursorButton setTitleColor:[UIColor colorWithRed:0 green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
    }completion:^(BOOL finished){}];
}

-(void)guidanceModeButtonPressed:(UIButton *)button
{
    static int guidanceModeValue = 0;
    /* 'guidanceModeValue value keeps track of where the cursor is in the existing positions it can go to in guidance mode. Most buttons allow 3 locations: in the first set of parenthsis, the second pair of paremthesis, and outside the math function. First value is 0, second is 1, and the last is 2 */
    /* Using the 'inOperationGuidanceMode value, we can move the guidance mode up to the last 'step' if there is only on e pair of parenthesis */
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
    
    [UIView animateWithDuration:0.5f animations:^{
        [self.leftCursorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rightCursorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }completion:^(BOOL finished){
        if (finished) {}
    }];
}

#pragma mark ScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = (int)(self.scrollView.contentOffset.x/self.scrollView.frame.size.width + 0.5);
}

@end
