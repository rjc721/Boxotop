//
//  MoviegluAPIHandler.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/16/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//
//  Movieglu API provides movies now playing in theaters.
//  We are using a default value of 15 films specified in
//  in the MOVIE GLU URL "n = 15". These results are then
//  passed to the Open Movie Database for further info.

import Foundation

class MoviegluAPIHandler {
    
    private let MOVIE_GLU_KEY = "mZ7e3PiwO69tFDYCwi63D1ZoROh14OViR6yqzqu6"  //API Key - MovieGlu
    private let MOVIE_GLU_URL = "https://api-gate.movieglu.com/filmsNowShowing/?n=15"    //URL
    private let MOVIE_GLU_CLIENT = "WHYO"
    private let MOVIE_GLU_AUTH = "Basic V0hZTzpJSkxXbk53a0l5cXg="
    private let MOVIE_GLU_VERSION = "v102"
    
    func getNowPlayingFilms(completionHandler: @escaping ([String]?, Error?) -> ()) {
        
        let movieGluHeaders = ["client" : MOVIE_GLU_CLIENT, "x-api-key" : MOVIE_GLU_KEY, "Authorization" : MOVIE_GLU_AUTH, "api-version" : MOVIE_GLU_VERSION]
        
        guard let nowPlayingURL = URL(string: MOVIE_GLU_URL) else {fatalError("Could not create URL")}
        
        var urlRequest = URLRequest(url: nowPlayingURL)
        urlRequest.allHTTPHeaderFields = movieGluHeaders
        
        var nowPlayingFilmTitles = [String]()
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if error == nil {
                
                guard let data = data else {fatalError("Could not set data")}
                
                do {
                    let jsonResponse = try JSONDecoder().decode(MoviegluResponse.self, from: data)
                    
                    if jsonResponse.status.state == "OK" {
                        
                        for film in jsonResponse.films {
                            nowPlayingFilmTitles.append(film.film_name)
                          
                        }
                        print(nowPlayingFilmTitles)
                        completionHandler(nowPlayingFilmTitles, nil)
                        
                    } else {
                        fatalError("Error, possibly ran out of API call requests (limit is 70). JSON State: \(jsonResponse.status.state)")
                    }
                    
                } catch let err {
                    completionHandler(nil, err)
                }
                
            } else { fatalError("Error returned on URL Session with Movieglu API")}
       
        }.resume()
        
    }
}
