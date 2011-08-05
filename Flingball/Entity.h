//
//  Entity.h
//  Flingball
//
//  Created by Nicholas Payne on 08/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "cocos2d.h"

@interface Entity : NSObject
{
    b2Body* body;
    b2Vec2 position;
    BOOL dead;
}

@property BOOL dead;

-(void) setPosition: (b2Vec2)_position;
-(float) getX;
-(float) getY;
-(b2Vec2) getPosition;
-(void) updateBody: (b2Body*)b;
-(void) onCollision: (Entity*)target;
-(void) onCollisionStart: (Entity*)target;
-(void) onCollisionEnd: (Entity*)target;
-(b2Body*) getBody;

@end
