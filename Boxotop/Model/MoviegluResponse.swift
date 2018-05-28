//
//  MoviegluResponse.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/22/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//
//  The response from the Movieglu API request is modeled
//  by the struct MoviegluResponse. It contains an array of
//  films characterized by MoviegluFilm and a status response
//  we want to check to verify a good response.

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
