//
//  FilmViewController.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/14/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import UIKit

class FilmViewController: UIViewController {
    
    var film: Film?
    @IBOutlet weak var filmTitleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let film = film {
            filmTitleLabel.text = film.cast
        }
        
    }

  
}

