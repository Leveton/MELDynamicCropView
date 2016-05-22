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

#define imageWidth                                       (400.0f)

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) MELDynamicCropView      *dynamicCropView;
@property (nonatomic, strong) UIImagePickerController *photoRollController;
@property (nonatomic, strong) UIImage                 *image;
@property (nonatomic, strong) UILabel                 *photoRollLabel;
@property (nonatomic, strong) UILabel                 *croppedPicLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect labelFrame = [[self photoRollLabel] frame];
    labelFrame.origin.y    = 20.0f;
    labelFrame.size.height = 60.0f;
    labelFrame.size.width  = CGRectGetWidth([[self view] frame]);
    [[self photoRollLabel] setFrame:labelFrame];
    
    CGRect showLabelFrame = [[self croppedPicLabel] frame];
    showLabelFrame.size.height = 60.0f;
    showLabelFrame.size.width  = CGRectGetWidth([[self view] frame]);
    showLabelFrame.origin.y    = CGRectGetHeight([[self view] frame]) - showLabelFrame.size.height;
    [[self croppedPicLabel] setFrame:showLabelFrame];
    
}

- (CGRect)viewFrame{
    CGRect frame = CGRectZero;
    frame.size      = CGSizeMake(imageWidth, imageWidth);
    frame.origin.y  = (CGRectGetHeight([[self view] frame]) - frame.size.height)/2;
    frame.origin.x  = (CGRectGetWidth([[self view] frame]) - frame.size.width)/2;
    return frame;
}

- (CGRect)cropFrame{
    CGRect frame = CGRectZero;
    frame.size      = CGSizeMake(200, 200);
    frame.origin.y  = (CGRectGetHeight([self viewFrame]) - frame.size.height)/2;
    frame.origin.x  = (CGRectGetWidth([self viewFrame]) - frame.size.width)/2;
    return frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getters

- (UILabel *)photoRollLabel{
    if (!_photoRollLabel){
        _photoRollLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_photoRollLabel setText:@"Photo Roll"];
        [_photoRollLabel setTextAlignment:NSTextAlignmentCenter];
        [_photoRollLabel setUserInteractionEnabled:YES];
        [[_photoRollLabel layer] setZPosition:3.0f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap:)];
        [_photoRollLabel addGestureRecognizer:tap];
        [[self view] addSubview:_photoRollLabel];
    }
    return _photoRollLabel;
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


- (MELDynamicCropView *)dynamicCropView{
    if (!_dynamicCropView){
        _dynamicCropView = [[MELDynamicCropView alloc]initWithFrame:[self viewFrame] cropFrame:[self cropFrame]];
        [_dynamicCropView setBackgroundColor:[UIColor redColor]];
        [_dynamicCropView setCropColor:[UIColor greenColor]];
        [_dynamicCropView setCropAlpha:0.5f];
    }
    return _dynamicCropView;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [[self photoRollController] dismissViewControllerAnimated:YES completion:^{
        UIImage *editedImage = [info valueForKey:UIImagePickerControllerEditedImage];
        UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
        UIImage *savedImage = (editedImage) ? editedImage : originalImage;
        
        if (savedImage){
            _image = savedImage;
            [[self dynamicCropView] setImage:_image];
            [[self view] addSubview:[self dynamicCropView]];
        }
    }];
}


#pragma mark - selectors

- (void)didTap:(id)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:[self photoRollController] animated:YES completion:nil];
    });
}

- (void)didTapCrop:(id)sender{
    ModalViewController *vc = [[ModalViewController alloc] init];
    [[vc view] setBackgroundColor:[UIColor whiteColor]];
    [vc setImage:[[self dynamicCropView] croppedImage]];
    [vc setImageSize:[[self dynamicCropView] cropFrame].size];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
