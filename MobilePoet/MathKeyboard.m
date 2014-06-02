//
//  MathKeyboard.m
//  MobilePoet
//
//  Created by Joseph Maag on 5/20/14.
//  
//

#import "MathKeyboard.h"

const CGFloat kPortaitKeyboardHeight = 216.0f;
const CGFloat kNormalButtonWidth = 30.f - 6.0f;
const CGFloat kNormalButtonHeight = 38.f;
const CGFloat kNormalButtonSpacing = 7.5f;
const CGFloat kBigButtonWidth = kNormalButtonWidth + 3.5f;

@interface MathKeyboard()
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) NSArray *buttonCharcters;
/* all characters on the keyboard */
@property (strong, nonatomic) NSDictionary *buttonValues;
/* all asciimath values of each character */
@property (strong, nonatomic) NSMutableArray *buttons;
/* all buttons on the keyboard */
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
            _buttonValues = @{@"0" : @"0", @"1" : @"1", @"2" : @"2", @"3" : @"3", @"4" : @"4", @"5" : @"5", @"6" : @"6", @"7" : @"7", @"8" : @"8", @"9" : @"9", @"+" : @"+", @"-" : @"-", @"*" : @"*", @"/" : @"/", @"=" : @"=", @"." : @".", @"(" : @"(", @")" : @")", @"[" : @"[", @"]" : @"]", @"<" : @"<", @">" : @">",@"^" : @"^",  @"\u00B0" : @"degree", @"\u2260" : @"!=", @"\u221A" : @"sqrt", @"\u221B" : @"sqrt^3()", @"%" : @"%", @"\u03C0" : @"pi", @"!" : @"!", @"x\u2044y" : @" / ", @"\u221E" : @"infty", @"x\u207f" : @" ^ ", @"\u00B1" : @"+-", @"space" : @" "};
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
    
    /* This is pretty messy, but it's just for testing the button layout. It will be improved once keyboard specifications are solidified */
    
    self.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - kPortaitKeyboardHeight, [[UIScreen mainScreen] bounds].size.width, kPortaitKeyboardHeight);
    self.backgroundColor = [UIColor grayColor];
    
    /* Row 1 */
    for (int i = 0; i<10; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(7.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), 10.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:self.buttonCharcters[i] forState:UIControlStateNormal];
        button.layer.cornerRadius = 3.0f;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self addSubview:button];
    }
    
    /* Row 2 */
    for (int i = 0; i<10; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(7.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + 10.0f + 10.0f + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 2.0f;
        [button setTitle:self.buttonCharcters[10+i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self addSubview:button];
    }
    
    /* Row 3 */
    for (int i = 0; i<10; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(7.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + kNormalButtonHeight + 10.0f + 10.0f + 10.0f + 5.0f + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 2.0f;
        [button setTitle:self.buttonCharcters[20 + i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self addSubview:button];
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
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(7.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), kNormalButtonHeight + kNormalButtonHeight + kNormalButtonHeight + 10.0f + 10.0f + 10.0f + 10.0f + 5.0f + 5.0f + 5.0f, kNormalButtonWidth, kNormalButtonHeight)];

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
    
    
    
}

#pragma mark - Action

-(void)buttonTapped:(UIButton *)button
{
    
    /* each button has it's own way of inserting its content, because the cursor placement is differnt for different math functions/symbols/etc. To determine each buttons type, I may make a UIButton subclass or catergory with a type property. */
    
    [self.textView insertText:[self.buttonValues objectForKey:button.titleLabel.text]];
    NSLog(@"%@", button.titleLabel.text);
    [self changeSelectedRangeForSymbol:button.titleLabel.text];
}

-(void)changeSelectedRangeForSymbol:(NSString *)symbol{
    /* Different math symbols require different cursor locations. */
    
}

@end
