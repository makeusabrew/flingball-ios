//
//  ContactListener.mm
//  Flingball
//
//  Created by Nicholas Payne on 11/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "ContactListener.h"

using namespace std;

ContactListener::ContactListener() : _contacts() {
    
}

ContactListener::~ContactListener() {
    
}


void ContactListener::BeginContact(b2Contact *contact) {
    Contact _contact = {
        contact->GetFixtureA(),
        contact->GetFixtureB(),
        true,
        false
    };
    
    _contacts.push_back(_contact);
}

void ContactListener::EndContact(b2Contact *contact) {
    Contact _contact = {
        contact->GetFixtureA(),
        contact->GetFixtureB(),
        false,
        true
    };
    
    vector<Contact>::iterator pos;
    pos = find(_contacts.begin(), _contacts.end(), _contact);
    if (pos != _contacts.end()) {
        pos->isEnding = true;
        //_contacts.erase(pos);
    }
}

void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
    
}

void ContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
    
}