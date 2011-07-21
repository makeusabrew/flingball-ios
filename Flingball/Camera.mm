//
//  Camera.mm
//  Flingball
//
//  Created by Nicholas Payne on 11/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Camera.h"
#import "Constants.h"

@implementation Camera

- (id)init
{
    self = [super init];
    if (self) {
        isSeeking = NO;
        seekSpeed = DEFAULT_CAMERA_SEEK_SPEED;
    }
    
    return self;
}

-(void) translateBy: (b2Vec2)vector {
    position.x += vector.x;
    position.y += vector.y;
}

-(void) translateTo: (b2Vec2)vector {
    position.x = vector.x;
    position.y = vector.y;
}

-(float) getLeftEdge {
    return position.x;
}

-(float) getRightEdge {
    return position.x + width;
}

-(float) getBottomEdge {
    return position.y;
}

-(float) getTopEdge {
    return position.y + height;
}

-(float) getCenterX {
    return position.x + (width/2);
}

-(float) getCenterY {
    return position.y + (height/2);
}

-(void) setViewport:(CGRect)viewport {
    position.x = viewport.origin.x;
    position.y = viewport.origin.y;
    
    width = viewport.size.width;
    height = viewport.size.height;
}

-(void) seekToEntity:(Entity *)entity {
    [self trackEntity: entity];
    isSeeking = YES;
}

-(void) trackEntity:(Entity *)entity {
    trackedEntity = entity;
}

-(BOOL) isEntityInShot:(Entity *)entity {
    // considered "in shot" if they're within our edge thresholds
    if (
        [entity getX] >= ([self getLeftEdge] + CAMERA_EDGE_THRESHOLD) &&
        [entity getX] <= ([self getRightEdge] - CAMERA_EDGE_THRESHOLD) &&
        [entity getY] >= ([self getBottomEdge] + CAMERA_EDGE_THRESHOLD) &&
        [entity getY] <= ([self getTopEdge] - CAMERA_EDGE_THRESHOLD)
        ) {
        return YES;
    }
    return NO;
}

-(void) update {
    if (trackedEntity == nil) {
        return;
    }
    
    
    float xOver = 0.0;
    float yOver = 0.0;
    
    if (isSeeking) {
        // we're trying to catch up to the entity, so figure out where it is
        // and move towards it
        
        // when we get within a certain small threshold, snap out of trackingTo
        float32 dx = [trackedEntity getX] - [self getCenterX];
        float32 dy = [trackedEntity getY] - [self getCenterY];
        
        float32 angle = atan2f(dy, dx);
        
        xOver = cos(angle) * seekSpeed;
        yOver = sin(angle) * seekSpeed;
        
        [self translateBy:b2Vec2(xOver, yOver)];
        
        if ([self isEntityInShot: trackedEntity]) {
            isSeeking = NO;
        }        
    } else {
        if ([trackedEntity getX] > [self getRightEdge] - CAMERA_EDGE_THRESHOLD) {
            xOver = [trackedEntity getX] - ([self getRightEdge] - CAMERA_EDGE_THRESHOLD);        
        } else if ([trackedEntity getX] < [self getLeftEdge] + CAMERA_EDGE_THRESHOLD) {
            xOver = [trackedEntity getX] - ([self getLeftEdge] + CAMERA_EDGE_THRESHOLD);
        }
        
        if ([trackedEntity getY] > [self getTopEdge] - CAMERA_EDGE_THRESHOLD) {
            yOver = [trackedEntity getY] - ([self getTopEdge] - CAMERA_EDGE_THRESHOLD);
        } else if ([trackedEntity getY] < [self getBottomEdge] + CAMERA_EDGE_THRESHOLD) {
            yOver = [trackedEntity getY] - ([self getBottomEdge] + CAMERA_EDGE_THRESHOLD);
        }
        
        [self translateBy:b2Vec2(xOver, yOver)];
    }
    
    
}

@end
