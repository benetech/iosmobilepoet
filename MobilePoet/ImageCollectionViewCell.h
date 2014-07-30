//
//  ImageCollectionViewCell.h
//  MobilePoet
//
//  Created by Joseph Maag on 6/26/14.
//
//

#import <UIKit/UIKit.h>

@interface ImageCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) NSString *title;

-(void)setImage:(UIImage *)image;

@end
