//
//  MoviegluAPIHandler.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/16/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MoviegluAPIHandler {
    
    private let MOVIE_GLU_KEY = "mZ7e3PiwO69tFDYCwi63D1ZoROh14OViR6yqzqu6"  //API Key - MovieGlu
    private let MOVIE_GLU_URL = "https://api-gate.movieglu.com/"    //API for getting Now Playing movies
    private let MOVIE_GLU_CLIENT = "WHYO"
    private let MOVIE_GLU_AUTH = "Basic V0hZTzpJSkxXbk53a0l5cXg="
    private let MOVIE_GLU_VERSION = "v102"
    private var nowPlayingJSON: JSON?
  
    func getNowPlayingFilms(completionHandler: @escaping (JSON?, Error?) -> ()) {
        makeAPICall(completionHandler: completionHandler)
    }
    
    private func makeAPICall(completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        let movieGluHeaders = ["client" : MOVIE_GLU_CLIENT, "x-api-key" : MOVIE_GLU_KEY, "Authorization" : MOVIE_GLU_AUTH, "api-version" : MOVIE_GLU_VERSION]
        let nowPlayingURL = MOVIE_GLU_URL + "filmsNowShowing/?n=15"
        
        Alamofire.request(nowPlayingURL, method: .get, headers: movieGluHeaders).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                completionHandler(value as? JSON, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
           
        }
    }
}
