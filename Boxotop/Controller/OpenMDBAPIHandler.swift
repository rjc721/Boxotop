//
//  OpenMDBAPIHandler.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/16/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class OpenMDBAPIHandler {
    private let OMDB_API_KEY = "9674d90"                //API Key - Open Movie DB
    private let OMDB_URL = "http://www.omdbapi.com/"    //Open Movie DB API
    
    func searchOpenMDB(titles: [String], completionHandler: @escaping (JSON?, String, Error?) -> ()) {
        makeSearchCall(movieTitles: titles, completionHandler: completionHandler)
    }
    
    private func makeSearchCall(movieTitles: [String], completionHandler: @escaping (JSON?, String, Error?) -> ()) {
        
        for movieTitle in movieTitles {
            
            let adjustedTitle = movieTitle.replacingOccurrences(of: " ", with: "-")
            let filmParams = ["s" : adjustedTitle, "type" : "movie", "apikey" : OMDB_API_KEY]
            
            Alamofire.request(OMDB_URL, method: .get, parameters: filmParams).responseJSON
                { response in
                    
                    if response.result.isSuccess {
                        let json : JSON = JSON(response.result.value!)
                        
                        if let success = json["Response"].string {
                            if success == "True" {
                                
                                completionHandler(json, movieTitle, nil)
                            }
                        }
                    } else {
                        let error = response.error
                        print("ERROR")
                        completionHandler(nil, movieTitle, error)
                    }
            }
        }
    }
    
    func loadFromOMDB(imdbIDs: [String], completionHandler: @escaping (JSON?, String, Error?) -> ()) {
        makeLoadCall(with: imdbIDs, completionHandler: completionHandler)
    }
    
    private func makeLoadCall(with imdbIDs: [String], completionHandler: @escaping (JSON?, String, Error?) -> ()) {
        
        for imdbID in imdbIDs {
            
            let filmParams = ["i" : imdbID, "apikey" : OMDB_API_KEY]
            
            Alamofire.request(OMDB_URL, method: .get, parameters: filmParams).responseJSON { response in
                
                if response.result.isSuccess {
                    let json : JSON = JSON(response.result.value!)
                    
                    if let success = json["Response"].string {
                        if success == "True" {
                            
                            completionHandler(json, imdbID, nil)
                        }
                    }
                } else {
                    let error = response.error
                    print("ERROR")
                    completionHandler(nil, imdbID, error)
                }
            }
        }
    }
}

