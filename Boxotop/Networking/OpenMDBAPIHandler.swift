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

protocol OpenMovieDBDelegate {
    func receivedOMDBSearchResults(result: OmdbResponseToS, movieTitle: String, isError: Bool)
    func receivedOMDBLoadResults(result: OmdbIDResponse, imdbID: String, isError: Bool)
}

enum ApiCallType {
    case search
    case load
}

class OpenMDBAPIHandler {
    
    var delegate: OpenMovieDBDelegate?
    
    private let OMDB_API_KEY = "9674d90"                //API Key - Open Movie DB
    private let OMDB_URL = "http://www.omdbapi.com/"    //Open Movie DB API
    private let apiKeyQuery = URLQueryItem(name: "apikey", value: "9674d90")
    
    func searchOpenMDB(for movieTitles: [String], isRetry: Bool? = false) {
    print("titles: \(movieTitles)")
        for movieTitle in movieTitles {
            let apiDelegate = ApiDelegate()
            apiDelegate.dataCompletionHandler = receivedData(data:title:imdbID:callType:hasError:)
            apiDelegate.retryHandler = attemptTaskRetry(task:callType:title:imdbID:)
            
            apiDelegate.movieTitle = movieTitle
            apiDelegate.callType = .search
            apiDelegate.isTaskRetry = isRetry
            
            let session = URLSession(configuration: .default, delegate: apiDelegate, delegateQueue: nil)
            
            let adjustedTitle = movieTitle.replacingOccurrences(of: " ", with: "-")
            
            let titleSearchQuery = URLQueryItem(name: "s", value: adjustedTitle)
            let typeOfSearchQuery = URLQueryItem(name: "type", value: "movie")
            
            guard let url = NSURLComponents(string: OMDB_URL) else {fatalError("OMDB URL Error")}
            
            url.queryItems = [apiKeyQuery, titleSearchQuery, typeOfSearchQuery]
            
            guard let convertedURL = url.url else {fatalError("URL could not be converted from NSURL")}
            
            let task = session.dataTask(with: convertedURL)
            apiDelegate.task = task
            apiDelegate.scheduleTimer()
            
            task.resume()
        }
    }
    
    func loadFromOMDB(with imdbIDs: [String], isRetry: Bool? = false, isBoxOfficeLoad: Bool) {
        
        for imdbID in imdbIDs {
            let apiDelegate = ApiDelegate()
            var id = imdbID
            
            if isBoxOfficeLoad {
                id = "tt" + imdbID
            }
            
            apiDelegate.dataCompletionHandler = receivedData(data:title:imdbID:callType:hasError:)
            apiDelegate.retryHandler = attemptTaskRetry(task:callType:title:imdbID:)
            apiDelegate.imdbID = id
            
            apiDelegate.callType = .load
            apiDelegate.isTaskRetry = isRetry
            
            let session = URLSession(configuration: .default, delegate: apiDelegate, delegateQueue: nil)
            
            guard let url = NSURLComponents(string: OMDB_URL) else {fatalError("OMDB URL Error")}
            
            let idQuery = URLQueryItem(name: "i", value: id)
            url.queryItems = [apiKeyQuery, idQuery]
            
            guard let convertedURL = url.url else {fatalError("URL could not be converted from NSURL")}
            
            let task = session.dataTask(with: convertedURL)
            apiDelegate.task = task
            apiDelegate.scheduleTimer()
            
            task.resume()
        }
        
    }
        
    func receivedData (data: Data, title: String?, imdbID: String?, callType: ApiCallType, hasError: Bool) -> Void {
        
        if callType == .search {
            
            do {
                let jsonResponse = try JSONDecoder().decode(OmdbResponseToS.self, from: data)
                
                if jsonResponse.Response == "True" {
                    
                    DispatchQueue.main.async {
                        self.delegate?.receivedOMDBSearchResults(result: jsonResponse, movieTitle: title!, isError: hasError)
                    }
                }
                
            } catch let err {
                print("error in search: \(err)")
            }
        }
        
        if callType == .load {
            
            do {
                let jsonResponse = try JSONDecoder().decode(OmdbIDResponse.self, from: data)
                
                if jsonResponse.Response == "True" {
                    DispatchQueue.main.async {
                        self.delegate?.receivedOMDBLoadResults(result: jsonResponse, imdbID: imdbID!, isError: hasError)
                    }
                }
            } catch let err {
                print("error in mdb api handler: \(err)")
            }
        }
    }
    
    func attemptTaskRetry(task: URLSessionDataTask, callType: ApiCallType, title: String?, imdbID: String?) -> Void {
        
        switch callType {
        case .search:
            guard let movieTitle = title else {fatalError("movie title was not passed back")}
            self.searchOpenMDB(for: [movieTitle], isRetry: true)
        case .load:
            guard let id = imdbID else {fatalError("imdb id did not get passed back")}
            self.loadFromOMDB(with: [id], isRetry: true, isBoxOfficeLoad: false)
        }
    }
    
}

