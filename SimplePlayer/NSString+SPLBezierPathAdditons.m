//
//  NSString+SPLBezierPathAdditons.m
//  SimplePlayer
//
//  Created by Matthew Doig on 3/11/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import "NSString+SPLBezierPathAdditons.h"

@implementation NSString (SPLBezierPathAdditons)

- (NSBezierPath *)spl_bezierWithFont: (NSFont*) theFont
{
    NSBezierPath *bezier = nil; /* default result */
	
    /* put the string's text into a text storage
     so we can access the glyphs through a layout. */
	NSTextStorage *textStore = [[NSTextStorage alloc] initWithString:self];
	NSTextContainer *textContainer = [[NSTextContainer alloc] init];
	BezierNSLayoutManager *myLayout = [[BezierNSLayoutManager alloc] init];
	[myLayout addTextContainer:textContainer];
	[textStore addLayoutManager:myLayout];
	[textStore setFont: theFont];
	
    /* create a new NSBezierPath and add it to the custom layout */
	[myLayout setTheBezierPath:[NSBezierPath bezierPath]];
	
    /* to call drawGlyphsForGlyphRange, we need a destination so we'll
     set up a temporary one.  Size is unimportant and can be small.  */
	NSImage *theImage = [[NSImage alloc] initWithSize: NSMakeSize(10.0, 10.0)];
    /* lines are drawn in reverse order, so we will draw the text upside down
     and then flip the resulting NSBezierPath right side up again to achieve
     our final result with the lines in the right order and the text with
     proper orientation.  */
	[theImage setFlipped:YES];
	[theImage lockFocus];
	
    /* draw all of the glyphs to collecting them into a bezier path
     using our custom layout class. */
	NSRange glyphRange = [myLayout glyphRangeForTextContainer:textContainer];
	[myLayout drawGlyphsForGlyphRange:glyphRange atPoint:NSMakePoint(0.0, 0.0)];
	
    /* clean up our temporary drawing environment */
	[theImage unlockFocus];
	
    /* retrieve the glyphs from our BezierNSLayoutManager instance */
	bezier = [myLayout theBezierPath];
	
    /* clean up our text storage objects */
	
    /* Flip the final NSBezierPath. */
	[bezier transformUsingAffineTransform:
     [[NSAffineTransform transform] flipVertical:[bezier bounds]]];
	
    /* return the new bezier path */
	return bezier;
}

@end

@implementation BezierNSLayoutManager

/* convert the NSString into a NSBezierPath using a specific font. */
- (void)showPackedGlyphs:(char *)glyphs length:(unsigned)glyphLen
              glyphRange:(NSRange)glyphRange atPoint:(NSPoint)point font:(NSFont *)font
                   color:(NSColor *)color printingAdjustment:(NSSize)printingAdjustment {
	
    /* if there is a NSBezierPath associated with this
     layout, then append the glyphs to it. */
	NSBezierPath *bezier = [self theBezierPath];
	
	if ( nil != bezier ) {
        
        /* add the glyphs to the bezier path */
		[bezier moveToPoint:point];
		[bezier appendBezierPathWithPackedGlyphs: glyphs];
	}
}

@end

@implementation NSAffineTransform (RectMapping)

- (NSAffineTransform *)mapFrom:(NSRect)src to:(NSRect)dst {
	NSAffineTransformStruct at;
	at.m11 = (dst.size.width/src.size.width);
	at.m12 = 0.0;
	at.tX = dst.origin.x - at.m11*src.origin.x;
	at.m21 = 0.0;
	at.m22 = (dst.size.height/src.size.height);
	at.tY = dst.origin.y - at.m22*src.origin.y;
	[self setTransformStruct: at];
	return self;
}

/* create a transform that proportionately scales bounds to a rectangle of height
 centered distance units above a particular point.   */
- (NSAffineTransform *)scaleBounds:(NSRect)bounds
                          toHeight:(float)height centeredDistance:(float)distance abovePoint:(NSPoint)location {
	NSRect dst = bounds;
	float scale = (height / dst.size.height);
	dst.size.width *= scale;
	dst.size.height *= scale;
	dst.origin.x = location.x - dst.size.width/2.0;
	dst.origin.y = location.y + distance;
	return [self mapFrom:bounds to:dst];
}

/* create a transform that proportionately scales bounds to a rectangle of height
 centered distance units above the origin.   */
- (NSAffineTransform *)scaleBounds:(NSRect)bounds toHeight:(float)height
               centeredAboveOrigin:(float)distance {
	return [self scaleBounds: bounds toHeight: height centeredDistance:
			distance abovePoint: NSMakePoint(0,0)];
}

/* initialize the NSAffineTransform so it will flip the contents of bounds
 vertically. */
- (NSAffineTransform *)flipVertical:(NSRect) bounds {
	NSAffineTransformStruct at;
	at.m11 = 1.0;
	at.m12 = 0.0;
	at.tX = 0;
	at.m21 = 0.0;
	at.m22 = -1.0;
	at.tY = bounds.size.height;
	[self setTransformStruct: at];
	return self;
}

@end
