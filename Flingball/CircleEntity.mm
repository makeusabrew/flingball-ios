//
//  CircleEntity.m
//  Flingball
//
//  Created by Nicholas Payne on 09/08/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "CircleEntity.h"

@implementation CircleEntity

@synthesize radius;

#pragma mark init methods

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithPosition: (b2Vec2)_position forWorld: (b2World*)world withRadius: (float32)_radius {
    self = [self init];
    if (self) {
        radius = _radius;
    }
    return self;
}

@end
