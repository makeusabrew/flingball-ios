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
    
    Entity* trackedEntity;
    
    float32 seekSpeed;
    BOOL isSeeking;
}

-(void) translateBy: (b2Vec2)vector;
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
