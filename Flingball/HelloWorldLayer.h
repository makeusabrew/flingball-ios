//
//  HelloWorldLayer.h
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

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
	GLESDebugDraw *m_debugDraw;
    
    CGPoint startDragLocation;
    
    Level* level;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
