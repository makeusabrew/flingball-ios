//
//  Constants.h
//  Flingball
//
//  Created by Nicholas Payne on 08/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#ifndef Flingball_Constants_h
#define Flingball_Constants_h

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32.0f

#define CAMERA_EDGE_THRESHOLD 180

const float32 BALL_ROLLING_FRICTION = 0.04f;

#endif
