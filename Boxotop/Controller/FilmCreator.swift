//
//  FilmCreator.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/16/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import UIKit

class FilmCreator {
    
    func createFilm(from result : OmdbIDResponse, imdbID: String, searchType: SearchType) -> Film {
        
        let newFilm = Film()
        
        newFilm.title = result.Title
        newFilm.director = result.Director
        newFilm.cast = result.Actors
        newFilm.criticRating = result.Metascore
        newFilm.imdbRating = result.imdbRating
        newFilm.plot = result.Plot
        newFilm.ratingMPAA = result.Rated
        newFilm.releaseDate = result.Released
        newFilm.writer = result.Writer
        newFilm.imdbID = imdbID
        newFilm.isNowPlaying = (searchType == .boxOffice)
    
        if result.Ratings.count > 1 {
             newFilm.rottenTomatoesRating = result.Ratings[1].Value!
        } else {
            newFilm.rottenTomatoesRating = "Not Available"
        }
        
        if let posterImageURL = result.Poster {
            
            let url = URL(string: posterImageURL)
            
            do {
                newFilm.posterImage = try Data(contentsOf: url!)
            } catch {
                newFilm.posterImage = UIImagePNGRepresentation(#imageLiteral(resourceName: "defaultPhoto"))!
            }
        }
        
        return newFilm
    }
    
}
