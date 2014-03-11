//
//  NSString+SPLBezierPathAdditons.h
//  SimplePlayer
//
//  Created by Matthew Doig on 3/11/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SPLBezierPathAdditons)

- (NSBezierPath *)spl_bezierWithFont: (NSFont*) theFont;

@end

@interface BezierNSLayoutManager: NSLayoutManager

@property (nonatomic, copy) NSBezierPath *theBezierPath;

/* convert the NSString into a NSBezierPath using a specific font. */
- (void)showPackedGlyphs:(char *)glyphs length:(unsigned)glyphLen
              glyphRange:(NSRange)glyphRange atPoint:(NSPoint)point font:(NSFont *)font
                   color:(NSColor *)color printingAdjustment:(NSSize)printingAdjustment;
@end

@interface NSAffineTransform (SPLBezierPathAdditons)

/* initialize the NSAffineTransform so it maps points in
 srcBounds proportionally to points in dstBounds */
- (NSAffineTransform *)mapFrom:(NSRect)srcBounds to:(NSRect)dstBounds;

/* scale the rectangle 'bounds' proportionally to the given height centered
 above the origin with the bottom of the rectangle a distance of height above
 the a particular point.  Handy for revolving items around a particular point. */
- (NSAffineTransform *)scaleBounds:(NSRect)bounds
                          toHeight:(float)height centeredDistance:(float)distance abovePoint:(NSPoint)location;

/* same as the above, except it centers the item above the origin.  */
- (NSAffineTransform *)scaleBounds:(NSRect)bounds
                          toHeight:(float)height centeredAboveOrigin:(float)distance;

/* initialize the NSAffineTransform so it will flip the contents of bounds
 vertically. */
- (NSAffineTransform *)flipVertical:(NSRect)bounds;

@end


