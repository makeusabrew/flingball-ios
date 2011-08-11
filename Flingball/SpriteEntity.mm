//
//  SpriteEntity.m
//  Flingball
//
//  Created by Nicholas Payne on 12/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "SpriteEntity.h"
#import "Constants.h"

@implementation SpriteEntity

@synthesize sprite;

#pragma mark init methods
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark -
#pragma mark main class methods

- (void)setPositon: (b2Vec2)_position {
    [super setPosition: _position];    
    [self setSpritePosition:_position withAngle:0];
}

- (void)setSpritePosition:(b2Vec2)_position withAngle:(float)angle {
    sprite.position = ccp(_position.x, _position.y);
    sprite.rotation = angle;
}

- (void)updateBody:(b2Body *)b withDelta:(ccTime)dt {
    // parent should update actual entity position
    [super updateBody:b withDelta: dt];
    
    // now worry about sprite stuff
    // -1 ensures the rotation is the same direction for the sprite as
    // it is the actual Box2D body
    float angle = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
    [self setSpritePosition:position withAngle:angle];
}
@end
