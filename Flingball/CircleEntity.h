//
//  CircleEntity.h
//  Flingball
//
//  Created by Nicholas Payne on 09/08/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "SpriteEntity.h"

@interface CircleEntity : SpriteEntity {
    float32 radius;
}

@property float32 radius;

- (id)initWithPosition: (b2Vec2)_position forWorld: (b2World*)world withRadius: (float32)_radius;

@end
