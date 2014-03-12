//
//  SPLOverlayLayer.m
//  SimplePlayer
//
//  Created by Matthew Doig on 3/5/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import "SPLOverlayLayer.h"
#import "SPLBezierLayer.h"
#import "CAAnimation+SPLBlockAdditions.h"
#import "CALayer+SPLAnimationAdditons.h"
#import "NSString+SPLBezierPathAdditons.h"
#import <QuartzCore/QuartzCore.h>

@interface SPLOverlayLayer ()

@property (nonatomic, strong) CATextLayer *candidate1Layer;
@property (nonatomic, strong) CALayer *candidate1Bg;
@property (nonatomic, strong) CALayer *candidate1BgText;
@property (nonatomic, strong) CATextLayer *candidate2Layer;
@property (nonatomic, strong) CALayer *candidate2Bg;
@property (nonatomic, strong) CALayer *candidate2BgText;
@property (nonatomic, strong) CAEmitterLayer *emitter1Layer;
@property (nonatomic, strong) CAEmitterLayer *emitter2Layer;
@property (nonatomic, strong) CATextLayer *headshot1Layer;
@property (nonatomic, strong) CATextLayer *headshot2Layer;
@property (nonatomic, strong) CALayer *percentLayer;
@property (nonatomic, strong) CALayer *percent1Layer;
@property (nonatomic, strong) CATextLayer *percent1TextLayer;
@property (nonatomic, strong) CALayer *percent2Layer;
@property (nonatomic, strong) CATextLayer *percent2TextLayer;
@property (nonatomic, strong) CALayer *raceNameLayer;
@property (nonatomic, strong) SPLBezierLayer *raceNameLayerDelegate;
@property (nonatomic, strong) CATextLayer *votes1Layer;
@property (nonatomic, strong) CATextLayer *votes2Layer;
@property (nonatomic, strong) CALayer *win1Layer;
@property (nonatomic, strong) CALayer *win2Layer;

@property (nonatomic, strong) CALayer *tickerLayer;
@property (nonatomic, strong) CATextLayer *crawlLayer;


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
    self.raceNameLayer = [[CALayer alloc] init];
    self.raceNameLayer.frame = CGRectMake(0, 520, bounds.size.width, 60);
    
    NSFont *font = [NSFont fontWithName:@"Helvetica-Bold" size:45.0];
    self.raceNameLayerDelegate = [[SPLBezierLayer alloc] initWithFont:font];
    self.raceNameLayerDelegate.string = @"Test Race Name";
    self.raceNameLayer.delegate = self.raceNameLayerDelegate;
    
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
    self.percent1Layer.anchorPoint = CGPointMake(0, .5);
    self.percent1TextLayer = [[CATextLayer alloc] init];
    self.percent1TextLayer.frame = CGRectMake(6, -4, 100, 40);
    self.percent1TextLayer.alignmentMode = kCAAlignmentLeft;
    [self setPercent1LayerString:@""];
    
    [self.percentLayer addSublayer:self.percent1Layer];
    [self.percentLayer addSublayer:self.percent1TextLayer];
    
    self.percent2Layer = [CALayer layer];
    self.percent2Layer.backgroundColor = [NSColor redColor].CGColor;
    self.percent2Layer.frame = CGRectMake(self.percentLayer.bounds.size.width, 0, 0, 40);
    self.percent2Layer.anchorPoint = CGPointMake(1, .5);
    self.percent2TextLayer = [[CATextLayer alloc] init];
    self.percent2TextLayer.frame = CGRectMake(self.percentLayer.bounds.size.width - 106, -4, 100, 40);
    self.percent2TextLayer.alignmentMode = kCAAlignmentRight;
    [self setPercent2LayerString:@""];

    [self.percentLayer addSublayer:self.percent2Layer];
    [self.percentLayer addSublayer:self.percent2TextLayer];
    
    self.candidate1Bg = [[CALayer alloc] init];
    [self.candidate1Bg setFrame:CGRectMake(126, 334, 187, 225)];
    [self.candidate1Bg setBackgroundColor:[[NSColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.7] CGColor]];
    self.candidate1Bg.cornerRadius = 20.0;
    self.candidate1Bg.borderWidth = 2.0;
    self.candidate1Bg.borderColor = [[NSColor whiteColor] CGColor];
    
    CATransform3D cand1BgTx = CATransform3DIdentity;
    cand1BgTx.m34 = -1.0 / 500.0;
    cand1BgTx = CATransform3DRotate(cand1BgTx, M_PI_4 / 8, 0, 1, 0);
    self.candidate1Bg.transform = cand1BgTx;
    
    [self setupEmitter1];
    [self.candidate1Bg addSublayer:self.emitter1Layer];
    
    self.candidate1BgText = [[CALayer alloc] init];
    [self.candidate1BgText setFrame:CGRectMake(0, 0, 187, 225)];
    self.candidate1BgText.cornerRadius = 20.0;
    [self.candidate1Bg addSublayer:self.candidate1BgText];
    
    self.candidate1Layer = [[CATextLayer alloc] init];
    self.candidate1Layer.frame = CGRectMake(0, -30, self.candidate1Bg.bounds.size.width, 100);
    self.candidate1Layer.alignmentMode = kCAAlignmentCenter;
    [self setCandidate1LayerString:@""];
    [self.candidate1BgText addSublayer:self.candidate1Layer];
    
    self.headshot1Layer = [CALayer layer];
    self.headshot1Layer.frame = CGRectMake(0, 70, self.candidate1Bg.bounds.size.width, 155);
    [self setHeadshot1LayerImage:@""];
    [self.candidate1BgText addSublayer:self.headshot1Layer];
    
    self.votes1Layer = [[CATextLayer alloc] init];
    self.votes1Layer.frame = CGRectMake(0, -50, self.candidate1Bg.bounds.size.width, 100);
    self.votes1Layer.alignmentMode = kCAAlignmentCenter;
    [self setVotes1LayerString:@""];
    [self.candidate1BgText addSublayer:self.votes1Layer];
    
    self.win1Layer = [CALayer layer];
    self.win1Layer.frame = CGRectMake(5, 173, 48, 48);
    [self setWin1LayerImage:@""];
    [self.candidate1BgText addSublayer:self.win1Layer];
    
    self.candidate2Bg = [[CALayer alloc] init];
    [self.candidate2Bg setFrame:CGRectMake(956, 334, 187, 225)];
    [self.candidate2Bg setBackgroundColor:[[NSColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.7] CGColor]];
    self.candidate2Bg.cornerRadius = 20.0;
    self.candidate2Bg.borderWidth = 2.0;
    self.candidate2Bg.borderColor = [[NSColor whiteColor] CGColor];

    CATransform3D cand2BgTx = CATransform3DIdentity;
    cand2BgTx.m34 = -1.0 / 500.0;
    cand2BgTx = CATransform3DRotate(cand2BgTx, -M_PI_4 / 8, 0, 1, 0);
    self.candidate2Bg.transform = cand2BgTx;
    
    [self setupEmitter2];
    [self.candidate2Bg addSublayer:self.emitter2Layer];
    
    self.candidate2BgText = [[CALayer alloc] init];
    [self.candidate2BgText setFrame:CGRectMake(0, 0, 187, 225)];
    self.candidate2BgText.cornerRadius = 20.0;
    [self.candidate2Bg addSublayer:self.candidate2BgText];
    
    self.candidate2Layer = [[CATextLayer alloc] init];
    self.candidate2Layer.frame = CGRectMake(0, -30, self.candidate2Bg.bounds.size.width, 100);
    self.candidate2Layer.alignmentMode = kCAAlignmentCenter;
    [self setCandidate2LayerString:@""];
    [self.candidate2BgText addSublayer:self.candidate2Layer];
    
    self.headshot2Layer = [CALayer layer];
    self.headshot2Layer.frame = CGRectMake(0, 70, self.candidate2Bg.bounds.size.width, 155);
    [self setHeadshot2LayerImage:@""];
    [self.candidate2BgText addSublayer:self.headshot2Layer];
    
    self.votes2Layer = [[CATextLayer alloc] init];
    self.votes2Layer.frame = CGRectMake(0, -50, self.candidate2Bg.bounds.size.width, 100);
    self.votes2Layer.alignmentMode = kCAAlignmentCenter;
    [self setVotes2LayerString:@""];
    [self.candidate2BgText addSublayer:self.votes2Layer];
    
    self.win2Layer = [CALayer layer];
    self.win2Layer.frame = CGRectMake(134, 173, 48, 48);
    [self setWin2LayerImage:@""];
    [self.candidate2BgText addSublayer:self.win2Layer];
    
    self.tickerLayer = [CALayer layer];
    self.tickerLayer.frame = CGRectMake(-10, 60, bounds.size.width, 0);
    [self setTickerLayerImage:@"/Users/matthewdoig/Desktop/ticker_blue_bar_darker_60.png"];
    
    [self addSublayer:self.raceNameLayer];
    [self addSublayer:self.percentLayer];
    [self addSublayer:self.candidate1Bg];
    [self addSublayer:self.candidate2Bg];
    [self addSublayer:self.tickerLayer];
    [self setFrame:bounds];
    [self setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
    [self setHidden:NO];
    self.opacity = 1.0;
}

- (void)addAnimation:(CAAnimation *)anim forKey:(NSString *)key
{
    [self.raceNameLayer addAnimation:anim forKey:key];
    [self.candidate1BgText addAnimation:anim forKey:key];
    [self.candidate2BgText addAnimation:anim forKey:key];
}

-(void) setupEmitter1
{
    self.emitter1Layer = [CAEmitterLayer layer];
    self.emitter1Layer.frame = CGRectMake(0, 0, 187, 225);
    self.emitter1Layer.masksToBounds = YES;
    self.emitter1Layer.opacity = 0.3f;
    self.emitter1Layer.cornerRadius = 20.0;
    
    self.emitter1Layer.renderMode = kCAEmitterLayerAdditive;
    self.emitter1Layer.emitterPosition = CGPointMake(self.emitter1Layer.frame.size.width / 2.0, self.emitter1Layer.frame.size.height / 2.0);
    
    CAEmitterCell * cell = [[CAEmitterCell alloc] init];
    
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:@"/Users/matthewdoig/Desktop/star_blue_20_20.png"];
    CGImageSourceRef source;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)[image TIFFRepresentation], NULL);
    CGImageRef maskRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    cell.contents = (__bridge id)(maskRef);
    
    //Number of particles per second
    cell.birthRate = 5;
    
    //Life in seconds
    cell.lifetime = 7.0;
    cell.lifetimeRange = 8.0;
    
    //Magnitude of initial veleocity with which particles travel
    cell.velocity = 20;
    
    //Radial direction of emission of the particles
    cell.emissionRange = 2 * M_PI;
    
    //Spin (angular velocity) of the particles in radians per sec
    cell.spin = 0.0;
    cell.spinRange = 4 * M_PI;
    
    //Scaling of the particles
    cell.scale = 1.0;
    cell.scaleRange = 1.0;
    
    self.emitter1Layer.emitterCells = @[cell];
}

-(void) setupEmitter2
{
    self.emitter2Layer = [CAEmitterLayer layer];
    self.emitter2Layer.frame = CGRectMake(0, 0, 187, 225);
    self.emitter2Layer.masksToBounds = YES;
    self.emitter2Layer.opacity = 0.3f;
    self.emitter2Layer.cornerRadius = 20.0;
    
    self.emitter2Layer.renderMode = kCAEmitterLayerAdditive;
    self.emitter2Layer.emitterPosition = CGPointMake(self.emitter2Layer.frame.size.width / 2.0, self.emitter2Layer.frame.size.height / 2.0);
    
    CAEmitterCell * cell = [[CAEmitterCell alloc] init];
    
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:@"/Users/matthewdoig/Desktop/star_red_20_20.png"];
    CGImageSourceRef source;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)[image TIFFRepresentation], NULL);
    CGImageRef maskRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    cell.contents = (__bridge id)(maskRef);
    
    //Number of particles per second
    cell.birthRate = 5;
    
    //Life in seconds
    cell.lifetime = 7.0;
    cell.lifetimeRange = 8.0;
    
    //Magnitude of initial veleocity with which particles travel
    cell.velocity = 20;
    
    //Radial direction of emission of the particles
    cell.emissionRange = 2 * M_PI;
    
    //Spin (angular velocity) of the particles in radians per sec
    cell.spin = 0.0;
    cell.spinRange = 4 * M_PI;
    
    //Scaling of the particles
    cell.scale = 1.0;
    cell.scaleRange = 1.0;
    
    self.emitter2Layer.emitterCells = @[cell];
}

-(void)update
{
    self.percentLayer.opacity = 0.0;
    self.tickerLayer.opacity = 0.0;
    [self setRaceNameLayerString:self.raceName];
    [self setPercent1LayerString:@""];
    [self setPercent2LayerString:@""];
    [self setHeadshot1LayerImage:self.candidateHeadshot1];
    [self setHeadshot2LayerImage:self.candidateHeadshot2];
    [self setCandidate1LayerString:self.candidateName1];
    [self setCandidate2LayerString:self.candidateName2];
    [self setWin1LayerImage:@""];
    [self setWin2LayerImage:@""];
    [self setVotes1LayerString:@""];
    [self setVotes2LayerString:@""];
}

-(void)updateComplete
{
    self.percentLayer.opacity = 1.0;

    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *vote1 = [f numberFromString:self.candidateVotes1];
    NSNumber *vote2 = [f numberFromString:self.candidateVotes2];
    float total = [vote1 floatValue] + [vote2 floatValue];
    float pct1 = [vote1 floatValue] / total;
    int width1 = self.percentLayer.bounds.size.width * pct1;
    int width2 = self.percentLayer.bounds.size.width - width1;
    
    CABasicAnimation *percentOn1 = [CABasicAnimation animationWithKeyPath:@"bounds"];
    percentOn1.fromValue = [NSValue valueWithRect:CGRectMake(0, 0, 0, self.percent1Layer.bounds.size.height)];
    percentOn1.toValue = [NSValue valueWithRect:CGRectMake(0, 0, width1, self.percent1Layer.bounds.size.height)];
    percentOn1.duration = 1.0;
    [self.percent1Layer spl_applyBasicAnimation:percentOn1];
    
    CABasicAnimation *percentOn2 = [CABasicAnimation animationWithKeyPath:@"bounds"];
    percentOn2.fromValue = [NSValue valueWithRect:NSRectFromCGRect(CGRectMake(0, 0, 0, self.percent2Layer.bounds.size.height))];
    percentOn2.toValue = [NSValue valueWithRect:NSRectFromCGRect(CGRectMake(0, 0, width2, self.percent2Layer.bounds.size.height))];
    percentOn2.duration = 1.0f;
    [percentOn2 setCompletion:^(BOOL finished) {
        [self updatePercent];
    }];
    [self.percent2Layer spl_applyBasicAnimation:percentOn2];
}

-(void)updatePercent
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self updateCounties];
    }];
    CATransition *transition = [CATransition animation];
    transition.duration = .5;
    transition.type = kCATransitionFade;
    [self addAnimation:transition forKey:nil];

    [self setPercent1LayerString:self.candidatePercent1];
    [self setPercent2LayerString:self.candidatePercent2];
    
    if (self.candidateWin1) {
        [self setWin1LayerImage:@"/Users/matthewdoig/Desktop/check2.png"];
    }
    if (self.candidateWin2) {
        [self setWin2LayerImage:@"/Users/matthewdoig/Desktop/check2.png"];
    }
    [self setVotes1LayerString:self.candidateVotes1];
    [self setVotes2LayerString:self.candidateVotes2];
    [CATransaction commit];
}

-(void)updateCounties
{
    if (![self.raceName isEqualToString:@"Tennessee House District 5"]) return;
    
    self.tickerLayer.opacity = 1.0;

    CABasicAnimation *on = [CABasicAnimation animationWithKeyPath:@"bounds"];
    on.duration = 1.0;
    on.fromValue = [NSValue valueWithRect:NSRectFromCGRect(CGRectMake(self.tickerLayer.bounds.origin.x, self.tickerLayer.bounds.origin.y, self.tickerLayer.bounds.size.width, 0))];
    on.toValue = [NSValue valueWithRect:NSRectFromCGRect(CGRectMake(self.tickerLayer.bounds.origin.x, self.tickerLayer.bounds.origin.y, self.tickerLayer.bounds.size.width, 60))];
    [on setCompletion:^(BOOL finished) {
        
    }];
    [self.tickerLayer spl_applyBasicAnimation:on];
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

-(void)setWin1LayerImage:(NSString *)file
{
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
    CGImageSourceRef source;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)[image TIFFRepresentation], NULL);
    CGImageRef maskRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    self.win1Layer.contents = (__bridge id)(maskRef);
}

-(void)setWin2LayerImage:(NSString *)file
{
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
    CGImageSourceRef source;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)[image TIFFRepresentation], NULL);
    CGImageRef maskRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    self.win2Layer.contents = (__bridge id)(maskRef);
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

-(void)setTickerLayerImage:(NSString *)file
{
    NSImage *head1Image = [[NSImage alloc] initWithContentsOfFile:file];
    CGImageSourceRef source;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)[head1Image TIFFRepresentation], NULL);
    CGImageRef maskRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    self.tickerLayer.contents = (__bridge id)(maskRef);
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
    self.raceNameLayerDelegate.string = self.raceName;
    [self.raceNameLayer setNeedsDisplay];
}

-(void)setCrawlLayerString:(NSString *)string layer:(CATextLayer *)layer
{
    NSAttributedString *att = [[NSAttributedString alloc]
            initWithString:string
            attributes:@{NSStrokeWidthAttributeName:[NSNumber numberWithFloat:-3.0],
                         NSStrokeColorAttributeName:[NSColor blackColor],
                         NSForegroundColorAttributeName: [NSColor whiteColor],
                         NSFontAttributeName: [NSFont fontWithName:@"Helvetica-Bold" size:27.0]}];
    [layer setString:att];
    CGRect f = layer.frame;
    f.size = [att size];
    layer.frame = f;
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
