//
//  SPLDocument.m
//  SimplePlayer
//
//  Created by Matthew Doig on 2/26/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import "SPLDocument.h"
#import "SPLOverlayLayer.h"
#import <AVFoundation/AVFoundation.h>
#import <WebKit/WebKit.h>

static void *AVSPPlayerItemStatusContext = &AVSPPlayerItemStatusContext;
static void *AVSPPlayerRateContext = &AVSPPlayerRateContext;
static void *AVSPPlayerLayerReadyForDisplay = &AVSPPlayerLayerReadyForDisplay;

@interface SPLDocument ()

@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) WebView *mapView;
@property (nonatomic, strong) SPLOverlayLayer *district1Layer;
@property (nonatomic, strong) NSView *district1View;
@property (nonatomic, strong) SPLOverlayLayer *district2Layer;
@property (nonatomic, strong) NSView *district2View;
@property (nonatomic, strong) NSView *overlayView;
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
        
        self.district1Layer = [[SPLOverlayLayer alloc] init];
        self.district1Layer.raceName = @"Tennessee House District 1";
        self.district1Layer.candidateName1 = @"Alan WoodRuff (D)";
        self.district1Layer.candidateHeadshot1 = @"/Users/matthewdoig/Desktop/AndyHarris.png";
        self.district1Layer.candidateVotes1 =@"47,597";
        self.district1Layer.candidatePercent1 = @"19.9%";
        self.district1Layer.candidateName2 = @"Phil Roe (R)";
        self.district1Layer.candidateHeadshot2 = @"/Users/matthewdoig/Desktop/PeterKing.png";
        self.district1Layer.candidateVotes2 =@"182,186";
        self.district1Layer.candidatePercent2 = @"76.1%";
        [self.district1Layer setupWithBounds:self.playerView.layer.bounds];
        
        self.district2Layer = [[SPLOverlayLayer alloc] init];
        self.district2Layer.raceName = @"Tennessee House District 5";
        self.district2Layer.candidateName1 = @"Jim Cooper (D)";
        self.district2Layer.candidateHeadshot1 = @"/Users/matthewdoig/Desktop/JimDeMint.png";
        self.district2Layer.candidateVotes1 =@"166,999";
        self.district2Layer.candidatePercent1 = @"65.2%";
        self.district2Layer.candidateName2 = @"Brad Staats (R)";
        self.district2Layer.candidateHeadshot2 = @"/Users/matthewdoig/Desktop/BradEllsworth.png";
        self.district2Layer.candidateVotes2 =@"83,982";
        self.district2Layer.candidatePercent2 = @"32.8%";
        [self.district2Layer setupWithBounds:self.playerView.layer.bounds];
        
        self.overlayView = [[NSView alloc] initWithFrame:self.playerView.frame];
        [self.playerView addSubview:self.overlayView positioned:NSWindowAbove relativeTo:self.mapView];
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
    [[self.mapView windowScriptObject] callWebScriptMethod:@"JSDistrict1"
                                             withArguments:@[]];
    
    [self.district2Layer hide];
    [self.overlayView setLayer:self.district1Layer];
    [self.district1Layer show];
    
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
- (IBAction)showDistrict2:(id)sender
{
    [[self.mapView windowScriptObject] callWebScriptMethod:@"JSDistrict5"
                                             withArguments:@[]];
    
    [self.district1Layer hide];
    [self.overlayView setLayer:self.district2Layer];
    [self.district2Layer show];    
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
