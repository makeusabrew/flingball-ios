//
//  Pickup.h
//  Flingball
//
//  Created by Nicholas Payne on 14/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "SpriteEntity.h"

@interface Pickup : SpriteEntity {
    float32 radius;
}

- (id)initWithPosition: (b2Vec2)_position forWorld: (b2World*)world;

@end
