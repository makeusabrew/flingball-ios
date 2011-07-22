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

@synthesize scale;

- (id)init
{
    self = [super init];
    if (self) {
        mode = CAMERA_MODE_NORMAL;
        scale = 1.0;
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
    return position.x;
}

-(float) getRightEdge {
    return position.x + (width/scale);
}

-(float) getBottomEdge {
    return position.y;
}

-(float) getTopEdge {
    return position.y + (height/scale);
}

-(float) getCenterX {
    return position.x + ((width/scale) / 2);
}

-(float) getCenterY {
    return position.y + ((height/scale) / 2);
}

-(void) setViewport:(CGRect)viewport {    
    width = viewport.size.width;
    height = viewport.size.height;
    
    position.x = viewport.origin.x;
    position.y = viewport.origin.y;
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
    //NSLog(@"[%.2f, %.2f] [%.2f, %.2f], [%.2f, %.2f]", [self getLeftEdge], [self getBottomEdge], [self getRightEdge], [self getTopEdge], [self getCenterX], [self getCenterY]);
    float xOver = 0.0;
    float yOver = 0.0;
    
    switch (mode) {            
        case CAMERA_MODE_NORMAL: {
            if (trackedEntity == nil) {
                return;
            }
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

@end
