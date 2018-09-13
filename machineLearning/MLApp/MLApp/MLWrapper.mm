//
//  MLWrapper.m
//  MLApp
//
//  Created by DImple on 29/11/17.
//  Copyright © 2017 DImple. All rights reserved.
//

#import "MLWrapper.h"


//#include <dlib/queue.h>
#include <dlib/image_processing.h>
#include <dlib/image_io.h>

@interface MLWrapper ()

@property (assign) BOOL prepared;

    + (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects;

@end

@implementation MLWrapper {
    dlib::shape_predictor sp;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _prepared = NO;
    }
    return self;
}

- (void)prepare {
    NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    std::string modelFileNameCString = [modelFileName UTF8String];
    
    dlib::deserialize(modelFileNameCString) >> sp;
    
    self.prepared = YES;
}

- (NSMutableArray *)doWorkOnSampleBuffer:(UIImage *)image inRects:(NSArray<NSValue *> *)rects {
    
    NSMutableArray *points = [[NSMutableArray alloc]init];
    if (!self.prepared) {
        [self prepare];
    }
  
    dlib::array2d<dlib::bgr_pixel> dlibImage;
    
    // convert uiimage to dlib image
    CGFloat width = image.size.width, height = image.size.height;
    CGContextRef context;
    size_t pixelBits = CGImageGetBitsPerPixel(image.CGImage);
    size_t pixelBytes = pixelBits/8;
    size_t dataSize = pixelBytes * ((size_t) width*height);
    char* imageData = (char*) malloc(dataSize);
    memset(imageData, 0, dataSize);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    bool isGray = false;
    if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelMonochrome) {
        // gray image
        bitmapInfo = kCGImageAlphaNone;
        isGray = true;
    }
    else
    {
        // color image
        
            bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
      
    }
    
    context = CGBitmapContextCreate(imageData, (size_t) width, (size_t) height,
                                    8, pixelBytes*((size_t)width), colorSpace,
                                    bitmapInfo);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
    CGContextRelease(context);
    
    dlibImage.clear();
    dlibImage.set_size((long)height, (long)width);
    dlibImage.reset();
    long position = 0;
    while (dlibImage.move_next()){
        dlib::bgr_pixel& pixel = dlibImage.element();
        
        long offset = position*((long) pixelBytes);
        char b, g, r;
        if (isGray) {
            b = imageData[offset];
            g = imageData[offset];
            r = imageData[offset];
        } else {
            b = imageData[offset];
            g = imageData[offset+1];
            r = imageData[offset+2];
        }
        pixel = dlib::bgr_pixel(b, g, r);
        position++;
    }
    free(imageData);
    
    std::vector<dlib::rectangle> convertedRectangles = [MLWrapper convertCGRectValueArray:rects];
    
    for (unsigned long j =0; j < convertedRectangles.size(); ++j) {
        
        dlib::rectangle oneFaceRect = convertedRectangles[j];
        
        // detect all landmarks
        dlib::full_object_detection shape = sp(dlibImage, oneFaceRect);
        
        // and draw them into the image (samplebuffer)
        for (unsigned long k = 0; k < shape.num_parts();  k++) {
            
            dlib::point p = shape.part(k);
            CGPoint point = CGPointMake(p.x(), p.y());
            [points addObject:[NSValue valueWithCGPoint:point]];
        }
    }
    return points;
}

+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects {
    
    std::vector<dlib::rectangle> myConvertedRects;
    for (NSValue *rectValue in rects) {
        CGRect rect = [rectValue CGRectValue];
        long left = rect.origin.x;
        long top = rect.origin.y;
        long right = left + rect.size.width;
        long bottom = top + rect.size.height;
        dlib::rectangle dlibRect(left, top, right, bottom);
        
        myConvertedRects.push_back(dlibRect);
    }
    return myConvertedRects;
}


@end
