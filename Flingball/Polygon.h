//
//  Polygon.h
//  Flingball
//
//  Created by Nicholas Payne on 13/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Entity.h"
#import "Box2D.h"

@interface Polygon : Entity {
    b2Vec2 currentVertex;
    NSInteger vertexCount;
    NSMutableArray *vertices;
    
    b2BodyDef bodyDef;
    
    b2PolygonShape shape;
    
    b2FixtureDef shapeDef;
}

@property b2BodyDef bodyDef;
@property b2PolygonShape shape;
@property b2FixtureDef shapeDef;
@property b2Vec2 currentVertex;

-(void) commitCurrentVertex;
-(void) createShape: (b2World*)world;
-(void) setVertexX: (float32)x;
-(void) setVertexY: (float32)y;
-(void) setBodyDefX: (float32)x;
-(void) setBodyDefY: (float32)y;
-(void) setShapeDefDensity: (float32)val;
-(void) setShapeDefFriction: (float32)val;
-(void) setShapeDefRestitution: (float32)val;

@end
