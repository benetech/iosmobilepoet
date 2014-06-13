//
//  MathKeyboardKey.h
//  MobilePoet
//
//  Created by Joseph Maag on 6/10/14.
//
//

#import <UIKit/UIKit.h>

/*
 MathKeyboardKey types distiguish keyboard key values that behave differently in the parent text input view.
 A 'MathKeyboardKeyTypeSymbol' for example would be any key that just inserts a symbol: 1, a, pi, !, 5, etc.  Symbols can be a number, letter, or any other non-function symbol that requires no input
 A 'MathKeyboardKeyTypeOperation' key, such as square root, would require the textInputView cursor to change position to fit an a pair of parenthesis: sqrt(_cursor_).
*/
typedef NS_ENUM(NSInteger, MathKeyboardKeyType){
    MathKeyboardKeyTypeSymbol,
    /* type Symbol is the default value */
    MathKeyboardKeyTypeOperation
    /* MathKeyboardKeyTypeOperation is NOT equivelent to the mathematical definition of 'operation'. In the MathKeyboardKey case, it's a sign or operation that requires asciimath parentheses and/or a change to the cursor placement (a change is the textInputView's selectedRange position) */
};

@interface MathKeyboardKey : UIButton

@property(nonatomic, assign) MathKeyboardKeyType type;

-(instancetype)initWithKeyType:(MathKeyboardKeyType)type andFrame:(CGRect)frame;

@end
