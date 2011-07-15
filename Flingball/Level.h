//
//  Level.h
//  Flingball
//
//  Created by Nicholas Payne on 11/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "Ball.h"
#import "ContactListener.h"
#import "GoalEntity.h"
#import "Polygon.h"
#import "Pickup.h"

@interface Level : NSObject {
    NSString* title;
    NSString* author;
    
    NSInteger width;
    NSInteger height;
    
    b2Vec2 gravity;
    b2Vec2 startPos;
    b2Vec2 endPos;
    
    b2World* world;
    Ball* ball;
    Entity* bounds;
    GoalEntity* goal;
    
    NSMutableArray* entities;
    
    ContactListener* contactListener;
}

@property (nonatomic, assign) b2World* world;
@property (nonatomic, assign) ContactListener* contactListener;
@property (nonatomic, retain) Ball* ball;
@property (nonatomic, retain) GoalEntity* goal;

-(void) createBoundaries:(CGRect)rect;
-(void) loadLevel: (NSInteger)levelIndex;

@end