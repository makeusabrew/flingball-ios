//
//  Camera.h
//  Flingball
//
//  Created by Nicholas Payne on 11/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"

@interface Camera : NSObject {
    b2Vec2 position;
    
    NSInteger width;
    NSInteger height;
}

-(void) translateBy: (b2Vec2)vector;
-(void) translateTo: (b2Vec2)vector;
- (float)getX;
- (float)getY;
//-(void) setViewport: (CGRect)viewport;

@end
