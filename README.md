# MELDynamicCropView 

<img src="https://raw.githubusercontent.com/Leveton/MELDynamicCropView/master/screenshot.png" alt="screenshot" width="320px" style="width: 320px;" />

MELDynamicCropView is an open-source UIView subclass that allows users to interact with multiple photo croppers (or just one cropper). Its image and cropper frames are flexible and support any size. Pinching, panning, and support for panorama photos is built in and the library's simplicity makes it a good foundation to build a more robust photo editor e.g. as seen in the Photos app.

## System Requirements
iOS 7.0 or above

## Installation

Download this project from GitHub, move the folder named 'MELDynamicCropView' into your XCode project.

## Usage

Import the class header.

``` objective-c
#import "MELDynamicCropView.h"
```

Create the view passing in your desired image frame and cropper frame. You can set the image, the cropper color, and the cropper alpha to make it semi-transparent. Don't forget to add it as a subview.

``` objective-c
- (MELDynamicCropView *)cropView{
    if (!_cropView){
        _cropView = [[MELDynamicCropView alloc]initWithFrame:[self yourImageFrame] cropFrame:[self yourCropperFrame]];
        [_cropView setImage:_yourImage];
        [_cropView setCropColor:[UIColor redColor]];
        [_cropView setCropAlpha:0.4f];
        [[self view] addSubview:_cropView];
    }
    return _cropView;
}
```

Crop the image by simply grabbing the view's croppedImage.

``` objective-c
- (void)yourCropperMethod{
    [[self yourImageView] setImage:[[self cropView] croppedImage]];
}
```

## License

MELDynamicCropView is available under the MIT license.

Copyright © 2016 Mike Leveton

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.