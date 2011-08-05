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

@synthesize dead;

- (id)init
{
    self = [super init];
    if (self) {
        position.x = 0;
        position.y = 0;
        
        dead = NO;
    }
    
    return self;
}

- (void)setPosition: (b2Vec2)_position {    
    b2Vec2 ptmPos = b2Vec2(_position.x / PTM_RATIO, _position.y / PTM_RATIO);
    body->SetTransform(ptmPos, 0);    
}

- (float)getX {
    return position.x;
}

- (float)getY {
    return position.y;
}

-(b2Vec2) getPosition {
    return position;
}

-(void) updateBody:(b2Body*)b {
    // update entity position
    position.Set(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
}

-(void) onCollision:(Entity *)target {
    //CCLOG(@"Contact");
}

-(void) onCollisionStart:(Entity *)target {
    
}

-(void) onCollisionEnd:(Entity *)target {
    
}

-(b2Body*) getBody {
    return body;
}

- (void)dealloc {
    body = NULL;
    
    [super dealloc];
}

@end
