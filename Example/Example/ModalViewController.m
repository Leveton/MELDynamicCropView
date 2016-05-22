//
//  ModalViewController.m
//  Example
//
//  Created by Mike Leveton on 5/22/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "ModalViewController.h"

@interface ModalViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton    *button;
@end

@implementation ModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect imageFrame = [[self imageView] frame];
    imageFrame.origin.x = (CGRectGetWidth([[self view]frame]) - imageFrame.size.width)/2;
    imageFrame.origin.y = (CGRectGetHeight([[self view]frame]) - imageFrame.size.height)/2;
    imageFrame.size = _imageSize;
    [[self imageView] setFrame:imageFrame];
    
    NSLog(@"image frame x,y,width,height: %f %f %f %f", imageFrame.origin.x, imageFrame.origin.y, imageFrame.size.width, imageFrame.size.height);
    
    CGRect buttonFrame = [[self button] frame];
    buttonFrame.size.width = 100;
    buttonFrame.size.height = 100.0f;
    [[self button] setFrame:buttonFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImage:(UIImage *)image{
    _image = image;
    [[self imageView] setImage:_image];
    //[[self imageView] sizeToFit];
}

- (void)setImageSize:(CGSize)imageSize{
    _imageSize = imageSize;
}

- (UIImageView *)imageView{
    if (!_imageView){
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [[_imageView layer] setBorderColor:[UIColor blackColor].CGColor];
        [[_imageView layer] setBorderWidth:1.0f];
        [[self view] addSubview:_imageView];
        return _imageView;
    }
    return _imageView;
}

- (UIButton *)button{
    if (!_button){
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button addTarget:self action:@selector(didTap:) forControlEvents:UIControlEventTouchUpInside];
        [_button setTitle:NSLocalizedString(@"drop", nil) forState:UIControlStateNormal];
        [_button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [[self view] addSubview:_button];
        return _button;
    }
    return _button;
}

- (void)didTap:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
