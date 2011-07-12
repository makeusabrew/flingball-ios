//
//  SpriteEntity.h
//  Flingball
//
//  Created by Nicholas Payne on 12/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Entity.h"

@interface SpriteEntity : Entity {
    CCSprite* sprite;   // possibly move this out, do base entities need a sprite?
}

@property (assign) CCSprite* sprite;

-(void) setSpritePosition: (b2Vec2)_position withAngle:(float)angle;

@end
