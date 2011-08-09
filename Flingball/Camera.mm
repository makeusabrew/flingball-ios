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

@synthesize scale, offsetX, offsetY;

- (id)init
{
    self = [super init];
    if (self) {
        mode = CAMERA_MODE_NORMAL;
        scale = scale(1.0);
        edgeThreshold = 0.0;
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        offsetX = screenSize.width / 2.0;
        offsetY = screenSize.height / 2.0;
    }
    
    return self;
}

-(void) translateBy: (b2Vec2)vector {
    position.x += vector.x;
    position.y += vector.y;
}

-(void) translateBy:(b2Vec2)vector withDistance:(float32)dist andAngle:(float32)angle {
    mode = CAMERA_MODE_MANUAL;
    // so, the distance moved is our "speed". Let's keep a record of it
    moveSpeed = dist;
    moveAngle = angle;
    [self translateBy: vector];
}

-(void) translateTo: (b2Vec2)vector {
    position.x = vector.x;
    position.y = vector.y;
}

-(float) getLeftEdge {
    return offsetX + position.x - ((width / 2.0) / scale);
}

-(float) getRightEdge {
    return offsetX + position.x + ((width / 2.0) / scale);
}

-(float) getBottomEdge {
    return offsetY + position.y - ((height / 2.0) / scale);
}

-(float) getTopEdge {
    return offsetY + position.y + ((height / 2.0) / scale);
}

-(float) getCenterX {
    return offsetX + position.x;
}

-(float) getCenterY {
    return offsetY + position.y;
}

/**
 * we assume viewport means the actual bounds of the camera, so we have to
 * adjust our actual position
 */
-(void) setViewport:(CGRect)viewport {    
    position.x = viewport.origin.x;// + (viewport.size.width / 2.0);
    position.y = viewport.origin.y;// + (viewport.size.height / 2.0);
    
    // these terms are very loose - they will scale appropriately
    // perhaps refactor as we only really care about half widths / heights?
    width = viewport.size.width;
    height = viewport.size.height;
}

-(void) seekToEntity:(Entity *)entity {
    mode = CAMERA_MODE_SEEKING;
    moveSpeed = DEFAULT_CAMERA_SEEK_SPEED;
    trackedEntity = entity;
}

-(void) trackEntity:(Entity *)entity {
    mode = CAMERA_MODE_NORMAL;
    trackedEntity = entity;
}

-(BOOL) isEntityInShot:(Entity *)entity {
    // considered "in shot" if they're within our edge thresholds
    if (
        [entity getX] >= ([self getLeftEdge] + [self getEdgeThreshold]) &&
        [entity getX] <= ([self getRightEdge] - [self getEdgeThreshold]) &&
        [entity getY] >= ([self getBottomEdge] + [self getEdgeThreshold]) &&
        [entity getY] <= ([self getTopEdge] - [self getEdgeThreshold])
        ) {
        return YES;
    }
    return NO;
}

-(void) update {
    //CCLOG(@"[%.2f, %.2f] [%.2f, %.2f], [%.2f, %.2f]", [self getLeftEdge], [self getBottomEdge], [self getCenterX], [self getCenterY], [self getRightEdge], [self getTopEdge]);
    float xOver = 0.0;
    float yOver = 0.0;
    
    switch (mode) {            
        case CAMERA_MODE_NORMAL: {
            if (trackedEntity == nil) {
                return;
            }
            if ([trackedEntity getX] > [self getRightEdge] - [self getEdgeThreshold]) {
                xOver = [trackedEntity getX] - ([self getRightEdge] - [self getEdgeThreshold]);        
            } else if ([trackedEntity getX] < [self getLeftEdge] + [self getEdgeThreshold]) {
                xOver = [trackedEntity getX] - ([self getLeftEdge] + [self getEdgeThreshold]);
            }
            
            if ([trackedEntity getY] > [self getTopEdge] - [self getEdgeThreshold]) {
                yOver = [trackedEntity getY] - ([self getTopEdge] - [self getEdgeThreshold]);
            } else if ([trackedEntity getY] < [self getBottomEdge] + [self getEdgeThreshold]) {
                yOver = [trackedEntity getY] - ([self getBottomEdge] + [self getEdgeThreshold]);
            }
            
            [self translateBy:b2Vec2(xOver, yOver)];
            break;
        }
        case CAMERA_MODE_MANUAL: {
            xOver = cos(moveAngle) * moveSpeed;
            yOver = sin(moveAngle) * moveSpeed;
            
            moveSpeed -= CAMERA_SLOWDOWN_SPEED;
            if (moveSpeed < 0) {
                moveSpeed = 0;
            }
            
            [self translateBy:b2Vec2(xOver, yOver)];
            break;
        }
        case CAMERA_MODE_SEEKING: {
            if (trackedEntity == nil) {
                return;
            } 
            // we're trying to catch up to the entity, so figure out where it is
            // and move towards it
            
            // when we get within a certain small threshold, snap out of trackingTo
            float32 dx = [trackedEntity getX] - [self getCenterX];
            float32 dy = [trackedEntity getY] - [self getCenterY];
            
            float32 angle = atan2f(dy, dx);
            
            xOver = cos(angle) * moveSpeed;
            yOver = sin(angle) * moveSpeed;
            
            [self translateBy:b2Vec2(xOver, yOver)];
            
            if ([self isEntityInShot: trackedEntity]) {
                mode = CAMERA_MODE_NORMAL;
            }
            break;
        }
    }
}

-(float32) getEdgeThreshold {
    if (edgeThreshold == 0.0) {  
        edgeThreshold = scale(CAMERA_EDGE_THRESHOLD);
    }
    return edgeThreshold;
}

-(b2Vec2) getDistanceRequiredToFocusVector:(b2Vec2)vector {
    b2Vec2 over;
    over.SetZero();
    float32 threshold = [self getEdgeThreshold];
    if (vector.x > [self getRightEdge] - threshold) {
        over.x = vector.x - ([self getRightEdge] - threshold);        
    } else if (vector.x < [self getLeftEdge] + threshold) {
        over.x = vector.x - ([self getLeftEdge] + threshold);
    }
    
    if (vector.y > [self getTopEdge] - threshold) {
        over.y = vector.y - ([self getTopEdge] - threshold);        
    } else if (vector.y < [self getBottomEdge] + threshold) {
        over.y = vector.y - ([self getBottomEdge] + threshold);
    }
    return over;
}

@end
