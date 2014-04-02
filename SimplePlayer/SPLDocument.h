//
//  SPLDocument.h
//  SimplePlayer
//
//  Created by Matthew Doig on 2/26/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SPLDocument : NSDocument

@property (weak) IBOutlet NSView *containerView;
@property (weak) IBOutlet NSProgressIndicator *loadingSpinner;
@property (weak) IBOutlet NSTextField *noVideoLabel;
@property (weak) IBOutlet NSTextField *unplayableLabel;
@property (weak) IBOutlet NSSlider *timeSlider;
@property (weak) IBOutlet NSButton *playPauseButton;
@property (weak) IBOutlet NSButton *fastForwardButton;
@property (weak) IBOutlet NSButton *rewindButton;
@property (weak) IBOutlet NSButton *presidentButton;
@property (weak) IBOutlet NSButton *pres3dButton;
@property (weak) IBOutlet NSButton *presCAButton;
@property (weak) IBOutlet NSButton *presUSAButton;
@property (weak) IBOutlet NSButton *presFULLButton;
@property (weak) IBOutlet NSButton *presWAButton;
@property (weak) IBOutlet NSButton *allButton;
@property (weak) IBOutlet NSButton *mapButton;
@property (weak) IBOutlet NSButton *overButton;
@property (weak) IBOutlet NSButton *bgButton;
@end
