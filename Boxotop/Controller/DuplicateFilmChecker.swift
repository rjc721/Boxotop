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
    
    func searchDatabaseFor(film: Film) -> Bool {
        
        let filmDatabase = realm.objects(Film.self)
        
        let predicate = NSPredicate(format: "imdbID == %@", film.imdbID)
        let queryFilm = filmDatabase.filter(predicate)
        
        guard let imdbID = queryFilm.first?.imdbID else {fatalError("Problem with Realm within Duplicate Film Checker")}
            
        return imdbID == film.imdbID
        
    }
        
}
