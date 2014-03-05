//
//  SPLOverlayLayer.m
//  SimplePlayer
//
//  Created by Matthew Doig on 3/5/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import "SPLOverlayLayer.h"

@interface SPLOverlayLayer ()

@property (nonatomic, strong) CALayer *percent1;
@property (nonatomic, strong) CALayer *percent1Text;
@property (nonatomic, strong) CALayer *percent2;
@property (nonatomic, strong) CALayer *percent2Text;
@property (nonatomic, assign) int width1;
@property (nonatomic, assign) int width2;

@end

@implementation SPLOverlayLayer

- (void)setupWithBounds:(CGRect)bounds
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *vote1 = [f numberFromString:self.candidateVotes1];
    NSNumber *vote2 = [f numberFromString:self.candidateVotes2];
    float total = [vote1 floatValue] + [vote2 floatValue];
    float pct1 = [vote1 floatValue] / total;
    self.width1 = 650 * pct1;
    self.width2 = 650 - self.width1;

    CATextLayer *raceNameLayer = [[CATextLayer alloc] init];
    [raceNameLayer setFrame:CGRectMake(0, 480, bounds.size.width, 100)];
    NSAttributedString *raceNameAtt = [[NSAttributedString alloc]
            initWithString:self.raceName
            attributes:@{NSStrokeWidthAttributeName:[NSNumber numberWithFloat:-3.0],
                         NSStrokeColorAttributeName:[NSColor blackColor],
                         NSForegroundColorAttributeName: [NSColor whiteColor],
                         NSFontAttributeName: [NSFont fontWithName:@"Helvetica-Bold" size:45.0]}];
    [raceNameLayer setString:raceNameAtt];
    [raceNameLayer setAlignmentMode:kCAAlignmentCenter];
    
    CALayer *percentage = [CALayer layer];
    percentage.backgroundColor = [NSColor clearColor].CGColor;
    percentage.shadowOffset = CGSizeMake(0, 3);
    percentage.shadowRadius = 5.0;
    percentage.shadowColor = [NSColor blackColor].CGColor;
    percentage.shadowOpacity = 0.8;
    percentage.frame = CGRectMake(320, 440, 650, 40);
    
    CALayer *percentage1 = [CALayer layer];
    percentage1.backgroundColor = [NSColor blueColor].CGColor;
    percentage1.frame = CGRectMake(0, 0, 0, 40);
    self.percent1 = percentage1;
    
    CATextLayer *percentage1Text = [[CATextLayer alloc] init];
    [percentage1Text setFont:@"Helvetica-Bold"];
    [percentage1Text setFontSize:27];
    [percentage1Text setFrame:CGRectMake(6, -4, self.width1, 40)];
    [percentage1Text setString:self.candidatePercent1];
    [percentage1Text setAlignmentMode:kCAAlignmentLeft];
    [percentage1Text setForegroundColor:[[NSColor whiteColor] CGColor]];
    percentage1Text.opacity = 0.0;
    self.percent1Text = percentage1Text;
    
    [self.percent1 addSublayer:self.percent1Text];
    [percentage addSublayer:self.percent1];
    
    CALayer *percentage2 = [CALayer layer];
    percentage2.backgroundColor = [NSColor redColor].CGColor;
    percentage2.frame = CGRectMake(650, 0, 0, 40);
    self.percent2 = percentage2;
    
    CATextLayer *percentage2Text = [[CATextLayer alloc] init];
    [percentage2Text setFont:@"Helvetica-Bold"];
    [percentage2Text setFontSize:27];
    [percentage2Text setFrame:CGRectMake(-6, -4, self.width2, 40)];
    [percentage2Text setString:self.candidatePercent2];
    [percentage2Text setAlignmentMode:kCAAlignmentRight];
    [percentage2Text setForegroundColor:[[NSColor whiteColor] CGColor]];
    percentage2Text.opacity = 0.0;
    self.percent2Text = percentage2Text;
    
    [self.percent2 addSublayer:self.percent2Text];
    [percentage addSublayer:self.percent2];
    
    CATextLayer *candidate1 = [[CATextLayer alloc] init];
    [candidate1 setFont:@"Helvetica-Bold"];
    [candidate1 setFontSize:18];
    [candidate1 setFrame:CGRectMake(146, 304, 187, 100)];
    [candidate1 setString:self.candidateName1];
    [candidate1 setAlignmentMode:kCAAlignmentCenter];
    [candidate1 setForegroundColor:[[NSColor whiteColor] CGColor]];
    
    CALayer *headshot1 = [CALayer layer];
    NSImage *head1Image = [[NSImage alloc] initWithContentsOfFile:self.candidateHeadshot1];
    CGImageSourceRef source;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)[head1Image TIFFRepresentation], NULL);
    CGImageRef maskRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    headshot1.contents = (__bridge id)(maskRef);
    headshot1.frame = CGRectMake(146, 404, 187, 155);
    
    CATextLayer *votes1 = [[CATextLayer alloc] init];
    [votes1 setFont:@"Helvetica-Bold"];
    [votes1 setFontSize:36];
    [votes1 setFrame:CGRectMake(-400, 284, bounds.size.width, 100)];
    [votes1 setString:self.candidateVotes2];
    [votes1 setAlignmentMode:kCAAlignmentCenter];
    [votes1 setForegroundColor:[[NSColor whiteColor] CGColor]];
    [votes1 setString:self.candidateVotes1];
    [votes1 setAlignmentMode:kCAAlignmentCenter];
    [votes1 setForegroundColor:[[NSColor whiteColor] CGColor]];
    
    CATextLayer *candidate2 = [[CATextLayer alloc] init];
    [candidate2 setFont:@"Helvetica-Bold"];
    [candidate2 setFontSize:18];
    [candidate2 setFrame:CGRectMake(410, 304, bounds.size.width, 100)];
    [candidate2 setString:self.candidateName2];
    [candidate2 setAlignmentMode:kCAAlignmentCenter];
    [candidate2 setForegroundColor:[[NSColor whiteColor] CGColor]];
    
    CALayer *headshot2 = [CALayer layer];
    NSImage *head2Image = [[NSImage alloc] initWithContentsOfFile:self.candidateHeadshot2];
    CGImageSourceRef source2;
    source2 = CGImageSourceCreateWithData((__bridge CFDataRef)[head2Image TIFFRepresentation], NULL);
    CGImageRef maskRef2 = CGImageSourceCreateImageAtIndex(source2, 0, NULL);
    headshot2.contents = (__bridge id)(maskRef2);
    headshot2.frame = CGRectMake(946, 404, 187, 155);
    
    CATextLayer *votes2 = [[CATextLayer alloc] init];
    [votes2 setFont:@"Helvetica-Bold"];
    [votes2 setFontSize:36];
    [votes2 setFrame:CGRectMake(410, 284, bounds.size.width, 100)];
    [votes2 setString:self.candidateVotes2];
    [votes2 setAlignmentMode:kCAAlignmentCenter];
    [votes2 setForegroundColor:[[NSColor whiteColor] CGColor]];
    
    [self addSublayer:raceNameLayer];
    [self addSublayer:percentage];
    [self addSublayer:candidate1];
    [self addSublayer:headshot1];
    [self addSublayer:votes1];
    [self addSublayer:candidate2];
    [self addSublayer:headshot2];
    [self addSublayer:votes2];
    [self setFrame:bounds];
    [self setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
    [self setHidden:NO];
    self.opacity = 0.0;
}

-(void)hide
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.percent1Text.opacity = 0.0;
        self.percent2Text.opacity = 0.0;
        CGRect oldBounds1 = CGRectMake(0, 0, 0, self.percent1.bounds.size.height);
        self.percent1.bounds = oldBounds1;
        CGRect oldBounds2 = CGRectMake(0, 0, 0, self.percent1.bounds.size.height);
        self.percent2.bounds = oldBounds2;
    }];
    CABasicAnimation *fadeOn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOn.duration = 1.0;
    fadeOn.fromValue = [NSNumber numberWithFloat:1.0];
    self.opacity = 0.0;
    [self addAnimation:fadeOn forKey:@"fade"];
    [CATransaction commit];
}

-(void)show
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            self.percent1Text.opacity = 1.0;
        }];
        CABasicAnimation *percentOn1 = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
        percentOn1.duration = 1.0;
        CGRect oldBounds1 = CGRectMake(0, 0, 0, self.percent1.bounds.size.height);
        
        CGRect newBounds1 = CGRectMake(0, 0, self.width1, self.percent1.bounds.size.height);
        percentOn1.fromValue = [NSValue valueWithRect:NSRectFromCGRect(oldBounds1)];
        self.percent1.anchorPoint = CGPointMake(0, .5);
        self.percent1.bounds = newBounds1;
        [self.percent1 addAnimation:percentOn1 forKey:@"bounds"];
        [CATransaction commit];
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            self.percent2Text.opacity = 1.0;
        }];
        CABasicAnimation *percentOn2 = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
        percentOn2.duration = 1.0;
        CGRect oldBounds2 = CGRectMake(0, 0, 0, self.percent1.bounds.size.height);
        CGRect newBounds2 = CGRectMake(0, 0, self.width2, self.percent1.bounds.size.height);
        percentOn2.fromValue = [NSValue valueWithRect:NSRectFromCGRect(oldBounds2)];
        self.percent2.anchorPoint = CGPointMake(1, .5);
        self.percent2.bounds = newBounds2;
        [self.percent2 addAnimation:percentOn1 forKey:@"bounds"];
        [CATransaction commit];
    }];
    CABasicAnimation *fadeOn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOn.duration = 1.0;
    fadeOn.fromValue = [NSNumber numberWithFloat:0.0];
    self.opacity = 1.0;
    [self addAnimation:fadeOn forKey:@"fade"];
    [CATransaction commit];
}

@end
