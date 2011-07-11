//
//  Level.h
//  Flingball
//
//  Created by Nicholas Payne on 11/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "Ball.h"

@interface Level : NSObject {
    NSString* title;
    NSString* author;
    
    NSInteger width;
    NSInteger height;
    
    b2Vec2 startPos;
    b2Vec2 gravity;
    
    b2World* world;
    Ball* ball;
}

@property (nonatomic, assign) b2World* world;
@property (nonatomic, retain) Ball* ball;

- (void)createBoundaries:(CGRect)rect;

@end