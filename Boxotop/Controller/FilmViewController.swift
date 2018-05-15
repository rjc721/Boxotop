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
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var releasedDateLabel: UILabel!
    @IBOutlet weak var plotTextLabel: UILabel!
    @IBOutlet weak var castTextLabel: UILabel!
    @IBOutlet weak var directorTextLabel: UILabel!
    @IBOutlet weak var writerTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let film = film {
            filmTitleLabel.text = film.title
            releasedDateLabel.text = film.releaseDate
            plotTextLabel.text = film.plot
            castTextLabel.text = film.cast
            directorTextLabel.text = film.director
            writerTextLabel.text = film.writer
            
            if let poster = UIImage(data: film.posterImage!) {
                posterImageView.image = poster
            } else {
                posterImageView.image = #imageLiteral(resourceName: "defaultPhoto")
            }
            
        }
        
    }

  
}

