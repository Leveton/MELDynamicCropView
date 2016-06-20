//
//  MELDynamicCropView.m
//  MELDynamicCropView
//
//  Created by Mike Leveton on 5/12/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "MELDynamicCropView.h"

#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger{
    kOrientationCenter,
    kOrientationTopLeft,
    kOrientationTopRight,
    kOrientationBottomLeft,
    kOrientationBottomRight,
}ImageFrameOrientation;

@interface MELDynamicCropView()
@property (nonatomic, strong) UIImageView               *imageToCrop;
@property (nonatomic, strong) UIView                    *cropView;
@property (nonatomic, strong) UIImage                   *copiedImage;
@property (nonatomic, strong) UIPanGestureRecognizer    *pan;
@property (nonatomic, strong) UIPinchGestureRecognizer  *pinch;
@property (nonatomic, assign) CGSize                    cropSize;
@property (nonatomic, assign) CGFloat                   cropViewXOffset;
@property (nonatomic, assign) CGFloat                   cropViewYOffset;
@property (nonatomic, assign) CGFloat                   minimumImageXOffset;
@property (nonatomic, assign) CGFloat                   minimumImageYOffset;
@property (nonatomic, assign) CGAffineTransform         originalTransform;
@property (nonatomic, assign) ImageFrameOrientation     currentOrientation;

@end

@implementation MELDynamicCropView

- (id)initWithFrame:(CGRect)frame cropFrame:(CGRect)cropFrame{
    self = [super initWithFrame:frame];
    if (self){
        [self setClipsToBounds:YES];
        CGSize cropSize = cropFrame.size;
        
        if (frame.size.width > frame.size.height){
            /* give preference to width */
            if (cropSize.width > frame.size.width){
                [self setUpGeometryForWidthWithFrame:frame cropSize:cropSize];
            }else if (cropSize.height > frame.size.height){
                [self setUpGeometryForHeightWithFrame:frame cropSize:cropSize];
            }else{
                [self setCropSize:cropSize];
            }
        }else{
            /* give preference to height */
            if (cropSize.height > frame.size.height){
                [self setUpGeometryForHeightWithFrame:frame cropSize:cropSize];
            }else if (cropSize.width > frame.size.width){
                [self setUpGeometryForWidthWithFrame:frame cropSize:cropSize];
            }else{
                [self setCropSize:cropSize];
            }
        }
    }
    
    [self setCropFrame:cropFrame];
    return self;
}

- (void)setUpGeometryForWidthWithFrame:(CGRect)frame cropSize:(CGSize)cropSize{
    CGFloat cropProportion = cropSize.height/cropSize.width;
    CGFloat adjustedWidth      = frame.size.width;
    CGFloat adjustedHeight     = adjustedWidth * cropProportion;
    CGFloat frameProportion = frame.size.height/frame.size.width;
    frame.size.width      = cropSize.width;
    frame.size.height     = frame.size.width * frameProportion;
    cropSize = CGSizeMake(adjustedWidth, adjustedHeight);
    
    [self setFrame:frame];
    [self setCropSize:cropSize];
}

- (void)setUpGeometryForHeightWithFrame:(CGRect)frame cropSize:(CGSize)cropSize{
    CGFloat cropProportion = cropSize.width/cropSize.height;
    CGFloat adjustedHeight     = frame.size.height;
    CGFloat adjustedWidth      = adjustedHeight * cropProportion;
    CGFloat frameProportion = frame.size.width/frame.size.height;
    frame.size.height    = cropSize.height;
    frame.size.width     = frame.size.height * frameProportion;
    cropSize = CGSizeMake(adjustedWidth, adjustedHeight);
    
    [self setFrame:frame];
    [self setCropSize:cropSize];
}

#pragma mark - getters

- (UIView *)cropView{
    if (!_cropView){
        _cropView = [[UIView alloc] initWithFrame:_cropFrame];
        
        /* default crop color and opacity */
        [_cropView setBackgroundColor:[UIColor blueColor]];
        [[_cropView layer] setOpacity:0.2f];
        
        [[_cropView layer] setZPosition:1.0f];
        [self addSubview:_cropView];
        return _cropView;
    }
    return _cropView;
}

- (UIImageView *)imageToCrop{
    if (!_imageToCrop){
        _imageToCrop = [[UIImageView alloc]initWithFrame:CGRectZero];
        [_imageToCrop setUserInteractionEnabled:YES];
        [_imageToCrop addGestureRecognizer:[self pan]];
        [_imageToCrop addGestureRecognizer:[self pinch]];
        [_imageToCrop setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_imageToCrop];
        return _imageToCrop;
    }
    return _imageToCrop;
}

- (UIPanGestureRecognizer *)pan{
    if (!_pan){
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPan:)];
    }
    return _pan;
}

- (UIPinchGestureRecognizer *)pinch{
    if (!_pinch){
        _pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(didPinch:)];
    }
    return _pinch;
}

- (CGFloat)distanceFromPoint:(CGPoint)pointA toPoint:(CGPoint)pointB{
    return sqrt((pointA.x - pointB.x) * (pointA.x - pointB.x) + (pointA.y - pointB.y) * (pointA.y - pointB.y));
}

- (CGPoint)orientationCenteredWithSize:(CGSize)size{
    CGPoint point = CGPointZero;
    point.x    = _cropViewXOffset -  (size.width - _cropView.bounds.size.width)/2;
    point.y    = _cropViewYOffset -  (size.height - _cropView.bounds.size.height)/2;
    return point;
}

- (CGPoint)orientationTopLeftWithSize:(CGSize)size{
    CGPoint point = CGPointZero;
    point.x    = _cropViewXOffset;
    point.y    = _cropViewYOffset;
    return point;
}

- (CGPoint)orientationTopRightWithSize:(CGSize)size{
    CGPoint point = CGPointZero;
    point.x    = CGRectGetMaxX([_cropView frame]) - size.width;
    point.y    = _cropViewYOffset;
    return point;
}

- (CGPoint)orientationBottomLeftWithSize:(CGSize)size{
    CGPoint point = CGPointZero;
    point.x    = _cropViewXOffset;
    point.y    = CGRectGetMaxY([_cropView frame]) - size.height;
    return point;
}

- (CGPoint)orientationBottomRightWithSize:(CGSize)size{
    CGPoint point = CGPointZero;
    point.x    = CGRectGetMaxX([_cropView frame]) - size.width;
    point.y    = CGRectGetMaxY([_cropView frame]) - size.height;
    return point;
}


#pragma mark - setters

- (void)setCropSize:(CGSize)cropSize{
    _cropSize = cropSize;
}

- (void)setCropFrame:(CGRect)cropFrame{
    _cropFrame = cropFrame;
    [[self cropView] setFrame:_cropFrame];
    _cropViewXOffset = cropFrame.origin.x;
    _cropViewYOffset = cropFrame.origin.y;
}

- (void)setImage:(UIImage *)image{
    _image = image;
    _copiedImage = [_image copy];
    
    [[self imageToCrop] setFrame:[self frameForGestureViewWithImage:_image]];
    
    _originalTransform = _imageToCrop.transform;
    
    [[self imageToCrop] setImage:_image];
    
    _minimumImageXOffset = (_cropViewXOffset + _cropView.bounds.size.width) - _imageToCrop.bounds.size.width;
    _minimumImageYOffset = (_cropViewYOffset + _cropView.bounds.size.height) - _imageToCrop.bounds.size.height;
}

- (void)setCropAlpha:(CGFloat)cropAlpha{
    _cropAlpha = cropAlpha;
    [[[self cropView] layer] setOpacity:_cropAlpha];
}

- (void)setCropColor:(UIColor *)cropColor{
    _cropColor = cropColor;
    [[self cropView] setBackgroundColor:_cropColor];
}

#pragma mark - selectors

- (CGRect)frameForGestureViewWithImage:(UIImage *)image{
    
    CGFloat proportion;
    CGFloat newHeight;
    CGFloat newWidth;
    
    if (image.size.width >= image.size.height){
        /* make the image height in between the crop view height and the total height */
        proportion            = image.size.width/image.size.height;
        newHeight             = (_cropSize.height + self.frame.size.height)/2;
        newWidth              = newHeight * proportion;
        
    }else{
        /* make the image width in between the crop view width and the total width */
        proportion             = image.size.height/image.size.width;
        newWidth               = (_cropSize.width + self.frame.size.width)/2;
        newHeight              = newWidth * proportion;
    }
    
    /* if crop size is wider or taller than the image, just make the proportional to the longer side of the view's frame */
    if (_cropSize.height > newHeight){
        newHeight              = self.frame.size.height;
        proportion             = image.size.width/image.size.height;
        newWidth               = newHeight * proportion;
    }
    
    if (_cropSize.width > newWidth){
        newWidth              = self.frame.size.width;
        proportion            = image.size.height/image.size.width;
        newHeight             = newWidth * proportion;
    }
    
    CGRect  dynamicImageViewFrame = [[self imageToCrop] frame];
    CGSize size = CGSizeMake(newWidth, newHeight);
    dynamicImageViewFrame.size  = size;
    CGPoint orientation;
    
    switch (_currentOrientation) {
        case kOrientationCenter:
            orientation = [self orientationCenteredWithSize:size];
            break;
        case kOrientationTopLeft:
            orientation = [self orientationTopLeftWithSize:size];
            break;
        case kOrientationTopRight:
            orientation = [self orientationTopRightWithSize:size];
            break;
        case kOrientationBottomLeft:
            orientation = [self orientationBottomLeftWithSize:size];
            break;
        case kOrientationBottomRight:
            orientation = [self orientationBottomRightWithSize:size];
            break;
        default:
            orientation = [self orientationCenteredWithSize:size];
            break;
    }
    
    dynamicImageViewFrame.origin      = orientation;
    
    return dynamicImageViewFrame;
}

- (void)didPan:(UIPanGestureRecognizer *)pan{
    if (pan.state == UIGestureRecognizerStateChanged){
        CGRect imageFrame = [[pan view] frame];
        
        CGPoint translation = [pan translationInView:pan.view.superview];
        pan.view.center = CGPointMake(pan.view.center.x + translation.x,
                                      pan.view.center.y + translation.y);
        
        CGFloat originX = pan.view.frame.origin.x;
        CGFloat originY = pan.view.frame.origin.y;
        
        if (originX < _cropViewXOffset && originY < _cropViewYOffset && originX > _minimumImageXOffset && originY > _minimumImageYOffset){
            [pan setTranslation:CGPointMake(0, 0) inView:pan.view.superview];
        }else{
            [[pan view] setFrame:imageFrame];
            [pan setTranslation:CGPointMake(0, 0) inView:pan.view.superview];
        }
    }
    
    if (pan.state == UIGestureRecognizerStateEnded){
        _minimumImageXOffset = (_cropViewXOffset + _cropView.bounds.size.width) - pan.view.frame.size.width;
        _minimumImageYOffset = (_cropViewYOffset + _cropView.bounds.size.height) - pan.view.frame.size.height;
    }
}

- (void)didPinch:(UIPinchGestureRecognizer *)recognizer{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    
    if ([recognizer state] == UIGestureRecognizerStateEnded){
        
        /* first check if the new x and y offsets are too far below or too far above the cropper, gesture will get stuck if you let this go */
        
        CGFloat gestureOriginX = recognizer.view.frame.origin.x;
        CGFloat gestureOriginY = recognizer.view.frame.origin.y;
        CGFloat gestureMaxX    = gestureOriginX + recognizer.view.frame.size.width;
        CGFloat gestureMaxY    = gestureOriginY + recognizer.view.frame.size.height;
        CGFloat cropperMaxX    = _cropViewXOffset + _cropSize.width;
        CGFloat cropperMaxY    = _cropViewYOffset + _cropSize.height;
        //bool outOfBounds       = NO;
        
        bool outOfBounds       = (cropperMaxX > gestureMaxX || cropperMaxY > gestureMaxY || gestureOriginX > _cropViewXOffset || gestureOriginY > _cropViewYOffset);
        
        CGFloat gestureWidth   = [recognizer view].frame.size.width;
        CGFloat gestureHeight  = [recognizer view].frame.size.height;
        
        bool disAllowedPinch   = (gestureWidth < _cropSize.width || gestureHeight < _cropSize.height);
        
        if (outOfBounds || disAllowedPinch){
            
            NSMutableArray *distanceArray = [NSMutableArray array];
            NSNumber *topLeft;
            NSNumber *topRight;
            NSNumber *bottomLeft;
            NSNumber *bottomRight;
            
            if (CGRectContainsPoint(_cropView.frame, CGPointMake(gestureOriginX, gestureOriginY))){
                topLeft = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureOriginX, gestureOriginY) toPoint:CGPointMake(_cropViewXOffset, _cropViewYOffset)]];
                [distanceArray addObject:topLeft];
            }
            if (CGRectContainsPoint(_cropView.frame, CGPointMake(gestureMaxX, gestureOriginY))){
                topRight = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureMaxX, gestureOriginY) toPoint:CGPointMake(cropperMaxX, _cropViewYOffset)]];
                [distanceArray addObject:topRight];
            }
            if (CGRectContainsPoint(_cropView.frame, CGPointMake(gestureOriginX, gestureMaxY))){
                bottomLeft = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureOriginX, gestureMaxY) toPoint:CGPointMake(_cropViewXOffset, cropperMaxY)]];
                [distanceArray addObject:bottomLeft];
            }
            if (CGRectContainsPoint(_cropView.frame, CGPointMake(gestureMaxX, gestureMaxY))){
                bottomRight = [NSNumber numberWithFloat:[self distanceFromPoint:CGPointMake(gestureMaxX, gestureMaxY) toPoint:CGPointMake(cropperMaxX, cropperMaxY)]];
                [distanceArray addObject:bottomRight];
            }
            
            NSArray *sortedDistances      = [distanceArray sortedArrayUsingSelector:@selector(compare:)];
            
            if (sortedDistances.count > 0){
                NSNumber *closestDistance = [sortedDistances objectAtIndex:0];
                if ([closestDistance isEqual:topLeft]){
                    _currentOrientation   = kOrientationTopLeft;
                }else if ([closestDistance isEqual:topRight]){
                    _currentOrientation   = kOrientationTopRight;
                }else if ([closestDistance isEqual:bottomLeft]){
                    _currentOrientation   = kOrientationBottomLeft;
                }else if ([closestDistance isEqual:bottomRight]){
                    _currentOrientation   = kOrientationBottomRight;
                }else{
                    _currentOrientation   = kOrientationCenter;
                }
            }else{
                _currentOrientation       = kOrientationCenter;
            }
            
            [UIView animateWithDuration:0.2f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [[self imageToCrop] setTransform:_originalTransform];
                                 [self setImage:_copiedImage];
                                 
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }else{
            _minimumImageXOffset = (_cropViewXOffset + _cropView.bounds.size.width)  - recognizer.view.frame.size.width;
            _minimumImageYOffset = (_cropViewYOffset + _cropView.bounds.size.height) - recognizer.view.frame.size.height;
        }
    }
}

#pragma mark - image methods

- (UIImage *)croppedImage{
    
    return [self croppedImageWithImage:_image rect:[self currentCropRect]];
}

- (CGRect)currentCropRect{
    /* this takes _cropView and puts it in _imageToCrop's coordinate space without moving it */
    CGRect cropRect = [_cropView convertRect:_cropView.bounds toView:_imageToCrop];
    CGFloat ratio   = 1.0f;
    
    /*changes the rect you give it to another rect with the aspect ratio that you want */
    ratio           = CGRectGetWidth(AVMakeRectWithAspectRatioInsideRect(_image.size, _imageToCrop.bounds)) / _image.size.width;
    CGRect rect     = CGRectMake(cropRect.origin.x/ratio, cropRect.origin.y/ratio, cropRect.size.width/ratio, cropRect.size.height/ratio);
    return rect;
}

- (UIImage *)croppedImageWithImage:(UIImage *)image rect:(CGRect)rect{
    
    CGFloat scale   = image.scale;
    CGRect cropRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(scale, scale));
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    //image = [self removeRotationForImage:image];
    UIImage *newImage = [UIImage imageWithCGImage:croppedImage scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(croppedImage);
    
    return newImage;
}

- (UIImage *)removeRotationForImage:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
