//
//  Film.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/14/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import Foundation
import RealmSwift

class Film: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var plot: String = ""
    @objc dynamic var imdbRating: Double = 0.0
    @objc dynamic var criticRating: Double = 0.0
    @objc dynamic var userRating: Double = 0.0
    @objc dynamic var releaseDate: String = ""
    @objc dynamic var director: String = ""
    @objc dynamic var writer: String = ""
    @objc dynamic var ratingMPAA: String = ""
    @objc dynamic var cast: String = ""
}
