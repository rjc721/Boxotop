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
    
    private let MOVIE_GLU_KEY = "5nQf66VFwjastzdFVCCUN2I8pvdW6YkK6Jmuawbr"  //API Key - MovieGlu
    private let MOVIE_GLU_URL = "https://api-gate2.movieglu.com/filmsNowShowing/?n=15"
    private let MOVIE_GLU_CLIENT = "CODE_6"
    private let MOVIE_GLU_AUTH = "Basic Q09ERV82OnR6WGtseVFkTThBQw=="
    private let MOVIE_GLU_VERSION = "v200"
    
    func getNowPlayingFilms(completionHandler: @escaping ([String]?, [String]?, Error?) -> ()) {
        
        let movieGluHeaders = ["client" : MOVIE_GLU_CLIENT, "x-api-key" : MOVIE_GLU_KEY, "Authorization" : MOVIE_GLU_AUTH, "api-version" : MOVIE_GLU_VERSION, "territory":"US","device-datetime":"2020-05-29T19:26:26Z"]
        
        guard let nowPlayingURL = URL(string: MOVIE_GLU_URL) else {fatalError("Could not create URL")}
        
        var urlRequest = URLRequest(url: nowPlayingURL)
        urlRequest.allHTTPHeaderFields = movieGluHeaders
        
        var nowPlayingFilmTitles = [String]()
        var nowPlayingIds = [String]()
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if error == nil {
                
                guard let data = data else {fatalError("Could not set data")}
                print("data was : \(data)")
                
                do {
                    let jsonResponse = try JSONDecoder().decode(MoviegluResponse.self, from: data)
                    
                    if jsonResponse.status.state == "OK" {
                        
                        for film in jsonResponse.films {
                            nowPlayingFilmTitles.append(film.film_name)
                            if let returnedId = film.imdb_id  {
                                let stringId = String(format: "%07d", returnedId)
                            nowPlayingIds.append(stringId)
                            }
                            
                        }
                        print(nowPlayingFilmTitles)
                        completionHandler(nowPlayingFilmTitles,nowPlayingIds, nil)
                        
                    } else {
                        fatalError("Error, possibly ran out of API call requests (limit is 75). JSON State: \(jsonResponse.status.state)")
                    }
                    
                } catch let err {
                    completionHandler(nil, nil, err)
                }
                
            } else { fatalError("Error returned on URL Session with Movieglu API")}
       
        }.resume()
        
    }
}
