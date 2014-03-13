//
//  SPLBezierLayer.m
//  SimplePlayer
//
//  Created by Matthew Doig on 3/7/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import "SPLBezierLayer.h"
#import "NSBezierPath+SPLQuartzAdditions.h"

@interface SPLBezierLayer ()

@property (nonatomic, copy) NSFont *font;
@property (nonatomic, copy) NSBezierPath *stringPath;

@end

@implementation SPLBezierLayer

-(void)setString:(NSString *)string
{
    _string = string;
    _stringPath = [NSBezierPath spl_bezierPathWithString:_string inFont:_font];
    //[_string spl_bezierWithFont:_font];
}

-(id)initWithFont:(NSFont *)font
{
    self = [super init];
    if (self) {
        self.font = font;
    }
    return self;
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    NSGraphicsContext *ntx;
    ntx = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:YES];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:ntx];
    
    NSAffineTransform *transform = [NSAffineTransform transform];
    float x = (layer.bounds.size.width - self.stringPath.bounds.size.width) / 2;
    float y = 0.0;
    [transform translateXBy:x yBy:y];
    [self.stringPath transformUsingAffineTransform:transform];
    
    if (self.gradient) {
        [self.gradient drawInBezierPath:self.stringPath angle:90.0];
    }
    
    if (self.shadow) {
        [self.shadow set];
    }
    
    if (self.strokeColor) {
        [self.stringPath setLineWidth:self.strokeWidth];
        [self.strokeColor set];
        [self.stringPath stroke];
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
