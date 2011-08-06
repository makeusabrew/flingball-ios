//
//  LevelLayer.mm
//  Flingball
//
//  Created by Nicholas Payne on 06/07/2011.
//  Copyright Payne Digital Ltd 2011. All rights reserved.
//

#import "LevelLayer.h"
#import "Constants.h"
#import "Level.h"
#import "SimpleAudioEngine.h"
#import "EndLevelLayer.h"
#import "GameState.h"
#import "HUDLayer.h"

@implementation LevelLayer

#pragma mark dealloc

- (void) dealloc
{
    CCLOG(@"LevelLayer::dealloc");
    
    [self removeAllChildrenWithCleanup: YES];
	
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"levelLoaded" object:nil];
	
	delete m_debugDraw;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark Scene initialisation methods

+(CCScene *) scene:(NSInteger)levelIndex
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LevelLayer *layer = [LevelLayer node];
    
    [layer setLevel:levelIndex];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
    HUDLayer* hudLayer = [HUDLayer node];
    
    // make sure we tag the HUD layer so we can retrieve it layer
    [scene addChild: hudLayer z: 1 tag: TAG_HUD_LAYER];
	
	// return the scene
	return scene;
}

+(CCScene*) sceneWithKey:(NSString *)key andIdentifier:(NSInteger)identifier {
    // ooh, dev mode you say?
    
	CCScene *scene = [CCScene node];
    LevelLayer *layer = [LevelLayer node];
    
    [layer setLevelWithKey: key andIdentifier: identifier];
	
	[scene addChild: layer];
    
    HUDLayer* hudLayer = [HUDLayer node];    
    [scene addChild: hudLayer z: 1 tag: TAG_HUD_LAYER];	
	return scene;
}

#pragma mark init

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        CCLOG(@"Initialising new level");
		
		// enable touches
		self.isTouchEnabled = YES;
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"goal.wav"];
        
        // game logic initialisation
        level = [[Level alloc] init];
        camera = [[Camera alloc] init];
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
        
        [camera setViewport: CGRectMake(0, 0, screenSize.width, screenSize.height)];
        
        entitiesToDelete = [[NSMutableArray alloc] init];
        storedTouches = [[NSMutableArray alloc] init];
        
        [[GameState sharedGameState] reset]; 
        // we need to cache the individual sprites before any of their init methods
        // are called within loadLevel
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"levelAtlas.plist"];        
        
        // event listeners
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ballAtGoal:) name:@"ballAtGoal" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ballHitPickup:) name:@"ballHitPickup" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelLoaded:) name:@"levelLoaded" object:nil];
        
	}
	return self;
}

#pragma mark -
#pragma mark Main class methods

-(void) setLevel:(NSInteger)levelIndex {
    CCLOG(@"Setting level Index %d", levelIndex);
    isDevMode = NO;
    cLevel = levelIndex;
    [[GameState sharedGameState] updateKey: @"currentLevel" withInt: levelIndex];
    
    [level loadLevel:levelIndex];
    [self doLevelInitialisation];
}

-(void) setLevelWithKey:(NSString *)key andIdentifier:(NSInteger)identifier {
    CCLOG(@"Setting level with key %@ and identifier %d", key, identifier);
    
    isDevMode = YES;
    cLevel = -1;
    
    [[GameState sharedGameState] updateKey: @"apiKey" withValue: key];
    [[GameState sharedGameState] updateKey: @"apiIdentifier" withInt: identifier];
    
    [level loadLevelWithKey: key andIdentifier: identifier];
    [self doLevelInitialisation];
}

-(void) doLevelInitialisation {
    CCLOG(@"proceeding with level init");
    [camera trackEntity:level.ball];
    // force the camera into the correct position
    [self updateCamera];
    
    [[GameState sharedGameState] updateKey: @"levelTitle" withValue: [level getTitle]];
    [[GameState sharedGameState] updateKey: @"isDevMode" withBool: isDevMode];
    
    // loop through all the world bodies - if any are SpriteEntity objects
    // then we want to add their sprites to this layer
    
    CCLOG(@"adding level sprites");
    CCSpriteBatchNode* levelSprites = [CCSpriteBatchNode batchNodeWithFile:@"levelAtlas.png"];
    for (b2Body* b = level.world->GetBodyList(); b; b = b->GetNext()) {
        
		if (b->GetUserData() != NULL) {            
			Entity *myEntity = (Entity*)b->GetUserData();
            if ([myEntity isKindOfClass: [SpriteEntity class]]) {
                // excellent, got a sprite?
                SpriteEntity *spriteEntity = (SpriteEntity*)myEntity;
                if (spriteEntity.sprite) {
                    //[self addChild: spriteEntity.sprite];
                    [levelSprites addChild: spriteEntity.sprite];
                    // manually update the position of the entity so it draws correctly
                    // before the first tick happens
                    CCLOG(@"setting up entity %@", NSStringFromClass([myEntity class]));
                    [spriteEntity updateBody:b];
                } else {
                    CCLOG(@"ignoring uninitialised sprite for %@", NSStringFromClass([myEntity class]));
                }
            }
		
        }
	}
    [self addChild: levelSprites z: 0 tag: TAG_LEVEL_SPRITES];
    
    // Debug Draw functions
    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
    level.world->SetDebugDraw(m_debugDraw);
    
    uint32 flags = 0;
    flags += b2DebugDraw::e_shapeBit;
    m_debugDraw->SetFlags(flags);
    
    [self schedule: @selector(tick:)];
}

-(CGPoint) adjustPointForCamera: (CGPoint)point {
    // right then! We need to work out where this touch is relative
    // to the camera and based on our current scale
    // first of all, we want to 'center' the touch position
    // so we take off half the screen dimensions
    // then we divide by the scale to scale out this value
    // then, we have to adjust the position based on the camera's centre
    // and last of all we just shift the touch back to where it was
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    float screenX = screenSize.width / 2.0;
    float screenY = screenSize.height / 2.0;
    
    point.x = ((point.x - screenX) / [camera scale]) + [camera getCenterX];
    point.y = ((point.y - screenY) / [camera scale]) + [camera getCenterY];
    
    return point;
}

-(void) loadEndLevel {
    CCLOG(@"Switching scene to end level %d", cLevel);
    // great! load the end level scene.
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:1.0f scene:[EndLevelLayer scene:cLevel]]];
}

-(void) updateCamera {    
    // update the camera class - it's been set up (in setLevel) to track the
    // level's ball entity
    [camera update];
    
    // sync cocos2d's camera with our own
    [self.camera setEyeX:([camera getCenterX] - [camera offsetX]) eyeY:([camera getCenterY] - [camera offsetY]) eyeZ:1];
    [self.camera setCenterX:([camera getCenterX] - [camera offsetX]) centerY:([camera getCenterY] - [camera offsetY]) centerZ:0];
    
    self.scale = camera.scale;
}

#pragma mark -
#pragma mark Draw method

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
        
        // draw a simple projection from ball
        // @see https://projects.paynedigital.com/issues/219
        if (currentDragLocation.x != startDragLocation.x ||
            currentDragLocation.y != startDragLocation.y) {
            
            float32 dx = currentDragLocation.x - startDragLocation.x;
            float32 dy = currentDragLocation.y - startDragLocation.y;        
            float32 a = atan2(dy, dx);
        
        
            glColor4f(1.0, 0.0, 0.0, 1.0);
            for (float32 i = FLING_PROJECTION_OFFSET; i < FLING_PROJECTION_DISTANCE; i += FLING_PROJECTION_GAP) {
                float32 drawX = [level.ball getX] - (cos(a) * i);
                float32 drawY = [level.ball getY] - (sin(a) * i);
                ccDrawCircle(ccp(drawX, drawY), FLING_PROJECTION_RADIUS, CC_DEGREES_TO_RADIANS(360), 60, NO);
            }
        }
    }
    /*
    glColor4f(1.0, 0.0, 0.0, 1.0);
    CGPoint vertices[] = {
        ccp([camera getLeftEdge], [camera getBottomEdge]), 
        ccp([camera getRightEdge], [camera getBottomEdge]),
        ccp([camera getRightEdge], [camera getTopEdge]),
        ccp([camera getLeftEdge], [camera getTopEdge])
    };
    ccDrawPoly(vertices, 4, YES);
    glColor4f(1.0, 0.0, 0.0, 1.0);
    ccDrawCircle(ccp([camera getCenterX], [camera getCenterY]), 32, CC_DEGREES_TO_RADIANS(360), 60, NO);
     */
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}

#pragma mark Main game loop

-(void) tick: (ccTime) dt
{
    // before anything, let's clean up any objects which need deleting
    if ([entitiesToDelete count] > 0) {
        CCSpriteBatchNode* sprites = (CCSpriteBatchNode *)[self getChildByTag: TAG_LEVEL_SPRITES];
        if (sprites == nil) {
            CCLOG(@"sprite is nil");
        }
    
        for (Entity* object in entitiesToDelete) {
            CCLOG(@"removing object marked for deletion");
            if ([object isKindOfClass: [SpriteEntity class]]) {
                SpriteEntity* spriteEntity = (SpriteEntity*) object;
                CCLOG(@"removing sprite");
                [sprites removeChild: spriteEntity.sprite cleanup:YES];
            }
            level.world->DestroyBody([object getBody]);
        }
        [entitiesToDelete removeAllObjects];
    }
    
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
            //CCLOG(@"updating entity %@", NSStringFromClass([myEntity class]));
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

#pragma mark Touch handlers

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [storedTouches addObjectsFromArray: [touches allObjects]];
    
    //CCLOG(@"touch count %d", [storedTouches count]);
    
    switch ([storedTouches count]) {
        case 1: {
            UITouch* touch = [[touches allObjects] objectAtIndex:0];
            CGPoint origPosition = [touch locationInView: [touch view]];
            
            origPosition = [[CCDirector sharedDirector] convertToGL: origPosition];
            
            // we *have* to convert the start location to a real world coordinate,
            // other wise it becomes a PITA later if the drag moves the camera
            CGPoint touchPosition = [self adjustPointForCamera: origPosition];
            
            b2Vec2 ballPos = [level.ball getPosition];
            float32 radius = [level.ball radius];
            
            if ([level.ball canFling] &&
                touchPosition.x > (ballPos.x - radius) && 
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
                touchPosition = [self adjustPointForCamera: touchPosition];
                
                float32 dx = touchPosition.x - startDragLocation.x;
                float32 dy = touchPosition.y - startDragLocation.y;
                float32 dist = sqrt((dx*dx) + (dy*dy));
                
                // scale max dist
                float32 maxDist = scale(MAX_DRAG_DISTANCE);
                
                if (dist > maxDist) {
                    dist = maxDist;
                }
                
                // now, get the angle between touchPos and startPos, and calculate
                // that * dist as our line
                // @see https://projects.paynedigital.com/issues/101
                
                float a = atan2(dy, dx);
                currentDragLocation.x = startDragLocation.x + (cos(a) * dist);
                currentDragLocation.y = startDragLocation.y + (sin(a) * dist);
                
                // render the fling %ge power
                // @see https://projects.paynedigital.com/issues/179
                // @see https://projects.paynedigital.com/issues/195
                int flingPc = round((dist / maxDist) * 100);
                
                // grab the hud layer and update it
                HUDLayer* hudLayer = (HUDLayer*) [[[CCDirector sharedDirector] runningScene] getChildByTag: TAG_HUD_LAYER];                
                [hudLayer setFlingPower: flingPc];
                
                b2Vec2 distRequired = [camera getDistanceRequiredToFocusVector: b2Vec2(currentDragLocation.x, currentDragLocation.y)];
                
                if (distRequired.x != 0.0 || distRequired.y != 0.0) {
                    // detach from the ball
                    [camera trackEntity: nil];
                    [camera translateBy: distRequired];
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
            // @see https://projects.paynedigital.com/issues/98
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
            
            //CCLOG(@"zIndex %.2f, new dist %.2f", camera.zIndex, (currentDistance - previousDistance));
            
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
                
                location = [self adjustPointForCamera: location];
                
                float dx = location.x - startDragLocation.x;
                float dy = location.y - startDragLocation.y;
                float dist = sqrt((dx*dx) + (dy*dy));
                float maxDist = scale(MAX_DRAG_DISTANCE);
                
                if (dist > maxDist) {
                    dist = maxDist;
                }
                float distPc = dist / maxDist;
                float vel = distPc * MAX_FLING_VELOCITY;
                
                CCLOG(@"drag distance %.2f (pc %.2f)", dist, distPc);                
                CCLOG(@"total fling velocity %.2f", vel);
                
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
                    CCLOG(@"fling velocity [%.2f, %.2f]", v.x, v.y);
                    
                    // since we're about to fling, track the ball again (if we weren't already)
                    [camera seekToEntity:level.ball];
                    [level.ball fling:v];
                    if ([[GameState sharedGameState] getValueAsInt: @"ballFlings"] == 1) {
                        // first fling, so start timer
                        [[GameState sharedGameState] updateKey: @"levelStarted" withBool: YES];
                        [[GameState sharedGameState] updateKey: @"startTime" withDouble: [NSDate timeIntervalSinceReferenceDate]];
                        CCLOG(@"start time %.2f", [[GameState sharedGameState] getValueAsDouble: @"startTime"]);
                    }
                }
                
                // @see https://projects.paynedigital.com/issues/179
                HUDLayer* hudLayer = (HUDLayer*) [[[CCDirector sharedDirector] runningScene] getChildByTag: TAG_HUD_LAYER];
                [hudLayer flingFinished];
                
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
    
    //CCLOG(@"touch count %d", [storedTouches count]);
}

#pragma mark Event Callbacks

-(void) ballAtGoal:(NSNotification *)notification {
    if (level.ball.atGoal) {
        return;
    }
    level.ball.atGoal = true;
    [[SimpleAudioEngine sharedEngine] playEffect:@"goal.wav"];
    CCLOG(@"At goal!");
    
    [[GameState sharedGameState] updateKey: STATE_ENDTIME withDouble: [NSDate timeIntervalSinceReferenceDate]];
    CCLOG(@"end time %.2f", [[GameState sharedGameState] getValueAsDouble: STATE_ENDTIME]);
    
    // check for achievement stuff
    if ([[GameState sharedGameState] getValueAsInt: STATE_BOUNCES] == 0 &&
        [[GameState sharedGameState] getAchievementPercentage: ACHIEVEMENT_NO_BOUNCES] == 0.0) {
        // woohoo! well done!
        CCLOG(@"got no bounce achievement!");
        [[GameState sharedGameState] reportAchievementIdentifier: ACHIEVEMENT_NO_BOUNCES percentComplete:100.0];
    }
    
    id action1 = [CCDelayTime actionWithDuration:3.0];
    id action2 = [CCCallFunc actionWithTarget:self selector:@selector(loadEndLevel)];
    [self runAction:[CCSequence actions:action1, action2, nil]];
}

-(void) ballHitPickup:(NSNotification *)notification {
    CCLOG(@"pickup callback");
    
    // we can't just delete the pickup (sprite, body etc) here, because
    // we don't know when this event handler was actually triggered
    // instead, we need to schedule the pickup to be deleted on the next tick
    // when we know that the world won't be mid simulation or anything :)
    Pickup *pickup = (Pickup*)[notification object];
    if (pickup.dead) {
        return;
    }
    pickup.dead = YES;
    [entitiesToDelete addObject:pickup];     
}

-(void) levelLoaded:(NSNotification *)notification {
    CCLOG(@"level loaded callback");
    // DO NOT USE FOR NOW! CAUSES MEMORY ISSUES
    //[self doLevelInitialisation];
}

@end
