//
//  Constants.h
//  Flingball
//
//  Created by Nicholas Payne on 08/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#ifndef Flingball_Constants_h
#define Flingball_Constants_h
#import "Box2D.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
const float32 PTM_RATIO = 32.0f;

// any pixel values here are defined for a resolution of 1024x768
// therefore, they will be scaled appropriately if shown on anything else
// (e.g. iPhone)
const float32 TARGET_WIDTH = 1024;
const float32 TARGET_HEIGHT = 768;

// handy iPhone / iPad scale converter
#define scale(x) (x * ([CCDirector sharedDirector].winSize.width / TARGET_WIDTH))

const float32 BALL_ROLLING_FRICTION = 0.04f;

const int CAMERA_EDGE_THRESHOLD = 180.0;
const int CAMERA_DRAG_EDGE_THRESHOLD = 90.0;

const float32 MAX_DRAG_DISTANCE = 300.0;
const float32 MAX_FLING_VELOCITY = 120.0f;  // m/s?
//const float32 DIST_TO_FLING_FACTOR = MAX_FLING_VELOCITY / MAX_DRAG_DISTANCE;

const float32 DEFAULT_CAMERA_SEEK_SPEED = 30.0;
const float32 CAMERA_SLOWDOWN_SPEED = 0.45;

const int CAMERA_MODE_NORMAL = 0;
const int CAMERA_MODE_SEEKING = 1;
const int CAMERA_MODE_MANUAL = 2;

const float32 MIN_CAMERA_ZEYE = 0.000001f;
const float32 MAX_CAMERA_ZEYE = 1.0f;
const float32 MAX_CAMERA_SCALE = 1.0;
const float32 MIN_CAMERA_SCALE = 0.25;

const float32 FLING_SPEED_THRESHOLD = 0.25f;

const float32 DEFAULT_GOAL_RADIUS = 64.0f;
const float32 DEFAULT_BALL_RADIUS = 32.0f;

const float32 FLING_POWER_OFFSET = 75.0;

const int TAG_HUD_LAYER = 1;
const int TAG_LEVEL_SPRITES = 2;

#endif
