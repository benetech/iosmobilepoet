//
//  AboutViewController.m
//  MobilePoet
//
//  Created by Joseph Maag on 8/6/14.
//
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation AboutViewController

#pragma mark Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.titleLabel];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareAndExecuteBackButtonAnimation];
}

-(UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc]initWithFrame:CGRectMake(10.0f, 110.0f, self.view.frame.size.width - 20.0f, self.view.frame.size.height - 80.0f)];
        _textView.editable = NO;
        _textView.userInteractionEnabled = NO;
        _textView.attributedText = [self makeTextViewText];
        _textView.font = [UIFont fontWithName:@"Avenir" size:14.0f];
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.text = @"Developed by The DIAGRAM Center, the MobilePoet mathematical expression description tool is an open-source tool for creating accessible descriptions of mathematical equations.\n\nWith MobilePoet, it is possible to instantaneously crowdsource the translation of mathematical images from textbooks and worksheets to accessible formats that can be voiced, converted to Nemeth braille, or incorporated into DAISY formatted books.";
        }
    return _textView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100.0f, 40.0f)];
        _titleLabel.center = CGPointMake(self.view.frame.size.width/2.0f, 80.0f);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:22.0f];
        _titleLabel.text = @"About";
    }
    return _titleLabel;
}

-(UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *backImage = [UIImage imageNamed:@"backToMenuButton.png"];
        [_backButton setBackgroundImage:backImage forState:UIControlStateNormal];
        _backButton.frame = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
        _backButton.transform = CGAffineTransformMakeScale(55.0f/_backButton.frame.size.width, 55.0f/_backButton.frame.size.width);
        [_backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _backButton.center = CGPointMake(30.0f, 40.0f);
    }
    return _backButton;
}

-(NSAttributedString *)makeTextViewText
{
    NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc]initWithString:@"Developed by The DIAGRAM Center, the MobilePoet mathematical expression description tool is an open-source tool for creating accessible descriptions of mathematical equations. With MobilePoet, it is possible to instantaneously crowdsource the translation of mathematical images from textbooks and worksheets to accessible formats that can be voiced, converted to Nemeth braille, or incorporated into DAISY formatted books."];
    [string1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir" size:14.0f] range:NSMakeRange(0, [string1 length])];
    NSMutableParagraphStyle *para1 = [NSMutableParagraphStyle new];
    [para1 setAlignment:NSTextAlignmentCenter];
    [string1 addAttribute:NSParagraphStyleAttributeName value:para1 range:NSMakeRange(0, [string1 length])];
    
    NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc]initWithString:@"\n\n\n\nFAQ\n\n"];
    [string2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:22.0f] range:NSMakeRange(4, 3)];
    [string2 addAttribute:NSParagraphStyleAttributeName value:para1 range:NSMakeRange(4, 3)];
    
    NSMutableAttributedString *stringQA1 = [[NSMutableAttributedString alloc]initWithString:@"Q:\n\n"
                                            "A:\n\n"];
    [stringQA1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:14.0f] range:NSMakeRange(0, [stringQA1 length])];
    [stringQA1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:16.0f] range:NSMakeRange(0, 2)];
    [stringQA1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:16.0f] range:NSMakeRange(4, 2)];
    
    [string1 appendAttributedString:string2];
    [string1 appendAttributedString:stringQA1];
    return string1;
}

-(void)prepareAndExecuteBackButtonAnimation
{
    self.backButton.center = CGPointMake(self.backButton.center.x - 70.0f, self.backButton.center.y);
    [UIView animateWithDuration:0.45f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backButton.center = CGPointMake(self.backButton.center.x + 70.0f, self.backButton.center.y);
    }completion:nil];
}

#pragma Button Action

-(void)backButtonPressed:(id)sender
{
    [UIView animateWithDuration:0.45f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backButton.center = CGPointMake(self.backButton.center.x + 70.0f, self.backButton.center.y);
    }completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
