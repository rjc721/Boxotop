//
//  OmdbIDResponse.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/22/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//
//  This search result characterizes the second type of OMDB search:
//  a search by unique IMDB ID

import Foundation

struct OmdbIDResponse: Decodable {
    
    let Title: String
    let Released: String
    let Director: String
    let Actors: String
    let Metascore: String
    let imdbRating: String
    let Plot: String
    let Rated: String
    let Writer: String
    let Ratings: [RatingType]
    let Poster: String?
    let Response: String
}

struct RatingType: Decodable {
    let Source: String?
    let Value: String?
}
