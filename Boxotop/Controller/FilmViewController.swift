//
//  FilmViewController.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/14/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import UIKit
import RealmSwift

class FilmViewController: UIViewController {
    
    var film: Film?
    
    @IBOutlet weak var filmTitleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var releasedDateLabel: UILabel!
    @IBOutlet weak var plotTextLabel: UILabel!
    @IBOutlet weak var castTextLabel: UILabel!
    @IBOutlet weak var directorTextLabel: UILabel!
    @IBOutlet weak var writerTextLabel: UILabel!
    @IBOutlet weak var tomatoRatingLabel: UILabel!
    @IBOutlet weak var imdbRatingLabel: UILabel!
    @IBOutlet weak var starRatingControl: RatingControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let film = film {
            filmTitleLabel.text = film.title
            releasedDateLabel.text = film.releaseDate
            plotTextLabel.text = film.plot
            castTextLabel.text = film.cast
            directorTextLabel.text = film.director
            writerTextLabel.text = film.writer
            tomatoRatingLabel.text = film.rottenTomatoesRating
            imdbRatingLabel.text = film.imdbRating
            starRatingControl.rating = film.userRating
            
            if let poster = UIImage(data: film.posterImage!) {
                posterImageView.image = poster
            } else {
                posterImageView.image = #imageLiteral(resourceName: "defaultPhoto")
            }
            
            starRatingControl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updateRating)))
            
        }
        
    }
    
    @objc func updateRating() {
        print("Rating updated!")
    }
    
    
    @IBAction func showPickerTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let webAction = UIAlertAction(title: "Visit Page on IMDB", style: .default) { (action) in
            
            self.performSegue(withIdentifier: "showWeb", sender: nil)
        }
        let showtimesAction = UIAlertAction(title: "Showtimes Near Me", style: .default) { (action) in
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(webAction)
        alert.addAction(showtimesAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}
