//
//  SPLDocument.m
//  SimplePlayer
//
//  Created by Matthew Doig on 2/26/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import "SPLDocument.h"
#import <AVFoundation/AVFoundation.h>
#import <WebKit/WebKit.h>

static void *AVSPPlayerItemStatusContext = &AVSPPlayerItemStatusContext;
static void *AVSPPlayerRateContext = &AVSPPlayerRateContext;
static void *AVSPPlayerLayerReadyForDisplay = &AVSPPlayerLayerReadyForDisplay;

@interface SPLDocument ()

@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) CALayer *overlayLayer;
@property (nonatomic, strong) CALayer *percent1;
@property (nonatomic, strong) CALayer *percent1Text;
@property (nonatomic, strong) CALayer *percent2;
@property (nonatomic, strong) CALayer *percent2Text;
@property (nonatomic, strong) WebView *mapView;
@property (nonatomic, strong) id timeObserverToken;

@end

@implementation SPLDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"SPLDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    [super windowControllerDidLoadNib:windowController];
	[[windowController window] setMovableByWindowBackground:YES];
	[[[self playerView] layer] setBackgroundColor:CGColorGetConstantColor(kCGColorBlack)];
	[[self loadingSpinner] startAnimation:self];
	
	// Create the AVPlayer, add rate and status observers
	self.player = [[AVPlayer alloc] init];
	[self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew context:AVSPPlayerRateContext];
	[self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:AVSPPlayerItemStatusContext];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayerDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
	
	// Create an asset with our URL, asychronously load its tracks, its duration, and whether it's playable or protected.
	// When that loading is complete, configure a player to play the asset.
	AVURLAsset *asset = [AVAsset assetWithURL:[self fileURL]];
	NSArray *assetKeysToLoadAndTest = [NSArray arrayWithObjects:@"playable", @"hasProtectedContent", @"tracks", @"duration", nil];
	[asset loadValuesAsynchronouslyForKeys:assetKeysToLoadAndTest completionHandler:^(void) {
		
		// The asset invokes its completion handler on an arbitrary queue when loading is complete.
		// Because we want to access our AVPlayer in our ensuing set-up, we must dispatch our handler to the main queue.
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			
			[self setUpPlaybackOfAsset:asset withKeys:assetKeysToLoadAndTest];
			
		});
		
	}];
}

- (void)videoPlayerDidReachEnd:(NSNotification *)notification
{
    [self.player.currentItem seekToTime:kCMTimeZero];
}

- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys
{
	// This method is called when the AVAsset for our URL has completing the loading of the values of the specified array of keys.
	// We set up playback of the asset here.
	
	// First test whether the values of each of the keys we need have been successfully loaded.
	for (NSString *key in keys)
	{
		NSError *error = nil;
		
		if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed)
		{
			[self stopLoadingAnimationAndHandleError:error];
			return;
		}
	}
	
	if (![asset isPlayable] || [asset hasProtectedContent])
	{
		// We can't play this asset. Show the "Unplayable Asset" label.
		[self stopLoadingAnimationAndHandleError:nil];
		[[self unplayableLabel] setHidden:NO];
		return;
	}
	
	// We can play this asset.
	// Set up an AVPlayerLayer according to whether the asset contains video.
	if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0)
	{
		// Create an AVPlayerLayer and add it to the player view if there is video, but hide it until it's ready for display
		AVPlayerLayer *newPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:[self player]];
		[newPlayerLayer setFrame:[[[self playerView] layer] bounds]];
		[newPlayerLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
		[newPlayerLayer setHidden:YES];
        
        /*
        [self.playerView setWantsLayer:YES];
        NSView *videoView = [[NSView alloc] initWithFrame:self.playerView.frame];
        [videoView setLayer:newPlayerLayer];
        [videoView setWantsLayer:YES];
        [self.playerView addSubview:videoView];
        */
        
        [[[self playerView] layer] addSublayer:newPlayerLayer];
        
        self.PlayerLayer = newPlayerLayer;
        [self addObserver:self forKeyPath:@"playerLayer.readyForDisplay" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVSPPlayerLayerReadyForDisplay];
        
        NSRect frame;
        frame.origin.x = 206;
        frame.origin.y = 45;
        frame.size.width = 878;
        frame.size.height = 500;
        self.mapView = [[WebView alloc] initWithFrame:frame];
        NSURL *webURL = [NSURL URLWithString:@"file:///Users/matthewdoig/Desktop/GoogleEarth.html#geplugin_browserok"];
        NSURLRequest *request = [NSURLRequest requestWithURL:webURL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mapViewFinishedLoading:)
                                                     name:WebViewProgressFinishedNotification
                                                   object:self.mapView];
        
        [[self.mapView mainFrame] loadRequest:request];
        [self.playerView addSubview:self.mapView positioned:NSWindowAbove relativeTo:self.playerView];

        
        CATextLayer *raceName = [[CATextLayer alloc] init];
        [raceName setFont:@"Helvetica-Bold"];
        [raceName setFontSize:36];
        [raceName setFrame:CGRectMake(0, 480, self.playerView.layer.bounds.size.width, 100)];
        [raceName setString:@"Tennessee House District 1"];
        [raceName setAlignmentMode:kCAAlignmentCenter];
        [raceName setForegroundColor:[[NSColor whiteColor] CGColor]];
        
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
        [percentage1Text setFrame:CGRectMake(6, -4, 130, 40)];
        [percentage1Text setString:@"19.9%"];
        [percentage1Text setAlignmentMode:kCAAlignmentLeft];
        [percentage1Text setForegroundColor:[[NSColor whiteColor] CGColor]];
        self.percent1Text = percentage1Text;
        
        [percentage addSublayer:percentage1];
        
        CALayer *percentage2 = [CALayer layer];
        percentage2.backgroundColor = [NSColor redColor].CGColor;
        percentage2.frame = CGRectMake(650, 0, 0, 40);
        self.percent2 = percentage2;
        
        CATextLayer *percentage2Text = [[CATextLayer alloc] init];
        [percentage2Text setFont:@"Helvetica-Bold"];
        [percentage2Text setFontSize:27];
        [percentage2Text setFrame:CGRectMake(-6, -4, 520, 40)];
        [percentage2Text setString:@"76.1%"];
        [percentage2Text setAlignmentMode:kCAAlignmentRight];
        [percentage2Text setForegroundColor:[[NSColor whiteColor] CGColor]];
        self.percent2Text = percentage2Text;
         
        [percentage addSublayer:percentage2];
         
        CATextLayer *candidate1 = [[CATextLayer alloc] init];
        [candidate1 setFont:@"Helvetica-Bold"];
        [candidate1 setFontSize:18];
        [candidate1 setFrame:CGRectMake(-400, 304, self.playerView.layer.bounds.size.width, 100)];
        [candidate1 setString:@"Alan WoodRuff (D)"];
        [candidate1 setAlignmentMode:kCAAlignmentCenter];
        [candidate1 setForegroundColor:[[NSColor whiteColor] CGColor]];
        
        CALayer *headshot1 = [CALayer layer];
        NSImage *head1Image = [[NSImage alloc] initWithContentsOfFile:@"/Users/matthewdoig/Desktop/AndyHarris.png"];
        CGImageSourceRef source;
        source = CGImageSourceCreateWithData((__bridge CFDataRef)[head1Image TIFFRepresentation], NULL);
        CGImageRef maskRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        headshot1.contents = (__bridge id)(maskRef);
        headshot1.frame = CGRectMake(146, 404, 187, 155);
        
        CATextLayer *votes1 = [[CATextLayer alloc] init];
        [votes1 setFont:@"Helvetica-Bold"];
        [votes1 setFontSize:36];
        [votes1 setFrame:CGRectMake(-400, 284, self.playerView.layer.bounds.size.width, 100)];
        [votes1 setString:@"47,597"];
        [votes1 setAlignmentMode:kCAAlignmentCenter];
        [votes1 setForegroundColor:[[NSColor whiteColor] CGColor]];
        
        CATextLayer *candidate2 = [[CATextLayer alloc] init];
        [candidate2 setFont:@"Helvetica-Bold"];
        [candidate2 setFontSize:18];
        [candidate2 setFrame:CGRectMake(410, 304, self.playerView.layer.bounds.size.width, 100)];
        [candidate2 setString:@"Phil Roe (R)"];
        [candidate2 setAlignmentMode:kCAAlignmentCenter];
        [candidate2 setForegroundColor:[[NSColor whiteColor] CGColor]];
        
        CALayer *headshot2 = [CALayer layer];
        NSImage *head2Image = [[NSImage alloc] initWithContentsOfFile:@"/Users/matthewdoig/Desktop/PeterKing.png"];
        CGImageSourceRef source2;
        source2 = CGImageSourceCreateWithData((__bridge CFDataRef)[head2Image TIFFRepresentation], NULL);
        CGImageRef maskRef2 = CGImageSourceCreateImageAtIndex(source2, 0, NULL);
        headshot2.contents = (__bridge id)(maskRef2);
        headshot2.frame = CGRectMake(946, 404, 187, 155);
        
        CATextLayer *votes2 = [[CATextLayer alloc] init];
        [votes2 setFont:@"Helvetica-Bold"];
        [votes2 setFontSize:36];
        [votes2 setFrame:CGRectMake(410, 284, self.playerView.layer.bounds.size.width, 100)];
        [votes2 setString:@"182,186"];
        [votes2 setAlignmentMode:kCAAlignmentCenter];
        [votes2 setForegroundColor:[[NSColor whiteColor] CGColor]];
        
        CALayer *overlayLayer = [CALayer layer];
        [overlayLayer addSublayer:raceName];
        [overlayLayer addSublayer:percentage];
        [overlayLayer addSublayer:candidate1];
        [overlayLayer addSublayer:headshot1];
        [overlayLayer addSublayer:votes1];
        [overlayLayer addSublayer:candidate2];
        [overlayLayer addSublayer:headshot2];
        [overlayLayer addSublayer:votes2];
		[overlayLayer setFrame:[[[self playerView] layer] bounds]];
		[overlayLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
		[overlayLayer setHidden:NO];
        overlayLayer.opacity = 0.0;
        
        NSView *overlayView = [[NSView alloc] initWithFrame:self.playerView.frame];
        [overlayView setLayer:overlayLayer];
        [self.playerView addSubview:overlayView positioned:NSWindowAbove relativeTo:self.mapView];

        self.OverlayLayer = overlayLayer;
        
    }
	else
	{
		// This asset has no video tracks. Show the "No Video" label.
		[self stopLoadingAnimationAndHandleError:nil];
		[[self noVideoLabel] setHidden:NO];
	}
	
	// Create a new AVPlayerItem and make it our player's current item.
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    CMTimeRange editRange = CMTimeRangeMake(CMTimeMake(0, 600), CMTimeMake(asset.duration.value, asset.duration.timescale));
    NSError *editError;
    BOOL result = [composition insertTimeRange:editRange ofAsset:asset atTime:composition.duration error:&editError];
    int numOfCopies = 100;
    if (result) {
        for (int i = 0; i < numOfCopies; i++) {
            [composition insertTimeRange:editRange ofAsset:asset atTime:composition.duration error:&editError];
        }
    }
    
	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:composition];
	[[self player] replaceCurrentItemWithPlayerItem:playerItem];
	
    [self setTimeObserverToken:[[self player] addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [[self timeSlider] setDoubleValue:CMTimeGetSeconds(time)];
	}]];
}

- (void)mapViewFinishedLoading:(NSNotification *)notification {
    // set window.external as soon as the web view is done loading
    // the page
    
    // http://developer.apple.com/DOCUMENTATION/AppleApplications/Conceptual/SafariJSProgTopics/Tasks/ObjCFromJavaScript.html
    [[self.mapView windowScriptObject] setValue:self forKey:@"external"];
    [self createPlacemark];
}

- (void)createPlacemark {
    // call a JS function, passing in the text field's value
    
    // http://developer.apple.com/DOCUMENTATION/Cocoa/Conceptual/DisplayWebContent/Tasks/JavaScriptFromObjC.html
    [[self.mapView windowScriptObject] callWebScriptMethod:@"JSCreatePlacemarkAtCameraCenter"
                                        withArguments:[NSArray arrayWithObjects:@"Nashville, TN", nil]];
}

- (void)stopLoadingAnimationAndHandleError:(NSError *)error
{
	[[self loadingSpinner] stopAnimation:self];
	[[self loadingSpinner] setHidden:YES];
	if (error)
	{
		[self presentError:error
			modalForWindow:[self windowForSheet]
				  delegate:nil
		didPresentSelector:NULL
			   contextInfo:nil];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == AVSPPlayerItemStatusContext)
	{
		AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
		BOOL enable = NO;
		switch (status)
		{
			case AVPlayerItemStatusUnknown:
				break;
			case AVPlayerItemStatusReadyToPlay:
				enable = YES;
				break;
			case AVPlayerItemStatusFailed:
				[self stopLoadingAnimationAndHandleError:[[[self player] currentItem] error]];
				break;
		}
		
		[[self playPauseButton] setEnabled:enable];
		[[self fastForwardButton] setEnabled:enable];
		[[self rewindButton] setEnabled:enable];
	}
	else if (context == AVSPPlayerRateContext)
	{
		float rate = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
		if (rate != 1.f)
		{
			[[self playPauseButton] setTitle:@"Play"];
		}
		else
		{
			[[self playPauseButton] setTitle:@"Pause"];
		}
	}
	else if (context == AVSPPlayerLayerReadyForDisplay)
	{
		if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue] == YES)
		{
			// The AVPlayerLayer is ready for display. Hide the loading spinner and show it.
			[self stopLoadingAnimationAndHandleError:nil];
			[[self playerLayer] setHidden:NO];
            [[self overlayLayer] setHidden:NO];
		}
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)close
{
	[[self player] pause];
	[[self player] removeTimeObserver:[self timeObserverToken]];
	[self setTimeObserverToken:nil];
	[self removeObserver:self forKeyPath:@"player.rate"];
	[self removeObserver:self forKeyPath:@"player.currentItem.status"];
	if ([self playerLayer])
		[self removeObserver:self forKeyPath:@"playerLayer.readyForDisplay"];
	[super close];
}

+ (NSSet *)keyPathsForValuesAffectingDuration
{
	return [NSSet setWithObjects:@"player.currentItem", @"player.currentItem.status", nil];
}

- (double)duration
{
	AVPlayerItem *playerItem = [[self player] currentItem];
	
	if ([playerItem status] == AVPlayerItemStatusReadyToPlay)
		return CMTimeGetSeconds([[playerItem asset] duration]);
	else
		return 0.f;
}

- (double)currentTime
{
	return CMTimeGetSeconds([[self player] currentTime]);
}

- (void)setCurrentTime:(double)time
{
	[[self player] seekToTime:CMTimeMakeWithSeconds(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

+ (NSSet *)keyPathsForValuesAffectingVolume
{
	return [NSSet setWithObject:@"player.volume"];
}

- (float)volume
{
	return [[self player] volume];
}

- (void)setVolume:(float)volume
{
	[[self player] setVolume:volume];
}

- (IBAction)playPauseToggle:(id)sender
{
    if ([[self player] rate] != 1.f)
	{
		if ([self currentTime] == [self duration])
			[self setCurrentTime:0.f];
		[[self player] play];
	}
	else
	{
		[[self player] pause];
	}
}


- (IBAction)showDistrict1:(id)sender
{
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [[self.mapView windowScriptObject] callWebScriptMethod:@"JSCreatePlacemarkAtCameraCenter"
                                                 withArguments:@[]];
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.percent1 addSublayer:self.percent1Text];
        }];
         CABasicAnimation *percentOn1 = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
         percentOn1.duration = 1.0;
         CGRect oldBounds1 = CGRectMake(0, 0, 0, self.percent1.bounds.size.height);
         CGRect newBounds1 = CGRectMake(0, 0, 130, self.percent1.bounds.size.height);
         percentOn1.fromValue = [NSValue valueWithRect:NSRectFromCGRect(oldBounds1)];
         self.percent1.anchorPoint = CGPointMake(0, .5);
         self.percent1.bounds = newBounds1;
         [self.percent1 addAnimation:percentOn1 forKey:@"bounds"];
        [CATransaction commit];
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.percent2 addSublayer:self.percent2Text];
        }];
         CABasicAnimation *percentOn2 = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
         percentOn2.duration = 1.0;
         CGRect oldBounds2 = CGRectMake(0, 0, 0, self.percent1.bounds.size.height);
         CGRect newBounds2 = CGRectMake(0, 0, 520, self.percent1.bounds.size.height);
         percentOn2.fromValue = [NSValue valueWithRect:NSRectFromCGRect(oldBounds2)];
         self.percent2.anchorPoint = CGPointMake(1, .5);
         self.percent2.bounds = newBounds2;
         [self.percent2 addAnimation:percentOn1 forKey:@"bounds"];
        [CATransaction commit];
    }];
    CABasicAnimation *fadeOn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOn.duration = 1.0;
    fadeOn.fromValue = [NSNumber numberWithFloat:0.0];
    self.overlayLayer.opacity = 1.0;
    [self.overlayLayer addAnimation:fadeOn forKey:@"fade"];
    [CATransaction commit];
}

- (IBAction)rewind:(id)sender
{
    if ([[self player] rate] > -2.f)
	{
		[[self player] setRate:-2.f];
	}
	else
	{
		[[self player] setRate:[[self player] rate] - 2.f];
	}
}

- (IBAction)fastForward:(id)sender
{
	if ([[self player] rate] < 2.f)
	{
		[[self player] setRate:2.f];
	}
	else
	{
		[[self player] setRate:[[self player] rate] + 2.f];
	}
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    if (outError != NULL)
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    if (outError != NULL)
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	return YES;
}

@end
