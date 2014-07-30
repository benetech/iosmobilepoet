//
//  MathKeyboardKey.h
//  MobilePoet
//
//  Created by Joseph Maag on 6/10/14.
//
//

#import <UIKit/UIKit.h>

/*
 MathKeyboardKey types distiguish keyboard key values that behave differently in the related text input view.
 A 'MathKeyboardKeyTypeAlphanumeric' is simply any letter or number. They are non-functional, meaning they don't require an 'input'.
 A 'MathKeyboardKeyTypeSymbol' would be any key that just inserts a symbol: pi, !, ^, %, etc. Symbols are non-functional and require no input.
 A 'MathKeyboardKeyTypeOperation' key, such as square root, would require the textInputView cursor to change position to fit an a pair of parenthesis: sqrt(_cursor_). They are functional and require input.
 Contrary to the other types, 'MathKeyboardKeyTypeDeleteKey' and 'MathKeyboardKeyTypeCapitalizeKey' are for specific non-general keys.
*/
typedef NS_ENUM(NSInteger, MathKeyboardKeyType){
    MathKeyboardKeyTypeAlphanumeric,
    /* type Alphanumeric is the default value */
    MathKeyboardKeyTypeSymbol,
    MathKeyboardKeyTypeOperation,
    /* MathKeyboardKeyTypeOperation is NOT equivelent to the mathematical definition of 'operation'. In the MathKeyboardKey case, it's a sign or operation that requires asciimath parentheses and/or a change to the cursor placement (a change is the textInputView's selectedRange position) */
    MathKeyboardKeyTypeDeleteKey,
    /* Specifically for a backspace key */
    MathKeyboardKeyTypeCapitalizeKey
    /* Specifically for a capitilize key */
};

@interface MathKeyboardKey : UIButton

@property(nonatomic, assign) MathKeyboardKeyType type;

-(instancetype)initWithKeyType:(MathKeyboardKeyType)type andFrame:(CGRect)frame;

@end
