//
//  MLWrapper.h
//  MLApp
//
//  Created by DImple on 29/11/17.
//  Copyright © 2017 DImple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>

@interface MLWrapper : NSObject

- (instancetype)init;
- (NSMutableArray *)doWorkOnSampleBuffer:(UIImage *)image inRects:(NSArray<NSValue *> *)rects;
- (void)prepare;

@end
