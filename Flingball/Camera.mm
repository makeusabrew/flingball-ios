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
        // Initialization code here.
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

-(void) setViewport:(CGRect)viewport {
    position.x = viewport.origin.x;
    position.y = viewport.origin.y;
    
    width = viewport.size.width;
    height = viewport.size.height;
}

-(void) trackEntity:(Entity *)entity {
    trackedEntity = entity;
}

-(void) update {
    if (trackedEntity == NULL) {
        return;
    }

    float xOver = 0.0;
    float yOver = 0.0;
    
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

@end
