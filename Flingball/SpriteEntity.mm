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

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) setPositon: (b2Vec2)_position {
    [super setPosition: _position];    
    [self setSpritePosition:_position withAngle:0];
}

- (void)setSpritePosition:(b2Vec2)_position withAngle:(float)angle {
    sprite.position = ccp(_position.x, _position.y);
    sprite.rotation = angle;
    
    // save our actual *entity* position too
    position.x = _position.x;
    position.y = _position.y;
}

- (void)updateBody:(b2Body *)b {
    b2Vec2 pos = b2Vec2(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
    float angle = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
    [self setSpritePosition:pos withAngle:angle];
}
@end
