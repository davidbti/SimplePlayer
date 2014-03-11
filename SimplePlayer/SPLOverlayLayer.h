//
//  SPLOverlayLayer.h
//  SimplePlayer
//
//  Created by Matthew Doig on 3/5/14.
//  Copyright (c) 2014 BTI. All rights reserved.
//

@interface SPLOverlayLayer : CALayer

@property (nonatomic, strong) NSString *raceName;
@property (nonatomic, strong) NSString *candidateName1;
@property (nonatomic, strong) NSString *candidateVotes1;
@property (nonatomic, strong) NSString *candidatePercent1;
@property (nonatomic, strong) NSString *candidateHeadshot1;
@property (nonatomic, assign) BOOL candidateWin1;
@property (nonatomic, strong) NSString *candidateName2;
@property (nonatomic, strong) NSString *candidateVotes2;
@property (nonatomic, strong) NSString *candidatePercent2;
@property (nonatomic, strong) NSString *candidateHeadshot2;
@property (nonatomic, assign) BOOL candidateWin2;

-(id)initWithBounds:(CGRect)bounds;
-(void)update;
-(void)updateComplete;

@end
