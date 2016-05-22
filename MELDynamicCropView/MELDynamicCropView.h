//
//  MELDynamicCropView.h
//  MELDynamicCropView
//
//  Created by Mike Leveton on 5/12/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MELDynamicCropView : UIView
@property (nonatomic, strong, readonly) UIImage             *image;
@property (nonatomic, strong, readonly) UIImage             *croppedImage;
@property (nonatomic, strong, readonly) UIColor             *cropColor;
@property (nonatomic, assign, readonly) CGRect              cropFrame;
@property (nonatomic, assign, readonly) CGFloat             cropAlpha;

- (id)initWithFrame:(CGRect)frame cropFrame:(CGRect)cropFrame;

- (void)setImage:(UIImage *)image;
- (void)setCropColor:(UIColor *)cropColor;
- (void)setCropAlpha:(CGFloat)cropAlpha;
- (void)setCropFrame:(CGRect)cropFrame;

@end
