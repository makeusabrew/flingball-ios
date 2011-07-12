//
//  Ball.h
//  Flingball
//
//  Created by Nicholas Payne on 08/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "SpriteEntity.h"

@interface Ball : SpriteEntity
{
    float32 radius;
    BOOL atGoal;
}

@property BOOL atGoal;

- (id)initWithPosition: (b2Vec2)_position forWorld: (b2World*)world;
- (void)fling: (b2Vec2)vector;

@end
