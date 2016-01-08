//
//  CustomScrollView.m
//  MobilePoet
//
//  Created by Joseph Maag on 9/12/14.
//
//

#import "CustomScrollView.h"

@implementation CustomScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delaysContentTouches = NO;
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delaysContentTouches = NO;
    }
    
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if ([view isKindOfClass:[UIButton class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

@end
