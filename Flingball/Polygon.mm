//
//  Polygon.mm
//  Flingball
//
//  Created by Nicholas Payne on 13/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Polygon.h"
#import "Constants.h"

@implementation Polygon

@synthesize bodyDef, shape, shapeDef, currentVertex;

- (id)init
{
    self = [super init];
    if (self) {
        vertices = [[NSMutableArray alloc] init];
        vertexCount = 0;
        // Initialization code here.
        /*
        b2BodyDef blockBodyDef;
        blockBodyDef.type = b2_staticBody;
        blockBodyDef.position.Set(600 / PTM_RATIO, 400 / PTM_RATIO);
        blockBodyDef.userData = self;
        
        //body world->CreateBody(&blockBodyDef);
        
        b2PolygonShape blockShape;
        //blockShape.
        blockShape.SetAsBox(0.25, 4.0);
        
        b2FixtureDef blockShapeDef;
        blockShapeDef.shape = &blockShape;
        blockShapeDef.density = 10.0;
        blockShapeDef.friction = 1.0;
        blockShapeDef.restitution = 0.1f;
        
        blockBody->CreateFixture(&blockShapeDef);
         */
    }
    
    return self;
}

-(void) createShape: (b2World*)world {
    bodyDef.userData = self;
    
    body = world->CreateBody(&bodyDef);
    
    //b2Vec2 *b2Vertices;
    
    //b2Vertices = new b2Vec2[vertexCount];
    
    b2Vec2 _vertices[10];
    
    for (int i = 0; i < vertexCount; i++) {
        NSValue *val = [vertices objectAtIndex: i];
        CGPoint p = [val CGPointValue];
        _vertices[i] = b2Vec2(p.x, p.y);
    }
    
    shape.Set(_vertices, vertexCount);
    
    shapeDef.shape = &shape;
    body->CreateFixture(&shapeDef);
    
    NSLog(@"added poly with %d vertices", vertexCount);
}

-(void) dealloc {
    [vertices release];
    vertices = nil;
    
    [super dealloc];
}

-(void) setVertexX:(float32)x {
    currentVertex.x = x / PTM_RATIO;
}

-(void) setVertexY:(float32)y {
    currentVertex.y = y / PTM_RATIO;
}

-(void) setBodyDefX:(float32)x {
    bodyDef.position.x = x / PTM_RATIO;
}

-(void) setBodyDefY:(float32)y {
    bodyDef.position.y = y / PTM_RATIO;
}

-(void) setShapeDefDensity:(float32)val {
    shapeDef.density = val;
}

-(void) setShapeDefFriction:(float32)val {
    shapeDef.friction = val;
}

-(void) setShapeDefRestitution:(float32)val {
    shapeDef.restitution = val;
}

-(void) commitCurrentVertex {
    NSLog(@"commiting vertex %.2f %.2f", currentVertex.x, currentVertex.y);
    [vertices addObject:[NSValue valueWithCGPoint:CGPointMake(currentVertex.x, currentVertex.y)]];
    vertexCount ++;
}

@end
