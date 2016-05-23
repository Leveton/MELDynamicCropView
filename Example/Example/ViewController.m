//
//  ViewController.m
//  Example
//
//  Created by Mike Leveton on 5/22/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>

#import "ViewController.h"
#import "MELDynamicCropView.h"
#import "ModalViewController.h"

typedef enum : NSUInteger{
    kCropRight,
    kCropLeft,
    kCropPano
}CurrentCropSelection;

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) MELDynamicCropView      *cropViewLeft;
@property (nonatomic, strong) MELDynamicCropView      *cropViewRight;
@property (nonatomic, strong) MELDynamicCropView      *cropViewPano;
@property (nonatomic, strong) UIImagePickerController *photoRollController;
@property (nonatomic, strong) UIImage                 *image;
@property (nonatomic, strong) UILabel                 *photoRollLeft;
@property (nonatomic, strong) UILabel                 *photoRollRight;
@property (nonatomic, strong) UILabel                 *photoRollPano;
@property (nonatomic, strong) UILabel                 *croppedPicLabel;
@property (nonatomic, assign) CurrentCropSelection    currentSelection;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect labelFrame = [[self photoRollLeft] frame];
    [[self photoRollLeft] setFrame:labelFrame];
    
    CGRect showLabelFrame = [[self croppedPicLabel] frame];
    showLabelFrame.size.height = 60.0f;
    showLabelFrame.size.width  = CGRectGetWidth([[self view] frame]);
    showLabelFrame.origin.y    = CGRectGetHeight([[self view] frame]) - showLabelFrame.size.height;
    [[self croppedPicLabel] setFrame:showLabelFrame];
    
}

- (CGRect)cropViewLeftFrame{
    CGRect frame = CGRectZero;
    CGFloat oneFourth = CGRectGetWidth([[self view]frame])/4;
    frame.size        = CGSizeMake(oneFourth, oneFourth);
    frame.origin.y    = CGRectGetMaxY([[self photoRollLeft]frame]);
    frame.origin.x    = frame.origin.y;
    return frame;
}

- (CGRect)cropViewLeftCropperFrame{
    CGRect frame      = CGRectZero;
    CGFloat oneHalf   = CGRectGetWidth([self cropViewLeftFrame])/2;
    frame.size        = CGSizeMake(oneHalf, oneHalf);
    frame.origin.y    = (CGRectGetHeight([self cropViewLeftFrame]) - frame.size.height)/2;
    frame.origin.x    = (CGRectGetWidth([self cropViewLeftFrame]) - frame.size.width)/2;
    return frame;
}

- (CGRect)cropViewRightFrame{
    CGRect frame = CGRectZero;
    CGFloat oneFifth  = CGRectGetWidth([[self view]frame])/5;
    frame.size        = CGSizeMake(oneFifth, oneFifth);
    frame.origin.y    = CGRectGetMaxY([[self photoRollLeft]frame]);
    frame.origin.x    = CGRectGetWidth([[self view]frame]) - frame.origin.y;
    return frame;
}

- (CGRect)cropViewRightCropperFrame{
    CGRect frame = CGRectZero;
    CGFloat twoThirds = CGRectGetWidth([self cropViewRightFrame]) * 0.66f;
    frame.size        = CGSizeMake(twoThirds, twoThirds);
    frame.origin.y    = (CGRectGetHeight([self cropViewRightFrame]) - frame.size.height)/2;
    frame.origin.x    = (CGRectGetWidth([self cropViewRightFrame]) - frame.size.width)/2;
    return frame;
}

- (CGRect)cropViewPanoFrame{
    CGRect frame = CGRectZero;
    frame.size.width  = CGRectGetWidth([[self view]frame])/3;
    frame.size.height = CGRectGetHeight([[self view]frame])/5;
    frame.origin.y    = CGRectGetHeight([[self view]frame]) - CGRectGetHeight([[self croppedPicLabel]frame]);
    frame.origin.x    = (CGRectGetWidth([[self view]frame]) - frame.size.width)/2;
    return frame;
}

- (CGRect)cropViewPanoCropperFrame{
    CGRect frame = CGRectZero;
    CGFloat twoThirds = CGRectGetWidth([self cropViewLeftFrame]) * 0.66f;
    frame.size        = CGSizeMake(twoThirds, twoThirds);
    frame.origin.y    = CGRectGetHeight([self cropViewPanoFrame]) * 0.75f;
    frame.origin.x    = CGRectGetWidth([self cropViewPanoFrame]) * 0.75f;
    return frame;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getters

- (UILabel *)photoRollLeft{
    if (!_photoRollLeft){
        _photoRollLeft = [[UILabel alloc] initWithFrame:CGRectZero];
        [_photoRollLeft setText:@"Photo Roll"];
        [_photoRollLeft sizeToFit];
        [_photoRollLeft setTextAlignment:NSTextAlignmentCenter];
        [_photoRollLeft setUserInteractionEnabled:YES];
        [[_photoRollLeft layer] setZPosition:3.0f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapLeft:)];
        [_photoRollLeft addGestureRecognizer:tap];
        [[self view] addSubview:_photoRollLeft];
    }
    return _photoRollLeft;
}

- (UILabel *)croppedPicLabel{
    if (!_croppedPicLabel){
        _croppedPicLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_croppedPicLabel setText:@"Crop"];
        [_croppedPicLabel setTextAlignment:NSTextAlignmentCenter];
        [_croppedPicLabel setUserInteractionEnabled:YES];
        [[_croppedPicLabel layer] setZPosition:3.0f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapCrop:)];
        [_croppedPicLabel addGestureRecognizer:tap];
        [[self view] addSubview:_croppedPicLabel];
        return _croppedPicLabel;
    }
    return _croppedPicLabel;
}

- (UIImagePickerController *)photoRollController{
    if (!_photoRollController){
        _photoRollController = [[UIImagePickerController alloc] init];
        [_photoRollController setDelegate:self];
        [_photoRollController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [_photoRollController setAllowsEditing:NO];
        [_photoRollController setMediaTypes:[NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil]];
        UIColor *teal = [UIColor blueColor];
        [_photoRollController.view setTintColor:teal];
    }
    return _photoRollController;
}


- (MELDynamicCropView *)cropViewLeft{
    if (!_cropViewLeft){
        _cropViewLeft = [[MELDynamicCropView alloc]initWithFrame:[self cropViewLeftFrame] cropFrame:[self cropViewLeftCropperFrame]];
        //[_cropViewLeft setBackgroundColor:[UIColor redColor]];
        [_cropViewLeft setCropColor:[UIColor greenColor]];
        [_cropViewLeft setCropAlpha:0.4f];
    }
    return _cropViewLeft;
}

- (MELDynamicCropView *)cropViewRight{
    if (!_cropViewRight){
        _cropViewRight = [[MELDynamicCropView alloc]initWithFrame:[self cropViewRightFrame] cropFrame:[self cropViewRightCropperFrame]];
        //[_cropViewRight setBackgroundColor:[UIColor clearColor]];
        [_cropViewRight setCropColor:[UIColor blueColor]];
        [_cropViewRight setCropAlpha:0.4f];
    }
    return _cropViewRight;
}

- (MELDynamicCropView *)cropViewPano{
    if (!_cropViewPano){
        _cropViewPano = [[MELDynamicCropView alloc]initWithFrame:[self cropViewPanoFrame] cropFrame:[self cropViewPanoCropperFrame]];
        //[_cropViewRight setBackgroundColor:[UIColor clearColor]];
        [_cropViewPano setCropColor:[UIColor yellowColor]];
        [_cropViewPano setCropAlpha:0.4f];
    }
    return _cropViewPano;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [[self photoRollController] dismissViewControllerAnimated:YES completion:^{
        UIImage *editedImage = [info valueForKey:UIImagePickerControllerEditedImage];
        UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
        UIImage *savedImage = (editedImage) ? editedImage : originalImage;
        
        if (savedImage){
            _image = savedImage;
            [[self cropViewLeft] setImage:_image];
            [[self view] addSubview:[self cropViewLeft]];
        }
    }];
}


#pragma mark - selectors

- (void)didTapLeft:(id)sender{
    _currentSelection = kCropLeft;
    [self presentPhotoRoll];
}

- (void)didTapRight:(id)sender{
    _currentSelection = kCropRight;
    [self presentPhotoRoll];
}

- (void)didTapPano:(id)sender{
    _currentSelection = kCropPano;
    [self presentPhotoRoll];
}

- (void)presentPhotoRoll{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:[self photoRollController] animated:YES completion:nil];
    });
}

- (void)didTapCrop:(id)sender{
    ModalViewController *vc = [[ModalViewController alloc] init];
    [[vc view] setBackgroundColor:[UIColor whiteColor]];
    [vc setImage:[[self cropViewLeft] croppedImage]];
    [vc setImageSize:[[self cropViewLeft] cropFrame].size];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
