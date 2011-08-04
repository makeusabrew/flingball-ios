//
//  LevelLayer.h
//  Flingball
//
//  Created by Nicholas Payne on 06/07/2011.
//  Copyright Payne Digital Ltd 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "Ball.h"
#import "Level.h"
#import "Camera.h"

@interface LevelLayer : CCLayer
{
	GLESDebugDraw *m_debugDraw;
    
    // drag related logic, probably to be improved...
    CGPoint startDragLocation;
    CGPoint currentDragLocation;    
    BOOL isDragging;
    
    Level* level;
    Camera* camera;
    
    NSInteger cLevel;
    
    NSMutableArray* entitiesToDelete;
    NSMutableArray* storedTouches;
}

// returns a CCScene that contains the LevelLayer as the only child
+(CCScene *) scene: (NSInteger)levelIndex;
-(void) setLevel:(NSInteger)levelIndex;
-(void) ballAtGoal: (NSNotification*)notification;
-(void) ballHitPickup: (NSNotification*)notification;
-(void) loadEndLevel;
-(void) updateCamera;
-(CGPoint) adjustPointForCamera: (CGPoint)point;

@end
