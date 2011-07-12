//
//  Ball.h
//  Flingball
//
//  Created by Nicholas Payne on 08/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Entity.h"

@interface Ball : Entity
{
    float32 radius;
}

- (id)initWithPosition: (b2Vec2)_position forWorld: (b2World*)world;
- (void)fling: (b2Vec2)vector;

@end
