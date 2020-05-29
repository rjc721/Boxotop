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
        
        newFilm.title = result.Title ?? "Title not found"
        newFilm.director = result.Director ?? "Director not found"
        newFilm.cast = result.Actors ?? "No actors listed"
        newFilm.criticRating = result.Metascore ?? "no score"
        newFilm.imdbRating = result.imdbRating ?? "no rating"
        newFilm.plot = result.Plot ?? "Plot not shown"
        newFilm.ratingMPAA = result.Rated ?? "No rating given"
        newFilm.releaseDate = result.Released ?? "release date unknown"
        newFilm.writer = result.Writer ?? "Writer not listed"
        newFilm.imdbID = imdbID
        newFilm.isNowPlaying = (searchType == .boxOffice)
    
        if let ratings = result.Ratings {
            if ratings.count > 1 {
                newFilm.rottenTomatoesRating = ratings[1].Value!
            } else {
            newFilm.rottenTomatoesRating = "Not Available"
            }
             
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
