//
//  SPLBezierLayer.h
//  SimplePlayer
//
//  Created by Matthew Doig on 3/7/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPLBezierLayer : NSObject

@property (nonatomic, copy) NSString *string;
@property (nonatomic, copy) NSGradient *gradient;
@property (nonatomic, copy) NSShadow *shadow;
@property (nonatomic, assign) float strokeWidth;
@property (nonatomic, copy) NSColor *strokeColor;

-(id)initWithFont:(NSFont *)font;

@end
