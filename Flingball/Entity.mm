//
//  Entity.mm
//  Flingball
//
//  Created by Nicholas Payne on 08/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Entity.h"
#import "Constants.h"

@implementation Entity

@synthesize sprite;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        position.x = 0;
        position.y = 0;
    }
    
    return self;
}

- (void)setPosition: (b2Vec2)_position {
    
    b2Vec2 ptmPos = b2Vec2(_position.x / PTM_RATIO, _position.y / PTM_RATIO);
    body->SetTransform(ptmPos, 0);
    
    [self setSpritePosition:_position withAngle:0];
}

- (void)setSpritePosition:(b2Vec2)_position withAngle:(float)angle {
    sprite.position = ccp(_position.x, _position.y);
    sprite.rotation = angle;
    
    // save our actual *entity* position too
    position.x = _position.x;
    position.y = _position.y;
}

@end
