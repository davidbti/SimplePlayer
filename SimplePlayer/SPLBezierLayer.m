//
//  SPLBezierLayer.m
//  SimplePlayer
//
//  Created by Matthew Doig on 3/7/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import "SPLBezierLayer.h"
#import "NSString+SPLBezierPathAdditons.h"

@interface SPLBezierLayer ()

@property (nonatomic, copy) NSFont *font;
@property (nonatomic, copy) NSBezierPath *stringPath;

@end

@implementation SPLBezierLayer

-(void)setString:(NSString *)string
{
    _string = string;
    _stringPath = [_string spl_bezierWithFont:_font];
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
    ntx = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:ntx];
    
    NSAffineTransform *transform = [NSAffineTransform transform];
    float x = (layer.bounds.size.width - self.stringPath.bounds.size.width) / 2;
    float y = self.stringPath.bounds.size.height / 2;
    y = y + ((layer.bounds.size.height - self.stringPath.bounds.size.height) / 2);
    [transform translateXBy:x yBy:y];
    [self.stringPath transformUsingAffineTransform:transform];
    
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor orangeColor] endingColor:[NSColor yellowColor]];
    [gradient drawInBezierPath:self.stringPath angle:90.0];
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
