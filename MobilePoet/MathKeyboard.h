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
-(void)animateIn;
-(void)disableCursorKeyHorizontalAnimationForNextKeyboardDismissal;
/* For clean animations when a keyboards super view is pushed off the navigation stack */
-(void)enableUIGuideMode;
-(void)disableUIGuideMode;

/*** Training Mode UI Introduction Guide ***/
/* UI Guide is the animated, sort of slide show, shown when the user first tries training mode.
    See TrainingModeViewController for the code that handes it. */
-(void)animateCursorButtonsForUIGuide;
/* This is used for the UI Guide in training mode. This method won't work if the keyboard is not in UI Guide mode */
-(void)removeYellowBorderForUIGuide;
/* This is used for the UI Guide in training mode. Removes the yellow border that is created when UI Guide is enabled */
-(void)removeCursorKeysYellowBorderForUIGuide;
/* This is used for the UI Guide in training mode. Removes the yellow border that is created after the yellow keyboard border is removed in 'removeYellowBorderForUIGuide' */

@end
