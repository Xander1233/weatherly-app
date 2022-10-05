//
//  Session.swift
//  weatherly
//
//  Created by David Neidhart on 10.10.22.
//

import Foundation

struct Session {
    var user: User? = nil
    
    static var shared: Session = Session()
}
