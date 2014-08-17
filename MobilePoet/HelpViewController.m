//
//  HelpViewController.m
//  MobilePoet
//
//  Created by Joseph Maag on 8/17/14.
//
//

#import "HelpViewController.h"
#import "TaskViewController.h"

@interface HelpViewController ()
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *backButton;
@property (nonatomic) BOOL presentedAsModalView;
/* Modal view meaning the help button on the keyboard was pressed and this view controller's view will pop up */
@end

@implementation HelpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.backButton];
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
        _textView.userInteractionEnabled = YES;
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.attributedText = [self constructTextViewText];
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
        _titleLabel.text = @"Help";
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

-(NSAttributedString *)constructTextViewText
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:@""];
    /* Create the text by appending Q&As it */
    [text appendAttributedString:[self makeAttributedQuestion:@"Example Question?" andAnswer:@"An example of an answer. This one is pretty short."]];
    [text appendAttributedString:[self makeAttributedQuestion:@"Is this another question example?" andAnswer:@"Yes. Yes it is. This is another example of an answer."]];
//    [text appendAttributedString:[self makeAttributedQuestion:@"How can I add more Questions?" andAnswer:@"Go to HelpViewController in the 'Satic Views' group. You'll see where these questions where added. You can make your own by simply using the method '(NSAttributedString *)makeAttributedQuestion:(NSString *)question andAnswer:(NSString *)answer'. That formats your Q and A nicely so you can simply append the formatted string to the textview text."]];
    [text appendAttributedString:[self makeAttributedQuestion:@"Lorem ipsum dolor sit amet?" andAnswer:@"Consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Typi non habent claritatem insitam; est usus legentis in iis qui facit eorum claritatem. "]];
    [text appendAttributedString:[self makeAttributedQuestion:@"Is this scrollable?" andAnswer:@"Yes."]];
    [text appendAttributedString:[self makeAttributedQuestion:@"Lorem ipsum dolor sit amet?" andAnswer:@"Consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Typi non habent claritatem insitam; est usus legentis in iis qui facit eorum claritatem. "]];
    [text appendAttributedString:[self makeAttributedQuestion:@"Where can I access this?" andAnswer:@"From the main menu as well as wherever you are using the math keyboard via the help button."]];
    return text;
}

-(NSAttributedString *)makeAttributedQuestion:(NSString *)question andAnswer:(NSString *)answer
{
    NSMutableAttributedString *qa = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@\n%@\n\n", question, answer]];
    [qa addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir" size:14.0f] range:NSMakeRange(0, [qa length])];
    [qa addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:16.0f] range:NSMakeRange(0, [question length])];
    return qa;
}

-(void)prepareAndExecuteBackButtonAnimation
{
    if (!self.presentedAsModalView) {
        self.backButton.center = CGPointMake(self.backButton.center.x - 70.0f, self.backButton.center.y);
        [UIView animateWithDuration:0.45f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.backButton.center = CGPointMake(self.backButton.center.x + 70.0f, self.backButton.center.y);
        }completion:nil];
    }
}

#pragma mark Button Action

-(void)backButtonPressed:(id)sender
{
    if (!self.presentedAsModalView) {
        [UIView animateWithDuration:0.45f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.backButton.center = CGPointMake(self.backButton.center.x + 70.0f, self.backButton.center.y);
        }completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        TaskViewController *presentingViewController = (TaskViewController *)self.presentingViewController;
        [presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark Presentation

-(void)adjustForModalPresentation
{
    self.presentedAsModalView = YES;
    /* Remake the back button */
    [self.backButton removeFromSuperview];
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setTitle:@"Close" forState:UIControlStateNormal];
    [self.backButton sizeToFit];
    [self.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.center = CGPointMake(30.0f, 40.0f);
    self.backButton.tintColor = [UIColor colorWithRed:0 green:30/255.0f blue:168/255.0f alpha:1.0f];
    self.backButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:self.backButton];

}

@end
