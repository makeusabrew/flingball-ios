//
//  ContactListener.mm
//  Flingball
//
//  Created by Nicholas Payne on 11/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "ContactListener.h"
#import "Entity.h"

using namespace std;

ContactListener::ContactListener() : _contacts() {
    
}

ContactListener::~ContactListener() {
    
}


void ContactListener::BeginContact(b2Contact *contact) {
    Contact _contact = {
        contact->GetFixtureA(),
        contact->GetFixtureB()
    };
    
    // the only alternative I can think of is to have some concept of the
    // current level, and push these contacts onto a stack
    // at the start of a tick, we'd empty the stack, so by the end of a
    // tick we'd know whatever in it was "new"
    // but that opens up too much state to this class IMO
    // to be honest, even having the entities in here isn't ideal because
    // everything should just be dealt with outside here.
    // what we could do instead is is add a 'new' member variable to Contact
    // and then process it in tick... hmm
    Entity* entityA = (Entity*)_contact.fixtureA->GetBody()->GetUserData();
    Entity* entityB = (Entity*)_contact.fixtureB->GetBody()->GetUserData();
    
    [entityA onCollisionStart: entityB];
    [entityB onCollisionStart: entityA];
    
    _contacts.push_back(_contact);
}

void ContactListener::EndContact(b2Contact *contact) {
    Contact _contact = {
        contact->GetFixtureA(),
        contact->GetFixtureB()
    };
    
    Entity* entityA = (Entity*)_contact.fixtureA->GetBody()->GetUserData();
    Entity* entityB = (Entity*)_contact.fixtureB->GetBody()->GetUserData();
    
    [entityA onCollisionEnd: entityB];
    [entityB onCollisionEnd: entityA];
    
    vector<Contact>::iterator pos;
    pos = find(_contacts.begin(), _contacts.end(), _contact);
    if (pos != _contacts.end()) {
        _contacts.erase(pos);
    }
}

void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
    
}

void ContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
    
}