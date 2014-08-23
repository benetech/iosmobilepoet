//
//  TaskViewController.h
//  MobilePoet
//
//  Created by Joseph Maag on 5/21/14.
//
//

#import <UIKit/UIKit.h>

@interface TaskViewController : UIViewController
-(void)setTask:(UIImageView *)image;
-(void)enableGuidanceMode;
/* Guidance mode occurs when a 'MathKeyboardKeyTypeOperation' type key is pressed on the MathKeyboard.
 * These keys are like functions and require input (such as the square root key - sqrt(input)).
 * When guidance mode occurs, a yellow highlight is shown inside the parenthesis of the 'MathKeyboardKeyTypeOperation' value
 * The cursor arrow keys on the MathKeyboard are restricted to exiting the "function". When the user moves the cursor out of the 
 * "functions" parenthesis, guidance mode ends, removing the highlight and allowing the arrow keys to freely move the cursor again
 */
-(void)disableGuidanceMode;
-(void)handleHelpButtonPressed;
/* Presents helpViewController */
@end
