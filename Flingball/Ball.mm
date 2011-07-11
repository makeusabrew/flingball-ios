//
//  Ball.mm
//  Flingball
//
//  Created by Nicholas Payne on 08/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Ball.h"
#import "Constants.h"

@implementation Ball

- (id)init
{
    self = [super init];
    if (self) {
        radius = 32.0;  // @todo obviously change this!
        sprite = [CCSprite spriteWithFile:@"ball.png" rect:CGRectMake(0, 0, radius*2, radius*2)];
    }
    
    return self;
}

- (id)initWithPosition: (b2Vec2)_position forWorld: (b2World*)world {
    self = [self init];
    if (self) {
        
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.userData = self;
        bodyDef.angularDamping = 0.1f;
        body = world->CreateBody(&bodyDef);
        
        b2CircleShape circle;
        circle.m_radius = radius/PTM_RATIO;
        
        b2FixtureDef shapeDef;
        shapeDef.shape = &circle;
        shapeDef.density = 1.0f;
        shapeDef.friction = 0.2f;
        shapeDef.restitution = 0.7f;
        body->CreateFixture(&shapeDef);
        
        [self setPosition: _position];
        
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

- (void)fling:(b2Vec2)vector {
    body->ApplyLinearImpulse(vector, body->GetPosition());
}

- (float)getX {
    return position.x;
}

- (float)getY {
    return position.y;
}

- (void)dealloc {
    body = NULL;
    
    [super dealloc];
}

@end