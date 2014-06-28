//
//  ImageCollectionViewCell.m
//  MobilePoet
//
//  Created by Joseph Maag on 6/26/14.
//
//

#import "ImageCollectionViewCell.h"

@interface ImageCollectionViewCell()
@property (strong, nonatomic) UIImageView *imageView;
@end
@implementation ImageCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_imageView];
        self.layer.shadowOpacity = 0.4f;
        self.layer.shadowRadius = 5.0f;
        self.layer.shadowOffset = CGSizeZero;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andImage: (UIImageView *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = image;
        [self addSubview:_imageView];
    }
    return self;
}

-(void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

@end
