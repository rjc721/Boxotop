//
//  OpenMDBJSONParser.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/16/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import Foundation
import SwiftyJSON

class OpenMDBJSONParser {
    
    func parseSearchResultsJSON(_ json: JSON, searchQuery: String, boxOfficeSearch: Bool) {
        if let count = Int(json["totalResults"].string!) {
            
            var searchResults = [SearchResultOMDB]()    //Using these results to find true box office titles
            var searchIDResults = [String]()            //Using these IDS for a generic user search
            
            let resultsCount = count <= 10 ? count : 10     //Search JSON contains max of 10 results
            
            for index in 0..<resultsCount {
                
                let searchResult = SearchResultOMDB()
                searchResult.title = json["Search"][index]["Title"].string!
                searchResult.imdbID = json["Search"][index]["imdbID"].string!
                searchResult.yearReleased = json["Search"][index]["Year"].string!
                searchResult.relevanceScore = 0
                searchResult.searchQuery = searchQuery
                
                searchIDResults.append(searchResult.imdbID)
                searchResults.append(searchResult)
            }
            
            if !boxOfficeSearch {
                loadFromOMDB(imdbIDs: searchIDResults, isNowPlaying: false)
            } else {
                checkSearchRelevance(results: searchResults)
            }
            
        }
    }
    
    func decodeOMDBJSON(_ json : JSON, imdbID: String, searchType: SearchType) {
        
        let newFilm = Film()
        
        newFilm.title = json["Title"].string!
        newFilm.director = json["Director"].string!
        newFilm.cast = json["Actors"].string!               //Using explicit unwrapping because JSON is
        newFilm.criticRating = json["Metascore"].string!    //checked for validity above
        newFilm.imdbRating = json["imdbRating"].string!     //and these strings return "N/A" when empty
        newFilm.plot = json["Plot"].string!
        newFilm.ratingMPAA = json["Rated"].string!
        newFilm.releaseDate = json["Released"].string!
        newFilm.writer = json["Writer"].string!
        newFilm.imdbID = imdbID
        newFilm.isNowPlaying = isNowPlaying
        
        
        if let rottenTomatoRating = json["Ratings"][1]["Value"].string {
            newFilm.rottenTomatoesRating = rottenTomatoRating
        } else {
            newFilm.rottenTomatoesRating = "Not Available"
        }
        
        if let posterImageURL = json["Poster"].string {
            
            let url = URL(string: posterImageURL)
            
            do {
                newFilm.posterImage = try Data(contentsOf: url!)
            } catch {
                newFilm.posterImage = UIImagePNGRepresentation(#imageLiteral(resourceName: "defaultPhoto"))!
            }
        }
        
        updateRealm(with: newFilm)
    }
    
}
