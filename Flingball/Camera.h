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
}

-(void) translateBy: (b2Vec2)vector;
-(void) translateTo: (b2Vec2)vector;
-(float) getLeftEdge;
-(float) getRightEdge;
-(float) getTopEdge;
-(float) getBottomEdge;
-(void) setViewport: (CGRect)viewport;
-(void) trackEntity: (Entity*)entity;
-(void) update;

@end
