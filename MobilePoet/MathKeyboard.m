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
    self.backgroundColor = [UIColor blueColor];
    
    /* Row 1 */
    for (int i = 0; i<10; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(7.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), 10.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor redColor];
        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        button.layer.cornerRadius = 3.0f;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self addSubview:button];
    }
    
    /* Row 2 */
    for (int i = 0; i<10; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(7.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), 10.0f + kNormalButtonHeight + 10.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor redColor];
        button.layer.cornerRadius = 2.0f;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self addSubview:button];
    }
    
    /* Row 3 - Big button test */
    for (int i = 0; i<10; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(5.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), 10.0f + kNormalButtonHeight + kNormalButtonHeight + 10.0f + 10.0f, kBigButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor redColor];
        button.layer.cornerRadius = 2.0f;
        [button setTitle:@"Sin" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self addSubview:button];
    }
    
    /* Row 4 */
    for (int i = 0; i<10; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10.0f + ((kNormalButtonWidth+kNormalButtonSpacing)*i), 10.0f + kNormalButtonHeight + kNormalButtonHeight + kNormalButtonHeight + 10.0f + 10.0f + 10.0f, kNormalButtonWidth, kNormalButtonHeight)];
        button.backgroundColor = [UIColor redColor];
        button.layer.cornerRadius = 2.0f;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self addSubview:button];
    }
    
    
    //_textView.inputView = self;
}

#pragma mark - Action

-(void)buttonTapped:(UIButton *)button
{
    
    /* each button has it's own way of inserting its content, because the cursor placement is differnt for different math functions/symbols/etc. To determine each buttons type, I may make a UIButton subclass or catergory with a type property. */
    
    [self.textView insertText:button.titleLabel.text];
    NSLog(@"%@", button.titleLabel.text);
}

@end
