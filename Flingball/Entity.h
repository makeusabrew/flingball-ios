//
//  Entity.h
//  Flingball
//
//  Created by Nicholas Payne on 08/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "cocos2d.h"

@interface Entity : NSObject
{
    b2Body* body;
    CCSprite* sprite;   // possibly move this out, do base entities need a sprite?
}

@property (assign) CCSprite* sprite;

@end
