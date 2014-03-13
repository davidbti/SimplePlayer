//
//  NSBezierPath+SPLQuartzAdditions.h
//  SimplePlayer
//
//  Created by Matthew Doig on 3/13/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBezierPath (SPLQuartzAdditions)

+ (NSBezierPath *)spl_bezierPathWithString:(NSString *)text inFont:(NSFont *)font;

- (void)spl_appendBezierPathWithString:(NSString *)text inFont:(NSFont *)font;

- (CGPathRef)spl_quartzPath;

@end
