//
//  SearchType.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/16/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//
//  Characterize the two types of searches we do of the
//  Open Movie Database (OMDB). The box office search is
//  performed with the results of the Movieglu API call.
//  The user search can be done on whatever the user enters
//  in the search bar.

import Foundation

enum SearchType {
    case user
    case boxOffice
}
