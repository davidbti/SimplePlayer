//
//  CALayer+SPLAnimationAdditons.m
//  SimplePlayer
//
//  Created by Matthew Doig on 3/11/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import "CALayer+SPLAnimationAdditons.h"
#import <QuartzCore/QuartzCore.h>

@implementation CALayer (SPLAnimationAdditons)

- (void)spl_applyBasicAnimation:(CABasicAnimation *)animation
{
    if (animation.fromValue == nil) {
        animation.fromValue = [self.presentationLayer ?: self valueForKeyPath:animation.keyPath];
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self setValue:animation.toValue forKeyPath:animation.keyPath];
    [CATransaction commit];
    
    [self addAnimation:animation forKey:nil];
}

@end
