//
//  Camera.h
//  Flingball
//
//  Created by Nicholas Payne on 11/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "Entity.h"

@interface Camera : NSObject {
    b2Vec2 position;
    
    NSInteger width;
    NSInteger height;
    
    float32 zIndex;
    
    Entity* trackedEntity;
    
    float32 moveSpeed;
    float32 moveAngle;
    NSInteger mode;
}

@property float32 zIndex;

-(void) translateBy: (b2Vec2)vector;
-(void) translateBy: (b2Vec2)vector withDistance: (float32)dist andAngle: (float32) angle;
-(void) translateTo: (b2Vec2)vector;
-(float) getLeftEdge;
-(float) getRightEdge;
-(float) getTopEdge;
-(float) getBottomEdge;
-(float) getCenterX;
-(float) getCenterY;
-(void) setViewport: (CGRect)viewport;
-(void) seekToEntity: (Entity*)entity;
-(void) trackEntity: (Entity*)entity;
-(BOOL) isEntityInShot: (Entity*)entity;
-(void) update;

@end
