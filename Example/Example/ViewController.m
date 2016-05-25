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
@property (nonatomic, strong) UILabel                 *leftCropLabel;
@property (nonatomic, strong) UILabel                 *rightCropLabel;
@property (nonatomic, strong) UILabel                 *panoCropLabel;
@property (nonatomic, assign) CurrentCropSelection    currentSelection;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect photoLeftFrame = [[self photoRollLeft] frame];
    [[self photoRollLeft] setFrame:photoLeftFrame];
    
    CGRect photoRightFrame = [[self photoRollRight] frame];
    photoRightFrame.origin.x    = CGRectGetWidth([[self view]frame]) - photoRightFrame.size.width;
    [[self photoRollRight] setFrame:photoRightFrame];
    
    CGRect photoPanoFrame = [[self photoRollPano] frame];
    photoPanoFrame.origin.x    = (CGRectGetWidth([[self view]frame]) - photoPanoFrame.size.width)/2;
    [[self photoRollPano] setFrame:photoPanoFrame];
    
    CGRect leftCropFrame = [[self leftCropLabel] frame];
    leftCropFrame.origin.y    = CGRectGetHeight([[self view] frame]) - leftCropFrame.size.height;
    [[self leftCropLabel] setFrame:leftCropFrame];
    
    CGRect rightCropFrame = [[self rightCropLabel] frame];
    rightCropFrame.origin.x    = CGRectGetWidth([[self view]frame]) - rightCropFrame.size.width;
    rightCropFrame.origin.y    = CGRectGetHeight([[self view] frame]) - rightCropFrame.size.height;
    [[self rightCropLabel] setFrame:rightCropFrame];
    
    CGRect panoCropFrame = [[self panoCropLabel] frame];
    panoCropFrame.origin.x    = (CGRectGetWidth([[self view]frame]) - panoCropFrame.size.width)/2;
    panoCropFrame.origin.y    = CGRectGetHeight([[self view] frame]) - panoCropFrame.size.height;
    [[self panoCropLabel] setFrame:panoCropFrame];
    
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
    frame.origin.x    = CGRectGetWidth([[self view]frame]) - (frame.origin.y + frame.size.width);
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
    frame.origin.y    = CGRectGetHeight([[self view]frame]) - ((CGRectGetHeight([[self panoCropLabel]frame])+frame.size.height));
    frame.origin.x    = (CGRectGetWidth([[self view]frame]) - frame.size.width)/2;
    return frame;
}

- (CGRect)cropViewPanoCropperFrame{
    CGRect frame = CGRectZero;
    frame.size.width        = CGRectGetWidth([self cropViewPanoFrame]) * 0.66f;
    frame.size.height        = CGRectGetHeight([self cropViewPanoFrame]) * 0.66f;
    frame.origin.y    = (CGRectGetHeight([self cropViewPanoFrame]) - frame.size.height)/2;
    frame.origin.x    = (CGRectGetWidth([self cropViewPanoFrame]) - frame.size.width)/2;
    return frame;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - getters

- (UILabel *)photoRollLeft{
    if (!_photoRollLeft){
        _photoRollLeft = [[UILabel alloc] initWithFrame:CGRectZero];
        [_photoRollLeft setText:@"Photo Roll Left"];
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

- (UILabel *)photoRollRight{
    if (!_photoRollRight){
        _photoRollRight = [[UILabel alloc] initWithFrame:CGRectZero];
        [_photoRollRight setText:@"Photo Roll Right"];
        [_photoRollRight sizeToFit];
        [_photoRollRight setTextAlignment:NSTextAlignmentCenter];
        [_photoRollRight setUserInteractionEnabled:YES];
        [[_photoRollRight layer] setZPosition:3.0f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapRight:)];
        [_photoRollRight addGestureRecognizer:tap];
        [[self view] addSubview:_photoRollRight];
    }
    return _photoRollRight;
}

- (UILabel *)photoRollPano{
    if (!_photoRollPano){
        _photoRollPano = [[UILabel alloc] initWithFrame:CGRectZero];
        [_photoRollPano setText:@"Photo Roll Pano"];
        [_photoRollPano sizeToFit];
        [_photoRollPano setTextAlignment:NSTextAlignmentCenter];
        [_photoRollPano setUserInteractionEnabled:YES];
        [[_photoRollPano layer] setZPosition:3.0f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapPano:)];
        [_photoRollPano addGestureRecognizer:tap];
        [[self view] addSubview:_photoRollPano];
    }
    return _photoRollPano;
}


- (UILabel *)leftCropLabel{
    if (!_leftCropLabel){
        _leftCropLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_leftCropLabel setText:@"Crop Left"];
        [_leftCropLabel sizeToFit];
        [_leftCropLabel setTextAlignment:NSTextAlignmentCenter];
        [_leftCropLabel setUserInteractionEnabled:YES];
        [[_leftCropLabel layer] setZPosition:3.0f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapLeftCrop:)];
        [_leftCropLabel addGestureRecognizer:tap];
        [[self view] addSubview:_leftCropLabel];
        return _leftCropLabel;
    }
    return _leftCropLabel;
}

- (UILabel *)rightCropLabel{
    if (!_rightCropLabel){
        _rightCropLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_rightCropLabel setText:@"Crop Right"];
        [_rightCropLabel sizeToFit];
        [_rightCropLabel setTextAlignment:NSTextAlignmentCenter];
        [_rightCropLabel setUserInteractionEnabled:YES];
        [[_rightCropLabel layer] setZPosition:3.0f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapRightCrop:)];
        [_rightCropLabel addGestureRecognizer:tap];
        [[self view] addSubview:_rightCropLabel];
        return _rightCropLabel;
    }
    return _rightCropLabel;
}

- (UILabel *)panoCropLabel{
    if (!_panoCropLabel){
        _panoCropLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_panoCropLabel setText:@"Crop Pano"];
        [_panoCropLabel sizeToFit];
        [_panoCropLabel setTextAlignment:NSTextAlignmentCenter];
        [_panoCropLabel setUserInteractionEnabled:YES];
        [[_panoCropLabel layer] setZPosition:3.0f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapPanoCrop:)];
        [_panoCropLabel addGestureRecognizer:tap];
        [[self view] addSubview:_panoCropLabel];
        return _panoCropLabel;
    }
    return _panoCropLabel;
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
        [_cropViewPano setBackgroundColor:[UIColor redColor]];
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
            
            switch (_currentSelection) {
                case kCropLeft:
                    [[self cropViewLeft] setImage:_image];
                    [[self view] addSubview:[self cropViewLeft]];
                    break;
                case kCropRight:
                    [[self cropViewRight] setImage:_image];
                    [[self view] addSubview:[self cropViewRight]];
                    break;
                case kCropPano:
                    [[self cropViewPano] setImage:_image];
                    [[self view] addSubview:[self cropViewPano]];
                    break;
                default:
                    break;
            }
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

- (void)didTapLeftCrop:(id)sender{
    ModalViewController *vc = [[ModalViewController alloc] init];
    [[vc view] setBackgroundColor:[UIColor whiteColor]];
    [vc setImage:[[self cropViewLeft] croppedImage]];
    [vc setImageSize:[[self cropViewLeft] cropFrame].size];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didTapRightCrop:(id)sender{
    ModalViewController *vc = [[ModalViewController alloc] init];
    [[vc view] setBackgroundColor:[UIColor whiteColor]];
    [vc setImage:[[self cropViewRight] croppedImage]];
    [vc setImageSize:[[self cropViewRight] cropFrame].size];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didTapPanoCrop:(id)sender{
    ModalViewController *vc = [[ModalViewController alloc] init];
    [[vc view] setBackgroundColor:[UIColor whiteColor]];
    [vc setImage:[[self cropViewPano] croppedImage]];
    [vc setImageSize:[[self cropViewPano] cropFrame].size];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
