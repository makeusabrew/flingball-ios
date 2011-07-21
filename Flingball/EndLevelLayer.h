//
//  EndLevelLayer.h
//  Flingball
//
//  Created by Nicholas Payne on 06/07/2011.
//  Copyright Payne Digital Ltd 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "GLES-Render.h"
#import "Level.h"

@interface EndLevelLayer : CCLayer
{
	GLESDebugDraw *m_debugDraw;
    
    NSInteger cLevel;
}

// returns a CCScene that contains the EndLevelLayer as the only child
+(CCScene *) scene: (NSInteger)levelIndex;
-(void) setLevel: (NSInteger)levelIndex;

@end
