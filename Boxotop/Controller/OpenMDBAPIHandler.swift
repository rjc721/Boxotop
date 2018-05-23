//
//  OpenMDBAPIHandler.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/16/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//
//  Two methods for Open Movie Database API, searchOpenMDB
//  gets list of films by title, retrieving a unique imdbID
//  loadFromOMDB uses this imdbID to precisely load the desired
//  film.

import Foundation

class OpenMDBAPIHandler {
    private let OMDB_API_KEY = "9674d90"                //API Key - Open Movie DB
    private let OMDB_URL = "http://www.omdbapi.com/"    //Open Movie DB API
    private let apiKeyQuery = URLQueryItem(name: "apikey", value: "9674d90")

    func searchOpenMDB(movieTitles: [String], completionHandler: @escaping ([SearchResultOMDB]?, [String]?, Error?) -> ()) {
        
        for movieTitle in movieTitles {
            
            let adjustedTitle = movieTitle.replacingOccurrences(of: " ", with: "-")
            
            guard let url = NSURLComponents(string: OMDB_URL) else {fatalError("OMDB URL Error")}
            
            let titleSearchQuery = URLQueryItem(name: "s", value: adjustedTitle)
            let typeOfSearchQuery = URLQueryItem(name: "type", value: "movie")
            
            url.queryItems = [titleSearchQuery, typeOfSearchQuery, apiKeyQuery]
            
            guard let convertedURL = url.url else {fatalError("URL could not be converted from NSURL")}
            
            
            URLSession.shared.dataTask(with: convertedURL) { (data, response, error) in
                
                if error == nil {
                    
                    guard let data = data else {fatalError("Could not set data")}
                    
                    do {
                        let jsonResponse = try JSONDecoder().decode(OmdbResponseToS.self, from: data)
                        
                        if jsonResponse.Response == "True" {
                            
                            var searchResults = [SearchResultOMDB]()
                            var searchIDResults = [String]()

                            for film in jsonResponse.Search {
                                
                                let searchResult = SearchResultOMDB()
                                searchResult.title = film.Title
                                searchResult.imdbID = film.imdbID
                                searchResult.yearReleased = film.Year
                                searchResult.relevanceScore = 0
                                searchResult.searchQuery = movieTitle
                                
                                searchIDResults.append(searchResult.imdbID)
                                searchResults.append(searchResult)
                            }
                            
                            completionHandler(searchResults, searchIDResults, nil)
                            
                        }
                        
                    } catch let err {
                        completionHandler(nil, nil, err)
                    }
                    
                } else { print("Error on URL Session -> OMDB")}
                
            }.resume()
        }
    }
    

    func loadFromOMDB(with imdbIDs: [String], completionHandler: @escaping (OmdbIDResponse?, String, Error?) -> ()) {
        
        for imdbID in imdbIDs {
            
            guard let url = NSURLComponents(string: OMDB_URL) else {fatalError("OMDB URL Error")}
            
            let idQuery = URLQueryItem(name: "i", value: imdbID)
            url.queryItems = [idQuery, apiKeyQuery]
            
            guard let convertedURL = url.url else {fatalError("URL could not be converted from NSURL")}
            
            URLSession.shared.dataTask(with: convertedURL) { (data, response, error) in
               
                if error == nil {
                    
                    guard let data = data else {fatalError("Could not set data")}
                    
                    do {
                        
                        let jsonResponse = try JSONDecoder().decode(OmdbIDResponse.self, from: data)
                        
                        if jsonResponse.Response == "True" {
                            
                            completionHandler(jsonResponse, imdbID, nil)
                        }
                        
                    } catch let err {
                        completionHandler(nil, imdbID, err)
                    }
                } else { print("Error on URL Session -> OMDB")}
                
            }.resume()
        }
    }
}

