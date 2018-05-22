//
//  MoviegluResponse.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/22/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import Foundation

struct MoviegluResponse: Decodable {
    let films: [MoviegluFilm]
    let count: Int
    let status: MoviegluStatus
}

struct MoviegluFilm: Decodable {
    let film_name: String
}

struct MoviegluStatus: Decodable {
    let state: String
}
