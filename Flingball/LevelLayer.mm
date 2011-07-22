//
//  LevelLayer.mm
//  Flingball
//
//  Created by Nicholas Payne on 06/07/2011.
//  Copyright Payne Digital Ltd 2011. All rights reserved.
//


// Import the interfaces
#import "LevelLayer.h"
#import "Constants.h"
#import "Level.h"
#import "SimpleAudioEngine.h"
#import "EndLevelLayer.h"
#import "GameStatistics.h"

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


// LevelLayer implementation
@implementation LevelLayer

+(CCScene *) scene:(NSInteger)levelIndex
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LevelLayer *layer = [LevelLayer node];
    
    [layer setLevel:levelIndex];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        NSLog(@"Initialising new level");
		
		// enable touches
		self.isTouchEnabled = YES;
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"goal.wav"];
        
        // game logic initialisation
        level = [[Level alloc] init];
        camera = [[Camera alloc] init];
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
        
        [camera setViewport: CGRectMake(0, 0, screenSize.width, screenSize.height)];
        
        //NSLog(@"camera Z %.8f", [CCCamera getZEye]);
        
        entitiesToDelete = [[NSMutableArray alloc] init];
        storedTouches = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) setLevel:(NSInteger)levelIndex {
    NSLog(@"Setting level Index %d", levelIndex);
    
    [[GameStatistics sharedGameStatistics] reset];
    
    cLevel = levelIndex;
    [level loadLevel:levelIndex];      
    [camera trackEntity:level.ball];
    // force the camera into the correct position
    [self updateCamera];
    
    // event listeners
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ballAtGoal:) name:@"ballAtGoal" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ballHitPickup:) name:@"ballHitPickup" object:nil];
    
    // loop through all the world bodies - if any are SpriteEntity objects
    // then we want to add their sprites to this layer
    for (b2Body* b = level.world->GetBodyList(); b; b = b->GetNext()) {
        
		if (b->GetUserData() != NULL) {            
			Entity *myEntity = (Entity*)b->GetUserData();
            if ([myEntity isKindOfClass: [SpriteEntity class]]) {
                // excellent, got a sprite?
                SpriteEntity *spriteEntity = (SpriteEntity*)myEntity;
                if (spriteEntity.sprite) {
                    [self addChild: spriteEntity.sprite];
                    // manually update the position of the entity so it draws correctly
                    // before the first tick happens
                    [spriteEntity updateBody:b];
                }
            }
		}
	}
    
    // Debug Draw functions
    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
    level.world->SetDebugDraw(m_debugDraw);
    
    uint32 flags = 0;
    flags += b2DebugDraw::e_shapeBit;
    m_debugDraw->SetFlags(flags);
    
    [self schedule: @selector(tick:)];
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	level.world->DrawDebugData();
    
    if (isDragging) {
        // crude drag path
        
        glColor4f(1.0, 1.0, 1.0, 1.0);
        glLineWidth(2.0);
        // the locations have already been adjusted for camera offset
        ccDrawLine(startDragLocation, currentDragLocation);
        glLineWidth(1.0);
    }
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}

#pragma mark main game loop

-(void) tick: (ccTime) dt
{
    // before anything, let's clean up any objects which need deleting
    for (Entity* object in entitiesToDelete) {
        NSLog(@"removing object marked for deletion");
        if ([object isKindOfClass: [SpriteEntity class]]) {
            SpriteEntity* spriteEntity = (SpriteEntity*) object;
            NSLog(@"removing sprite");
            [self removeChild: spriteEntity.sprite cleanup:YES];           
        }
        level.world->DestroyBody([object getBody]);
    }
    [entitiesToDelete removeAllObjects];
    
    // now things can carry on as normal
    
   	int32 velocityIterations = 10;
	int32 positionIterations = 10;
    float32 timestep = 1.0f / 60.0f;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.    
	level.world->Step(timestep, velocityIterations, positionIterations);

	
	//Iterate over the bodies in the physics world
	for (b2Body* b = level.world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {            
            // bear in mind that obviously different sub classes of Entity
            // will implement their own version of updateBody
			Entity *myEntity = (Entity*)b->GetUserData();
            [myEntity updateBody:b];
		}
	}
    
    // process contacts
    std::vector<Contact>::iterator pos = level.contactListener->_contacts.begin();
    
    // we can't use a for because of the two ways we might alter pos
    while (pos != level.contactListener->_contacts.end()) {
        //Contact contact = *pos;
        Entity* entityA = (Entity*) pos->fixtureA->GetBody()->GetUserData();
        Entity* entityB = (Entity*) pos->fixtureB->GetBody()->GetUserData();
        
        // new contact?
        if (pos->isNew) {            
            [entityA onCollisionStart: entityB];
            [entityB onCollisionStart: entityA];            
            // remember, we need to update the actual contact, not our copy of it
            pos->isNew = false;
        }
        
        [entityA onCollision:entityB];
        [entityB onCollision:entityA];
        
        // contact over?
        if (pos->isEnding) {
            [entityA onCollisionEnd: entityB];
            [entityB onCollisionEnd: entityA];
            
            // re-assign the pointer since it'll be invalidated after the .erase()
            pos = level.contactListener->_contacts.erase(pos);
        } else {
            // under normal circumstances, simply iterate to the next contact
            ++pos;
        }
    }

    [self updateCamera];
}

#pragma mark touch handlers

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [storedTouches addObjectsFromArray: [touches allObjects]];
    
    NSLog(@"touch count %d", [storedTouches count]);
    
    switch ([storedTouches count]) {
        case 1: {
            UITouch* touch = [[touches allObjects] objectAtIndex:0];
            CGPoint touchPosition = [touch locationInView: [touch view]];
            
            touchPosition = [[CCDirector sharedDirector] convertToGL: touchPosition];
            
            // we *have* to convert the start location to a real world coordinate,
            // other wise it becomes a PITA later if the drag moves the camera
            touchPosition.x += [camera getLeftEdge];
            touchPosition.y += [camera getBottomEdge];
            
            b2Vec2 ballPos = [level.ball getPosition];
            float32 radius = [level.ball radius];
            
            if (touchPosition.x > (ballPos.x - radius) && 
                touchPosition.x < (ballPos.x + radius) &&
                touchPosition.y > (ballPos.y - radius) && 
                touchPosition.y < (ballPos.y + radius)) {
                
                float32 dx = ballPos.x - touchPosition.x;
                float32 dy = ballPos.y - touchPosition.y;
                float32 dist = sqrt((dx*dx) + (dy*dy));
                
                if (dist < [level.ball radius]) {    
                    currentDragLocation = startDragLocation = touchPosition;
                    isDragging = YES;
                }
            }
            break;
        }
        case 2: {
            // ?
            break;
        }
    }  
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    switch ([storedTouches count]) {
        case 1: {
            UITouch* touch = [touches anyObject];
            CGPoint touchPosition = [touch locationInView:[touch view]];
            touchPosition = [[CCDirector sharedDirector] convertToGL: touchPosition];
            if (isDragging) {        
                touchPosition.x += [camera getLeftEdge];
                touchPosition.y += [camera getBottomEdge];
                
                float32 dx = touchPosition.x - startDragLocation.x;
                float32 dy = touchPosition.y - startDragLocation.y;
                float32 dist = sqrt((dx*dx) + (dy*dy));
                
                if (dist < MAX_DRAG_DISTANCE) {
                    currentDragLocation = touchPosition;
                }
                
                
                // @todo let's look at refactoring all this stuff into the camera object
                // itself
                float xOver = 0.0;
                float yOver = 0.0;
                
                if (currentDragLocation.x > [camera getRightEdge] - CAMERA_DRAG_EDGE_THRESHOLD) {
                    xOver = currentDragLocation.x - ([camera getRightEdge] - CAMERA_DRAG_EDGE_THRESHOLD);        
                } else if (currentDragLocation.x < [camera getLeftEdge] + CAMERA_DRAG_EDGE_THRESHOLD) {
                    xOver = currentDragLocation.x - ([camera getLeftEdge] + CAMERA_DRAG_EDGE_THRESHOLD);
                }
                
                if (currentDragLocation.y > [camera getTopEdge] - CAMERA_DRAG_EDGE_THRESHOLD) {
                    yOver = currentDragLocation.y - ([camera getTopEdge] - CAMERA_DRAG_EDGE_THRESHOLD);        
                } else if (currentDragLocation.y < [camera getBottomEdge] + CAMERA_DRAG_EDGE_THRESHOLD) {
                    yOver = currentDragLocation.y - ([camera getBottomEdge] + CAMERA_DRAG_EDGE_THRESHOLD);
                }
                
                if (xOver != 0.0 || yOver != 0.0) {
                    // detach from the ball
                    [camera trackEntity:nil];
                    [camera translateBy:b2Vec2(xOver, yOver)];
                }
            } else {
                // hey ho, detach the camera
                CGPoint prevPosition = [touch previousLocationInView: [touch view]];
                prevPosition = [[CCDirector sharedDirector] convertToGL: prevPosition];
                
                // note that it's important that we subtract the *current* position
                // from the *previous* (not the other way round) - otherwise the camera
                // tracks the inverse direction
                float32 dx = prevPosition.x - touchPosition.x;
                float32 dy = prevPosition.y - touchPosition.y;
                b2Vec2 diff = b2Vec2(dx, dy);
                
                [camera trackEntity: nil];
                [camera translateBy:diff];
            }
            break;
        }
        case 2: {
            // ah, interesting. zoom the camera
            UITouch* touch1 = [storedTouches objectAtIndex:0];
            UITouch* touch2 = [storedTouches objectAtIndex:1];
            
            CGPoint touchPosition1 = [touch1 locationInView:[touch1 view]];
            touchPosition1 = [[CCDirector sharedDirector] convertToGL: touchPosition1];
            
            CGPoint touchPosition2 = [touch2 locationInView:[touch2 view]];
            touchPosition2 = [[CCDirector sharedDirector] convertToGL: touchPosition2];
            
            float32 dx = touchPosition1.x - touchPosition2.x;
            float32 dy = touchPosition1.y - touchPosition2.y;
            
            float32 currentDistance = sqrt((dx*dx) + (dy*dy));
            
            touchPosition1 = [touch1 previousLocationInView:[touch1 view]];
            touchPosition1 = [[CCDirector sharedDirector] convertToGL: touchPosition1];
            
            touchPosition2 = [touch2 previousLocationInView:[touch2 view]];
            touchPosition2 = [[CCDirector sharedDirector] convertToGL: touchPosition2];
            
            dx = touchPosition1.x - touchPosition2.x;
            dy = touchPosition1.y - touchPosition2.y;
            
            float32 previousDistance = sqrt((dx*dx) + (dy*dy));
            
            //NSLog(@"zIndex %.2f, new dist %.2f", camera.zIndex, (currentDistance - previousDistance));
            
            camera.scale += (currentDistance - previousDistance) / 500;
            
            if (camera.scale < MIN_CAMERA_SCALE) {
                camera.scale = MIN_CAMERA_SCALE;
            } else if (camera.scale > MAX_CAMERA_SCALE) {
                camera.scale = MAX_CAMERA_SCALE;
            }
            
            break;
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
	UITouch* touch = [[touches allObjects] objectAtIndex:0];
    
    switch ([storedTouches count]) {
        case 1: {
            if (isDragging) {
                
                CGPoint location = [touch locationInView: [touch view]];
                
                location = [[CCDirector sharedDirector] convertToGL: location];
                
                location.x += [camera getLeftEdge];
                location.y += [camera getBottomEdge];
                
                float dx = location.x - startDragLocation.x;
                float dy = location.y - startDragLocation.y;
                float dist = sqrt((dx*dx) + (dy*dy));
                if (dist > MAX_DRAG_DISTANCE) {
                    dist = MAX_DRAG_DISTANCE;
                }
                NSLog(@"drag distance %.2f", dist);
                float vel = dist * DIST_TO_FLING_FACTOR;
                NSLog(@"total fling velocity %.2f", vel);
                
                b2Vec2 v;
                v.SetZero();
                
                if (dy < 0 && dx == 0) {	// straight up
                    v.x = 0;
                    v.y = -vel;
                } else if (dy > 0 && dx == 0) {	// straight down
                    v.x = 0;
                    v.y = vel;
                } else if (dx > 0 && dy == 0) {	// straight left
                    v.x = vel;
                    v.y = 0;
                } else if (dx < 0 && dy == 0) {	// straight right
                    v.x = -vel;
                    v.y = 0;
                } else if (dy < 0 && dx < 0) {	// bottom left of ball
                    float a = dy / dx;
                    a = atan(a);
                    v.x = cos(a) * vel;
                    v.y = sin(a) * vel;		
                } else if (dy < 0 && dx > 0) {	// bottom right of ball
                    float a = atan2(dy, dx);		
                    v.x = -(cos(a) * vel);
                    v.y = -(sin(a) * vel);
                }
                
                // only fling if we've got a velocity to apply        
                if (v.x != 0 || v.y != 0) {
                    NSLog(@"fling velocity [%.2f, %.2f]", v.x, v.y);
                    
                    // since we're about to fling, track the ball again (if we weren't already)
                    [camera seekToEntity:level.ball];
                    [level.ball fling:v];
                    if ([GameStatistics sharedGameStatistics].ballFlings == 1) {
                        // first fling, so start timer
                        [GameStatistics sharedGameStatistics].startTime = [NSDate timeIntervalSinceReferenceDate];
                        NSLog(@"start time %.2f", [GameStatistics sharedGameStatistics].startTime);
                    }
                }
                
                isDragging = NO;
            } else {
                // one drag let go means we were moving the camera - so add some
                // speed to it
                CGPoint touchPosition = [touch locationInView: [touch view]];
                touchPosition = [[CCDirector sharedDirector] convertToGL: touchPosition];
                
                CGPoint prevPosition = [touch previousLocationInView: [touch view]];
                prevPosition = [[CCDirector sharedDirector] convertToGL: prevPosition];
                
                // note that it's important that we subtract the *current* position
                // from the *previous* (not the other way round) - otherwise the camera
                // tracks the inverse direction
                float32 dx = prevPosition.x - touchPosition.x;
                float32 dy = prevPosition.y - touchPosition.y;
                float32 dist = sqrt((dx*dx) + (dy*dy));
                float32 angle = atan2(dy, dx);
                b2Vec2 diff = b2Vec2(dx, dy);
                
                [camera translateBy:diff withDistance:dist andAngle:angle];
            }
            break;
        }
    }    
    
    [storedTouches removeObjectsInArray: [touches allObjects]];
    
    NSLog(@"touch count %d", [storedTouches count]);
}

-(void) loadEndLevel {
    NSLog(@"Switching scene to end level %d", cLevel);
    // great! load the end level scene.
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionCrossFade transitionWithDuration:1.0f scene:[EndLevelLayer scene:cLevel]]];
}

-(void) updateCamera {    
    // update the camera class - it's been set up (in setLevel) to track the
    // level's ball entity
    [camera update];
    
    // sync cocos2d's camera with our own
    [self.camera setEyeX:[camera getLeftEdge] eyeY:[camera getBottomEdge] eyeZ:1];
    [self.camera setCenterX:[camera getLeftEdge] centerY:[camera getBottomEdge] centerZ:0];
    
    self.scale = camera.scale;
}

#pragma mark Event Callbacks

-(void) ballAtGoal:(NSNotification *)notification {
    if (level.ball.atGoal) {
        return;
    }
    level.ball.atGoal = true;
    [[SimpleAudioEngine sharedEngine] playEffect:@"goal.wav"];
    NSLog(@"At goal!");
    
    [GameStatistics sharedGameStatistics].endTime = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"end time %.2f", [GameStatistics sharedGameStatistics].endTime);
    
    id action1 = [CCDelayTime actionWithDuration:3.0];
    id action2 = [CCCallFunc actionWithTarget:self selector:@selector(loadEndLevel)];
    [self runAction:[CCSequence actions:action1, action2, nil]];
}

-(void) ballHitPickup:(NSNotification *)notification {
    NSLog(@"pickup callback");
    
    // we can't just delete the pickup (sprite, body etc) here, because
    // we don't know when this event handler was actually triggered
    // instead, we need to schedule the pickup to be deleted on the next tick
    // when we know that the world won't be mid simulation or anything :)
    Pickup *pickup = (Pickup*)[notification object];
    [entitiesToDelete addObject:pickup];     
}

#pragma mark dealloc

- (void) dealloc
{
    NSLog(@"LevelLayer::dealloc");
    for (b2Body* b = level.world->GetBodyList(); b; b = b->GetNext()) {
        
		if (b->GetUserData() != NULL) {            
			Entity *myEntity = (Entity*)b->GetUserData();
            if ([myEntity isKindOfClass: [SpriteEntity class]]) {
                // excellent, got a sprite?
                SpriteEntity *spriteEntity = (SpriteEntity*)myEntity;
                if (spriteEntity.sprite) {
                    NSLog(@"removing sprite from layer");
                    [self removeChild: spriteEntity.sprite cleanup:YES];
                }
            }
		}
	}
	
	[level release];
    level = nil;
    
    [camera release];
    camera = nil;
    
    [entitiesToDelete release];
    entitiesToDelete = nil;
    
    [storedTouches release];
    storedTouches = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ballAtGoal" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ballHitPickup" object:nil];
	
	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
