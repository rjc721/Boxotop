//
//  FilmViewController.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/14/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices

class FilmViewController: UIViewController, SFSafariViewControllerDelegate {
    
    var film: Film?
    let realm = try! Realm()
    
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
        starRatingControl.delegate = self
     
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
            
            if let poster = UIImage(data: film.posterImage) {
                posterImageView.image = poster
            } else {
                posterImageView.image = #imageLiteral(resourceName: "defaultPhoto")
            }
        }
        
    }
    
    //MARK: Action Sheet for Web/Showtimes
    
    @IBAction func showPickerTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let webAction = UIAlertAction(title: "Visit Page on IMDB", style: .default) { (action) in
            
            let baseURL = "https://www.imdb.com/title/"
            let imdbURL = URL(string: baseURL + self.film!.imdbID) ?? URL(string: "https://www.google.com")
            
            let safariVC = SFSafariViewController(url: imdbURL!)        //Default to Google if failure
            self.present(safariVC, animated: true, completion: nil)
            safariVC.delegate = self
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(webAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

//MARK: Delegate method for saving rating

extension FilmViewController: RatingControlDelegate {
    
    func saveRating(newRating: Int) {
        do {
            try realm.write {
                film?.userRating = newRating
            }
        } catch {
            fatalError("Error saving user rating")
        }
    }
}
