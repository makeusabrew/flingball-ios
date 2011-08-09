//
//  Vortex.h
//  Flingball
//
//  Created by Nicholas Payne on 09/08/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//  @see https://projects.paynedigital.com/issues/223

#import "CircleEntity.h"

@interface Vortex : CircleEntity {
    float32 pullStrength;
}

@property float32 pullStrength;

@end
