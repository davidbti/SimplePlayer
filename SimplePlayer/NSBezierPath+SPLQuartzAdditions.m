//
//  NSBezierPath+SPLQuartzAdditions.m
//  SimplePlayer
//
//  Created by Matthew Doig on 3/13/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import "NSBezierPath+SPLQuartzAdditions.h"

@implementation NSBezierPath (SPLQuartzAdditions)

- (CGPathRef)spl_quartzPath
{
    long i, numElements;
    
    // Need to begin a path here.
    CGPathRef           immutablePath = NULL;
    
    // Then draw the path elements.
    numElements = [self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;
        
        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
                    
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
                    
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
                    
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
        
        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath)
            CGPathCloseSubpath(path);
        
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
    
    return immutablePath;
}

+ (NSBezierPath *)spl_bezierPathWithString:(NSString *)text inFont:(NSFont *)font {
	NSBezierPath *textPath = [self bezierPath];
	[textPath spl_appendBezierPathWithString:text inFont:font];
	return textPath;
}

- (void)spl_appendBezierPathWithString:(NSString *)text inFont:(NSFont *)font {
	if ([self isEmpty]) [self moveToPoint:NSMakePoint(0.0, -font.descender)];
    
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text];
	CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedString);
	
	CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
	CFIndex count = CFArrayGetCount(glyphRuns);
    
	for (CFIndex index = 0; index < count; index++) {
		CTRunRef currentRun = CFArrayGetValueAtIndex(glyphRuns, index);
        
		CFIndex glyphCount = CTRunGetGlyphCount(currentRun);
        
		CGGlyph glyphs[glyphCount];
		CTRunGetGlyphs(currentRun, CTRunGetStringRange(currentRun), glyphs);
        
		NSGlyph bezierPathGlyphs[glyphCount];
		for (CFIndex glyphIndex = 0; glyphIndex < glyphCount; glyphIndex++)
			bezierPathGlyphs[glyphIndex] = glyphs[glyphIndex];
        
		[self appendBezierPathWithGlyphs:bezierPathGlyphs count:glyphCount inFont:font];
	}
    
	CFRelease(line);
}
@end
