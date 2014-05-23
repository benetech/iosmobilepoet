//
//  MathKeyboard.h
//  MobilePoet
//
//  Created by Joseph Maag on 5/20/14.
// 
//

#import <UIKit/UIKit.h>

@interface MathKeyboard : UIView

-(instancetype)initWithTextView:(UITextView *)textView withCharacters:(NSArray *)characters;
/* The keyboard will be 'textView's inputView. Each character in 'charcters' will have a button on the keyboard */

+(void)addMathKeyboardToTextView:(UITextView *)textView;
/* Creates and attaches a math keyboard to the textview without having to intialize one. */

@end
