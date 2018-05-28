//
//  OmdbResponseToS.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/22/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//
//  We perform two types of queries to Open Movie Database
//  (OMDB). The first type uses a search parameter of "S"
//  to search films by title. The results give us the IMDB
//  unique identifier (imdbID) which is more reliable.

import Foundation

struct OmdbResponseToS: Decodable {
    let Search: [OmdbSFilmResult]
    let totalResults: String
    let Response: String
}

struct OmdbSFilmResult: Decodable {
    let Title: String
    let Year: String
    let imdbID: String
}
