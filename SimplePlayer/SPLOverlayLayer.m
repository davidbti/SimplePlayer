//
//  SPLOverlayLayer.m
//  SimplePlayer
//
//  Created by Matthew Doig on 3/5/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import "SPLOverlayLayer.h"

@interface SPLOverlayLayer ()

@property (nonatomic, strong) CATextLayer *candidate1Layer;
@property (nonatomic, strong) CATextLayer *candidate2Layer;
@property (nonatomic, strong) CATextLayer *headshot1Layer;
@property (nonatomic, strong) CATextLayer *headshot2Layer;
@property (nonatomic, strong) CALayer *percentLayer;
@property (nonatomic, strong) CALayer *percent1Layer;
@property (nonatomic, strong) CATextLayer *percent1TextLayer;
@property (nonatomic, strong) CALayer *percent2Layer;
@property (nonatomic, strong) CATextLayer *percent2TextLayer;
@property (nonatomic, strong) CATextLayer *raceNameLayer;
@property (nonatomic, strong) CATextLayer *votes1Layer;
@property (nonatomic, strong) CATextLayer *votes2Layer;

@end

@implementation SPLOverlayLayer

-(id)initWithBounds:(CGRect)bounds
{
    self = [super init];
    if (self) {
        [self setupWithBounds:bounds];
    }
    return self;
}

-(void)setupWithBounds:(CGRect)bounds
{
    self.raceNameLayer = [[CATextLayer alloc] init];
    self.raceNameLayer.frame = CGRectMake(0, 480, bounds.size.width, 100);
    self.raceNameLayer.alignmentMode = kCAAlignmentCenter;
    [self setRaceNameLayerString:@""];
    
    self.percentLayer = [CALayer layer];
    self.percentLayer.backgroundColor = [NSColor clearColor].CGColor;
    self.percentLayer.shadowOffset = CGSizeMake(0, -5);
    self.percentLayer.shadowRadius = 10.0;
    self.percentLayer.shadowColor = [NSColor blackColor].CGColor;
    self.percentLayer.shadowOpacity = 0.8;
    self.percentLayer.frame = CGRectMake(320, 440, 630, 40);
    
    self.percent1Layer = [CALayer layer];
    self.percent1Layer.backgroundColor = [NSColor blueColor].CGColor;
    self.percent1Layer.frame = CGRectMake(0, 0, 0, 40);
    self.percent1TextLayer = [[CATextLayer alloc] init];
    self.percent1TextLayer.frame = CGRectMake(6, -4, 100, 40);
    self.percent1TextLayer.alignmentMode = kCAAlignmentLeft;
    [self setPercent1LayerString:@""];
    
    [self.percentLayer addSublayer:self.percent1Layer];
    [self.percentLayer addSublayer:self.percent1TextLayer];
    
    self.percent2Layer = [CALayer layer];
    self.percent2Layer.backgroundColor = [NSColor redColor].CGColor;
    self.percent2Layer.frame = CGRectMake(self.percentLayer.bounds.size.width, 0, 0, 40);
    self.percent2TextLayer = [[CATextLayer alloc] init];
    self.percent2TextLayer.frame = CGRectMake(self.percentLayer.bounds.size.width - 106, -4, 100, 40);
    self.percent2TextLayer.alignmentMode = kCAAlignmentRight;
    [self setPercent2LayerString:@""];

    [self.percentLayer addSublayer:self.percent2Layer];
    [self.percentLayer addSublayer:self.percent2TextLayer];
    
    CALayer *candidate1Bg = [[CALayer alloc] init];
    [candidate1Bg setFrame:CGRectMake(126, 334, 187, 225)];
    [candidate1Bg setBackgroundColor:[[NSColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.6] CGColor]];
    candidate1Bg.cornerRadius = 10.0;
    CATransform3D cand1BgTx = CATransform3DIdentity;
    cand1BgTx.m34 = -1.0 / 500.0;
    cand1BgTx = CATransform3DRotate(cand1BgTx, M_PI_4 / 8, 0, 1, 0);
    candidate1Bg.transform = cand1BgTx;
    
    self.candidate1Layer = [[CATextLayer alloc] init];
    self.candidate1Layer.frame = CGRectMake(0, -30, candidate1Bg.bounds.size.width, 100);
    self.candidate1Layer.alignmentMode = kCAAlignmentCenter;
    [self setCandidate1LayerString:@""];
    [candidate1Bg addSublayer:self.candidate1Layer];
    
    self.headshot1Layer = [CALayer layer];
    self.headshot1Layer.frame = CGRectMake(0, 70, candidate1Bg.bounds.size.width, 155);
    [self setHeadshot1LayerImage:@""];
    [candidate1Bg addSublayer:self.headshot1Layer];
    
    self.votes1Layer = [[CATextLayer alloc] init];
    self.votes1Layer.frame = CGRectMake(0, -50, candidate1Bg.bounds.size.width, 100);
    self.votes1Layer.alignmentMode = kCAAlignmentCenter;
    [self setVotes1LayerString:@""];
    [candidate1Bg addSublayer:self.votes1Layer];
    
    CALayer *candidate2Bg = [[CALayer alloc] init];
    [candidate2Bg setFrame:CGRectMake(956, 334, 187, 225)];
    [candidate2Bg setBackgroundColor:[[NSColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.6] CGColor]];
    candidate2Bg.cornerRadius = 10.0;
    CATransform3D cand2BgTx = CATransform3DIdentity;
    cand2BgTx.m34 = -1.0 / 500.0;
    cand2BgTx = CATransform3DRotate(cand2BgTx, -M_PI_4 / 8, 0, 1, 0);
    candidate2Bg.transform = cand2BgTx;
    
    self.candidate2Layer = [[CATextLayer alloc] init];
    self.candidate2Layer.frame = CGRectMake(0, -30, candidate1Bg.bounds.size.width, 100);
    self.candidate2Layer.alignmentMode = kCAAlignmentCenter;
    [self setCandidate2LayerString:@""];
    [candidate2Bg addSublayer:self.candidate2Layer];
    
    self.headshot2Layer = [CALayer layer];
    self.headshot2Layer.frame = CGRectMake(0, 70, candidate2Bg.bounds.size.width, 155);
    [self setHeadshot2LayerImage:@""];
    [candidate2Bg addSublayer:self.headshot2Layer];
    
    self.votes2Layer = [[CATextLayer alloc] init];
    self.votes2Layer.frame = CGRectMake(0, -50, candidate2Bg.bounds.size.width, 100);
    self.votes2Layer.alignmentMode = kCAAlignmentCenter;
    [self setVotes2LayerString:@""];
    [candidate2Bg addSublayer:self.votes2Layer];

    [self addSublayer:self.raceNameLayer];
    [self addSublayer:self.percentLayer];
    [self addSublayer:candidate1Bg];
    [self addSublayer:candidate2Bg];
    [self setFrame:bounds];
    [self setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
    [self setHidden:NO];
    self.opacity = 1.0;
}

/*
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
*/

-(void)update
{
    [self setRaceNameLayerString:self.raceName];
    [self setPercent1LayerString:@""];
    self.percent1Layer.opacity = 0.0;
    [self setPercent2LayerString:@""];
    self.percent2Layer.opacity = 0.0;
    [self setHeadshot1LayerImage:self.candidateHeadshot1];
    [self setHeadshot2LayerImage:self.candidateHeadshot2];
    [self setCandidate1LayerString:self.candidateName1];
    [self setCandidate2LayerString:self.candidateName2];
    [self setVotes1LayerString:self.candidateVotes1];
    [self setVotes2LayerString:self.candidateVotes2];
}

-(void)updateComplete
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *vote1 = [f numberFromString:self.candidateVotes1];
    NSNumber *vote2 = [f numberFromString:self.candidateVotes2];
    float total = [vote1 floatValue] + [vote2 floatValue];
    float pct1 = [vote1 floatValue] / total;
    int width1 = self.percentLayer.bounds.size.width * pct1;
    int width2 = self.percentLayer.bounds.size.width - width1;
    
    self.percent1Layer.opacity = 1.0;
    CABasicAnimation *percentOn1 = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
    percentOn1.duration = 1.0;
    CGRect oldBounds1 = CGRectMake(0, 0, 0, self.percent1Layer.bounds.size.height);
    
    CGRect newBounds1 = CGRectMake(0, 0, width1, self.percent1Layer.bounds.size.height);
    percentOn1.fromValue = [NSValue valueWithRect:NSRectFromCGRect(oldBounds1)];
    self.percent1Layer.anchorPoint = CGPointMake(0, .5);
    self.percent1Layer.bounds = newBounds1;
    [self.percent1Layer addAnimation:percentOn1 forKey:@"bounds"];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self updatePercent];
    }];
    self.percent2Layer.opacity = 1.0;
    CABasicAnimation *percentOn2 = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
    percentOn2.duration = 1.0;
    CGRect oldBounds2 = CGRectMake(0, 0, 0, self.percent1Layer.bounds.size.height);
    CGRect newBounds2 = CGRectMake(0, 0, width2, self.percent1Layer.bounds.size.height);
    percentOn2.fromValue = [NSValue valueWithRect:NSRectFromCGRect(oldBounds2)];
    self.percent2Layer.anchorPoint = CGPointMake(1, .5);
    self.percent2Layer.bounds = newBounds2;
    [self.percent2Layer addAnimation:percentOn1 forKey:@"bounds"];
    [CATransaction commit];
}

-(void)updatePercent
{
    CATransition *transition = [CATransition animation];
    transition.duration = .5;
    transition.type = kCATransitionFade;
    [self addAnimation:transition forKey:nil];

    [self setPercent1LayerString:self.candidatePercent1];
    [self setPercent2LayerString:self.candidatePercent2];
}

-(void)setCandidate1LayerString:(NSString *)string
{
    NSAttributedString *att = [[NSAttributedString alloc]
            initWithString:string
            attributes:@{NSStrokeWidthAttributeName:[NSNumber numberWithFloat:-3.0],
                         NSStrokeColorAttributeName:[NSColor blackColor],
                         NSForegroundColorAttributeName: [NSColor whiteColor],
                         NSFontAttributeName: [NSFont fontWithName:@"Helvetica-Bold" size:18.0]}];
    [self.candidate1Layer setString:att];
}

-(void)setCandidate2LayerString:(NSString *)string
{
    NSAttributedString *att = [[NSAttributedString alloc]
            initWithString:string
            attributes:@{NSStrokeWidthAttributeName:[NSNumber numberWithFloat:-3.0],
                         NSStrokeColorAttributeName:[NSColor blackColor],
                         NSForegroundColorAttributeName: [NSColor whiteColor],
                         NSFontAttributeName: [NSFont fontWithName:@"Helvetica-Bold" size:18.0]}];
    [self.candidate2Layer setString:att];
}

-(void)setHeadshot1LayerImage:(NSString *)file
{
    NSImage *head1Image = [[NSImage alloc] initWithContentsOfFile:file];
    CGImageSourceRef source;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)[head1Image TIFFRepresentation], NULL);
    CGImageRef maskRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    self.headshot1Layer.contents = (__bridge id)(maskRef);
}

-(void)setHeadshot2LayerImage:(NSString *)file
{
    NSImage *head1Image = [[NSImage alloc] initWithContentsOfFile:file];
    CGImageSourceRef source;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)[head1Image TIFFRepresentation], NULL);
    CGImageRef maskRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    self.headshot2Layer.contents = (__bridge id)(maskRef);
}

-(void)setPercent1LayerString:(NSString *)string
{
    NSAttributedString *att = [[NSAttributedString alloc]
            initWithString:string
            attributes:@{NSStrokeWidthAttributeName:[NSNumber numberWithFloat:-3.0],
                         NSStrokeColorAttributeName:[NSColor blackColor],
                         NSForegroundColorAttributeName: [NSColor whiteColor],
                         NSFontAttributeName: [NSFont fontWithName:@"Helvetica-Bold" size:27.0]}];
    [self.percent1TextLayer setString:att];
}

-(void)setPercent2LayerString:(NSString *)string
{
    NSAttributedString *att = [[NSAttributedString alloc]
            initWithString:string
            attributes:@{NSStrokeWidthAttributeName:[NSNumber numberWithFloat:-3.0],
                         NSStrokeColorAttributeName:[NSColor blackColor],
                         NSForegroundColorAttributeName: [NSColor whiteColor],
                         NSFontAttributeName: [NSFont fontWithName:@"Helvetica-Bold" size:27.0]}];
    [self.percent2TextLayer setString:att];
}

-(void)setRaceNameLayerString:(NSString *)string
{
    NSAttributedString *att = [[NSAttributedString alloc]
            initWithString:string
            attributes:@{NSStrokeWidthAttributeName:[NSNumber numberWithFloat:-3.0],
                         NSStrokeColorAttributeName:[NSColor blackColor],
                         NSForegroundColorAttributeName: [NSColor whiteColor],
                         NSFontAttributeName: [NSFont fontWithName:@"Helvetica-Bold" size:45.0]}];
    [self.raceNameLayer setString:att];
}

-(void)setVotes1LayerString:(NSString *)string
{
    NSAttributedString *att = [[NSAttributedString alloc]
            initWithString:string
            attributes:@{NSStrokeWidthAttributeName:[NSNumber numberWithFloat:-3.0],
                         NSStrokeColorAttributeName:[NSColor blackColor],
                         NSForegroundColorAttributeName: [NSColor whiteColor],
                         NSFontAttributeName: [NSFont fontWithName:@"Helvetica-Bold" size:36.0]}];
    [self.votes1Layer setString:att];
}

-(void)setVotes2LayerString:(NSString *)string
{
    NSAttributedString *att = [[NSAttributedString alloc]
            initWithString:string
            attributes:@{NSStrokeWidthAttributeName:[NSNumber numberWithFloat:-3.0],
                         NSStrokeColorAttributeName:[NSColor blackColor],
                         NSForegroundColorAttributeName: [NSColor whiteColor],
                         NSFontAttributeName: [NSFont fontWithName:@"Helvetica-Bold" size:36.0]}];
    [self.votes2Layer setString:att];
}

@end
