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
    
    func searchOpenMDB(titles: [String], completionHandler: @escaping (JSON?, Error?) -> ()) {
        makeSearchCall(movieTitles: titles, completionHandler: completionHandler)
    }
    
    private func makeSearchCall(movieTitles: [String], completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        for movieTitle in movieTitles {
            
            let adjustedTitle = movieTitle.replacingOccurrences(of: " ", with: "-")
            let filmParams = ["s" : adjustedTitle, "type" : "movie", "apikey" : OMDB_API_KEY]
            
            Alamofire.request(OMDB_URL, method: .get, parameters: filmParams).responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    if let json = value as? JSON {
                        if let success = json["Response"].string {
                            if success == "True" {
                                completionHandler(json, nil)
                            }
                        }
                    }
                case .failure(let error):
                    completionHandler(nil, error)
                }
            }
        }
    }
    
    func loadFromOMDB(imdbIDs: [String], completionHandler: @escaping (JSON?, Error?) -> ()) {
        makeLoadCall(with: imdbIDs, completionHandler: completionHandler)
    }
    
    private func makeLoadCall(with imdbIDs: [String], completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        for imdbID in imdbIDs {
            
            let filmParams = ["i" : imdbID, "apikey" : OMDB_API_KEY]
            
            Alamofire.request(OMDB_URL, method: .get, parameters: filmParams).responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    if let json = value as? JSON {
                        if let success = json["Response"].string {
                            if success == "True" {
                                completionHandler(json, nil)
                            }
                        }
                    }
                case .failure(let error):
                    completionHandler(nil, error)
                }
            }
        }
    }
}
