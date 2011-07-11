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

- (id)initWithPosition: (b2Vec2)position forWorld: (b2World*)world;
- (void)setPosition: (b2Vec2)position;
- (void)setSpritePosition: (b2Vec2)position withAngle:(float)angle;
- (void)fling: (b2Vec2)vector;
- (float)getX;
- (float)getY;
@end
