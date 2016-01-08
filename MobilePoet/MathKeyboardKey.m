//
//  MathKeyboardKey.m
//  MobilePoet
//
//  Created by Joseph Maag on 6/10/14.
//
//

#import "MathKeyboardKey.h"

const CGFloat kNormalButtonWidth;
const CGFloat kBigButtonWidth;

@interface MathKeyboardKey()
@end

@implementation MathKeyboardKey

-(instancetype)initWithKeyType:(MathKeyboardKeyType)type andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        if (frame.size.width <= kNormalButtonWidth) {
            [self setBackgroundImage:[UIImage imageNamed:@"selectedNormalSizeKeyBackground.png"] forState:UIControlStateHighlighted];
        }else{
            [self setBackgroundImage:[UIImage imageNamed:@"selectedBigSizeKeyBackground.png"] forState:UIControlStateHighlighted];
        }
        self.layer.cornerRadius = 4.0f;
        self.backgroundColor = [UIColor whiteColor];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = MathKeyboardKeyTypeSymbol;
        if (frame.size.width <= kNormalButtonWidth) {
            [self setBackgroundImage:[UIImage imageNamed:@"selectedNormalSizeKeyBackground.png"] forState:UIControlStateHighlighted];
        }else{
            [self setBackgroundImage:[UIImage imageNamed:@"selectedBigSizeKeyBackground.png"] forState:UIControlStateHighlighted];
        }
        self.layer.cornerRadius = 4.0f;
        self.backgroundColor = [UIColor whiteColor];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (frame.size.width <= kNormalButtonWidth) {
        [self setBackgroundImage:[UIImage imageNamed:@"selectedNormalSizeKeyBackground.png"] forState:UIControlStateHighlighted];
    }else if (frame.size.width > 100.0f){
        /* Space key */
        [self setBackgroundImage:[UIImage imageNamed:@"selectedSpaceKeyBackground.png"] forState:UIControlStateHighlighted];
    }
    else{
        [self setBackgroundImage:[UIImage imageNamed:@"selectedBigSizeKeyBackground.png"] forState:UIControlStateHighlighted];
    }
    
}

@end
