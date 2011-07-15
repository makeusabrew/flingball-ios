//
//  GoalEntity.h
//  Flingball
//
//  Created by Nicholas Payne on 12/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "SpriteEntity.h"

@interface GoalEntity : SpriteEntity {
    float32 radius;
}

- (id)initWithPosition: (b2Vec2)_position forWorld: (b2World*)world;

@end
