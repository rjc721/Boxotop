//
//  DuplicateFilmChecker.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/17/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import Foundation
import RealmSwift

class DuplicateFilmChecker {
    
    private let realm = try! Realm()
    
    func searchDatabaseFor(film: Film, searchType: SearchType) -> Bool {
        
        let filmDatabase = realm.objects(Film.self)
        
        let predicate = NSPredicate(format: "imdbID == %@", film.imdbID)
        let queryFilm = filmDatabase.filter(predicate)
        
        if let duplicateFilm = queryFilm.first {
            
            if searchType == .boxOffice {
                do {
                    try realm.write {
                        duplicateFilm.isNowPlaying = true   //Film is already in database and still Now Playing
                    }
                } catch {fatalError("Error updating duplicate now playing flag")}
            }
            
            return duplicateFilm.imdbID == film.imdbID
        }
            
        return false
        
    }
        
}
