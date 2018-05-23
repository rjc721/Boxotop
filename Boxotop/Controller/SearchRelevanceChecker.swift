//
//  SearchRelevanceChecker.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/16/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//
//  Because Movieglu API returns film titles, some of which may
//  be duplicates, remakes, or similar to older films, this
//  simplistic algorithm tries to find the best match. I give a
//  "relevance score" simply based on Title and Year of release.


import Foundation

class SearchRelevanceChecker {
    
    func check(results: [SearchResultOMDB]) -> String {
        
        if results.count == 1 {
            
            guard let onlyResult = results.first?.imdbID else {fatalError("Relevance checker VERY broken")}
            
            return onlyResult
        }
            
        else {
            
            let date = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            
            for result in results {
                if let releaseYearInt = Int(result.yearReleased) {
                    
                    switch releaseYearInt {
                        
                    case year:  result.relevanceScore += 3
                    case year - 1:  result.relevanceScore += 2
                    case year - 2:  result.relevanceScore += 1
                    default:    break
                        
                    }
                }
                
                if result.title == result.searchQuery {
                    result.relevanceScore += 2
                }
            }
            
            let sortedResults = results.sorted(by: {$0.relevanceScore > $1.relevanceScore})
            
            guard let bestResult = sortedResults.first?.imdbID else {fatalError("Relevance checker broken")}
            
            return bestResult
        }
    }
}
