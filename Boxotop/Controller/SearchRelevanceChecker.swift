//
//  SearchRelevanceChecker.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/16/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import Foundation

class SearchRelevanceChecker {
    
    func checkSearchRelevance(results: [SearchResultOMDB]) {
        
        if results.count == 1 {
            
            if let onlyResult = results.first?.imdbID {
                loadFromOMDB(imdbIDs: [onlyResult], isNowPlaying: true)
            }
            
        }
        else if results.count > 1 {
            
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
            
            if let bestResult = sortedResults.first?.imdbID {
                loadFromOMDB(imdbIDs: [bestResult], isNowPlaying: true)
            }
            
        }
    }
}
