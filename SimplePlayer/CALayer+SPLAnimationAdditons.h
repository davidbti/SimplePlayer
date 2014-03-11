//
//  CALayer+SPLAnimationAdditons.h
//  SimplePlayer
//
//  Created by Matthew Doig on 3/11/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CABasicAnimation;

@interface CALayer (SPLAnimationAdditons)

- (void)spl_applyBasicAnimation:(CABasicAnimation *)animation;

@end
