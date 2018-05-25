//
//  SearchResponseInterpreter.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/25/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import Foundation

class SearchResponseInterpreter {
    
    func interpretResults (result: OmdbResponseToS, movieTitle: String) -> ([SearchResultOMDB], [String]) {
        
        var searchResults = [SearchResultOMDB]()
        var searchIDResults = [String]()

        for film in result.Search {

            let searchResult = SearchResultOMDB()
            searchResult.title = film.Title
            searchResult.imdbID = film.imdbID
            searchResult.yearReleased = film.Year
            searchResult.relevanceScore = 0
            searchResult.searchQuery = movieTitle

            searchIDResults.append(searchResult.imdbID)
            searchResults.append(searchResult)
        }
        
        return (searchResults, searchIDResults)
            
    }
}
