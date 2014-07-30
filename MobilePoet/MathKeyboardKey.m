//
//  MathKeyboardKey.m
//  MobilePoet
//
//  Created by Joseph Maag on 6/10/14.
//
//

#import "MathKeyboardKey.h"

@implementation MathKeyboardKey

-(instancetype)initWithKeyType:(MathKeyboardKeyType)type andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = MathKeyboardKeyTypeSymbol;
    }
    return self;
}

/* Button behavior is defined in the keyboard class */

@end
