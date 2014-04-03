//
//  OpenMapRenderer.h
//  Election Voting VOTE
//
//  Created by Matthew Doig on 3/31/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import "glUtil.h"
#import <Foundation/Foundation.h>

@interface OpenMapRenderer : NSObject

@property (nonatomic, assign) float opacity;

- (id) initWithDefaultFBO: (GLuint) defaultFBOName;
- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height;
- (void) render;
- (void) dealloc;
- (void) initCA;
- (void) initTN;
- (void) initUSA;
- (void) initWA;

@end