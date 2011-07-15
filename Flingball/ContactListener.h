//
//  ContactListener.h
//  Flingball
//
//  Created by Nicholas Payne on 11/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Box2D.h"
#import <vector>
#import <algorithm>

using namespace std;

struct Contact {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    bool isNew;
    bool operator==(const Contact& other) const {
        return (fixtureA == other.fixtureA && fixtureB == other.fixtureB);
    }
};

class ContactListener : public b2ContactListener {
public:
    vector<Contact>_contacts;
    
    ContactListener();
    ~ContactListener();
    
    virtual void BeginContact(b2Contact* contact);
    virtual void EndContact(b2Contact* contact);
    virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);    
    virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
};
