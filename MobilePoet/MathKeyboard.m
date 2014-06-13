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
const CGFloat kNormalButtonWidth = 30.f - 7.0f;
const CGFloat kNormalButtonHeight = 38.f;
const CGFloat kNormalButtonSpacing = 7.5f;
const CGFloat kBigButtonWidth = kNormalButtonWidth + 3.5f;

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
            _buttonCharcters = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"+", @"-", @"*", @"/", @"=", @"\u2260", @"<", @">", @"\u2264", @"\u2265", @"\u00B1", @".", @"^", @"\u00B0", @"%", @"\u03C0", @"\u221E", @"!", @"\u221A", @"\u221B", @"(", @")", @"[", @"]", @"x\u2044y", @"x\u207f"];
            _operationButtonCharcters = @[@"\u221A", @"\u221B"];
            _buttonValues = @{@"0" : @"0", @"1" : @"1", @"2" : @"2", @"3" : @"3", @"4" : @"4", @"5" : @"5", @"6" : @"6", @"7" : @"7", @"8" : @"8", @"9" : @"9", @"+" : @"+", @"-" : @"-", @"*" : @"*", @"/" : @"/", @"=" : @"=", @"." : @".", @"(" : @"(", @")" : @")", @"[" : @"[", @"]" : @"]", @"<" : @"<", @">" : @">", @"\u2264" : @"<=", @"\u2265" : @">=",@"^" : @"^",  @"\u00B0" : @"degree", @"\u2260" : @"!=", @"\u221A" : @"sqrt()", @"\u221B" : @"sqrt^3()", @"%" : @"%", @"\u03C0" : @"pi", @"!" : @"!", @"x\u2044y" : @" / ", @"\u221E" : @"infty", @"x\u207f" : @" ^ ", @"\u00B1" : @"+-", @"space" : @" ", @"return" : @"\n"
                              ,@"Q" : @"q", @"W" : @"w", @"E" : @"e", @"R" : @"r", @"T" : @"t", @"Y" : @"y", @"U" : @"u", @"I" : @"i", @"O" : @"o", @"P" : @"p", @"A" : @"a", @"S" : @"s", @"D" : @"d", @"F" : @"f", @"G" : @"g", @"H" : @"h", @"J" : @"j", @"K" : @"k", @"L" : @"l", @"Z" : @"z", @"X" : @"x", @"C" : @"c", @"V" : @"v", @"B" : @"b", @"N" : @"n", @"M" : @"m"};
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
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, kPortaitKeyboardHeight - 50.0f);
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * 3.0f, self.frame.size.height - kNormalButtonHeight * 2.0f);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor grayColor];
    [self addSubview:self.scrollView];
    self.backgroundColor = [UIColor grayColor];
    
    /* Row 1 */
    for (int i = 0; i<10; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithFrame:CGRectMake(11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), 10.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:self.buttonCharcters[i] forState:UIControlStateNormal];
        button.layer.cornerRadius = 3.0f;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.scrollView addSubview:button];
    }
    
    /* Row 2 */
    for (int i = 0; i<10; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithFrame:CGRectMake(11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + 10.0f + 10.0f + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 2.0f;
        [button setTitle:self.buttonCharcters[10+i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.scrollView addSubview:button];
    }
    
    /* Row 3 */
    for (int i = 0; i<10; i++) {
        NSString *currentKeyCharcter = self.buttonCharcters[20 + i];
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithKeyType:([self.operationButtonCharcters containsObject:currentKeyCharcter] ? MathKeyboardKeyTypeOperation : MathKeyboardKeyTypeSymbol) andFrame: CGRectMake(11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + kNormalButtonHeight + 10.0f + 10.0f + 10.0f + 5.0f + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 2.0f;
        [button setTitle:currentKeyCharcter forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.scrollView addSubview:button];
    }
    
    /* Big buttons */
    /************************************************
    for (int i = 0; i<10; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(5.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + kNormalButtonHeight + kNormalButtonHeight + 10.0f + 10.0f + 10.0f + 10.0f, kBigButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor redColor];
        button.layer.cornerRadius = 2.0f;
        if ((30 + i) < [self.buttonCharcters count]) {
            [button setTitle:self.buttonCharcters[30+i] forState:UIControlStateNormal];
        }else
            [button setTitle:@"sin" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self addSubview:button];
    }
     ************************************************/
    
    /* Row 4 */
    for (int i = 0; i<10; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithFrame:CGRectMake(11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + kNormalButtonHeight + kNormalButtonHeight + 10.0f + 10.0f + 10.0f + 10.0f + 5.0f + 5.0f + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];

        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 2.0f;
        if ((30 + i) < [self.buttonCharcters count]) {
            [button setTitle:self.buttonCharcters[30+i] forState:UIControlStateNormal];
        }else
            [button setTitle:@"sin" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        /* Custom 4th row setup */
        if (i == 0) {
            button.titleLabel.font = [UIFont systemFontOfSize:12.0f];
            [button setTitle:@"abc" forState:UIControlStateNormal];
            button.backgroundColor = [UIColor lightGrayColor];
        }else if (i == 1) {
            /* help button */
            button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, (button.frame.size.width * 2) + kNormalButtonSpacing, button.frame.size.height);
            [button setTitle:@"help" forState:UIControlStateNormal];
            i = 2;
        }else if (i == 3) {
            /* space button */
            button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, (button.frame.size.width * 4) + (kNormalButtonSpacing * 3), button.frame.size.height);
            [button setTitle:@"space" forState:UIControlStateNormal];
            i = 6;
        }else if (i == 8) {
            /* return key */
            button.frame = CGRectMake(button.frame.origin.x - kBigButtonWidth/2, button.frame.origin.y, (button.frame.size.width * 2) + (kNormalButtonSpacing * 2), button.frame.size.height);
            [button setTitle:@"return" forState:UIControlStateNormal];
            i=9;
        }else if(i == 7){
            /* skip key */
            continue;
        }
        [self.buttons addObject:button];
        [self addSubview:button];
    }
    
    /***** Keyboard 2 *****/
    
    /* Row 1 */
    NSArray *test = @[@"Q", @"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P", @"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L", @"Z", @"X", @"C", @"V", @"B", @"N", @"M"];
    for (int i = 0; i<10; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithFrame:CGRectMake(self.frame.size.width + 11.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), 10.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:test[i] forState:UIControlStateNormal];
        button.layer.cornerRadius = 3.0f;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.scrollView addSubview:button];
    }
    /* Row 2 */
    for (int i = 0; i<9; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithFrame:CGRectMake(self.frame.size.width + 24.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + 10.0f + 10.0f + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 2.0f;
        [button setTitle:test[10+i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.scrollView addSubview:button];
    }
    /* Row 3 */
    for (int i = 1; i<8; i++) {
        MathKeyboardKey *button = [[MathKeyboardKey alloc]initWithFrame: CGRectMake(self.frame.size.width + 24.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + kNormalButtonHeight + 10.0f + 10.0f + 10.0f + 5.0f + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 2.0f;
        [button setTitle:test[20+(i-2)] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.scrollView addSubview:button];
    }
}

-(void)animateIn
{
    /* Helps indicate you can swipe on the keyboard to get to other keys */
    self.scrollView.contentOffset = CGPointMake(120.0f, 0);
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        self.scrollView.contentOffset = CGPointZero;
    }completion:^(BOOL finished){}];
}

-(void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if (!self.alreadyShowedAnimation) {
        self.alreadyShowedAnimation = YES;
        [self animateIn];
    }
}

#pragma mark - Action

-(void)buttonTapped:(MathKeyboardKey *)button
{
    [self.textView insertText:[self.buttonValues objectForKey:button.titleLabel.text]];
    if (button.type == MathKeyboardKeyTypeOperation) {
        self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location - 1, 0);
    }
    NSLog(@"%@ - %@", button.titleLabel.text, button.type == 0 ? @"Symbol" : @"Operation");
    //[self changeSelectedRangeForSymbol:button.titleLabel.text];
}

-(void)changeSelectedRangeForSymbol:(NSString *)symbol
{
    /* Probably will scrap this */
    
}

#pragma mark ScrollView Delegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.scrollView.contentOffset.x < self.frame.size.width/2) {
        /* Custom scroll animation (the default is to slow) */
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.contentOffset = CGPointMake(0, 0);
        }completion:^(BOOL finished){}];
    }else{
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
        }completion:^(BOOL finished){}];
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    *targetContentOffset = self.scrollView.contentOffset;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%f", scrollView.contentOffset.x);
}

@end
