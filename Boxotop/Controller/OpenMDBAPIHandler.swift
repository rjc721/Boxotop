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

    func searchOpenMDB(movieTitles: [String], completionHandler: @escaping (OmdbResponseToS?, String?, Error?) -> ()) {
        
        for movieTitle in movieTitles {
            
            let adjustedTitle = movieTitle.replacingOccurrences(of: " ", with: "-")
            
            let titleSearchQuery = URLQueryItem(name: "s", value: adjustedTitle)
            let typeOfSearchQuery = URLQueryItem(name: "type", value: "movie")
            
            guard let url = NSURLComponents(string: OMDB_URL) else {fatalError("OMDB URL Error")}
            url.queryItems = [apiKeyQuery, titleSearchQuery, typeOfSearchQuery]
            guard let convertedURL = url.url else {fatalError("URL could not be converted from NSURL")}
            
            var request = URLRequest(url: convertedURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
            request.httpMethod = "GET"
            
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    
                    print("Response: \(response)")
                    
                    guard let data = data else {fatalError("Could not set data")}
                    
                    do {
                        let jsonResponse = try JSONDecoder().decode(OmdbResponseToS.self, from: data)
                        
                        if jsonResponse.Response == "True" {
                            
                            URLSession.shared.dataTask(with: request).cancel()
                            
                            DispatchQueue.main.async {
                                completionHandler(jsonResponse, movieTitle, nil)
                            }
                            
                        }
                        
                    } catch {
                        print("OMDB Movie not found")
                    }
                    
                } else {
                    
                    URLSession.shared.dataTask(with: request).cancel()
                    
                    DispatchQueue.main.async {
                        completionHandler(nil, nil, error)
                    }
                    
                }
            }.resume()
        }
    }
    

    func loadFromOMDB(with imdbIDs: [String], completionHandler: @escaping (OmdbIDResponse?, String, Error?) -> ()) {
        
        for imdbID in imdbIDs {
            
            let idQuery = URLQueryItem(name: "i", value: imdbID)
            
            guard let url = NSURLComponents(string: OMDB_URL) else {fatalError("OMDB URL Error")}
            url.queryItems = [apiKeyQuery, idQuery]
            guard let convertedURL = url.url else {fatalError("URL could not be converted from NSURL")}
            
            var request = URLRequest(url: convertedURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
            request.httpMethod = "GET"
            
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                if error == nil {
                    
                    guard let data = data else {fatalError("Could not set data")}
                    
                    do {
                        
                        let jsonResponse = try JSONDecoder().decode(OmdbIDResponse.self, from: data)
                        
                        if jsonResponse.Response == "True" {
                            
                            URLSession.shared.dataTask(with: request).cancel()
                            
                            DispatchQueue.main.async {
                                completionHandler(jsonResponse, imdbID, nil)
                            }
                        }
                        
                    } catch let err {
                        fatalError("Fatal error, JSON decoding in load from OMDB: error: \(err)")
                    }
                } else {
                    URLSession.shared.dataTask(with: request).cancel()
                    
                    DispatchQueue.main.async {
                        print("Error on URL Session -> OMDB \(error)")
                        completionHandler(nil, imdbID, error)
                    }
                }
            }.resume()
        }
    }
}

