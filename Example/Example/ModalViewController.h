//
//  ModalViewController.h
//  Example
//
//  Created by Mike Leveton on 5/22/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalViewController : UIViewController
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) CGSize imageSize;

- (void)setImage:(UIImage *)image;
- (void)setImageSize:(CGSize)imageSize;
@end
