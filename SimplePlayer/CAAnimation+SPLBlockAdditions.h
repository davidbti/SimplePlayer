//
//  CAAnimation+SPLBlockAdditions.h
//  SimplePlayer
//
//  Created by Matthew Doig on 3/11/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (SPLBlockAdditions)

@property (nonatomic, copy) void (^completion)(BOOL finished);
@property (nonatomic, copy) void (^start)(void);

-(void)setCompletion:(void (^)(BOOL finished))completion;

@end
