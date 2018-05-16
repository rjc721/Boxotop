//
//  BoxOfficeTableViewController.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/14/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import UIKit
import ChameleonFramework
import RealmSwift
import Alamofire
import SwiftyJSON
import SVProgressHUD

class BoxOfficeTableViewController: UITableViewController {
    
    let realm = try! Realm()            //Initiate Realm for persistent storage
    var boxOfficeFilms: Results<Film>?  // to avoid redundant networking
    var tableViewCache: Results<Film>?
    var filmDatabase: Results<Film>?
    
    let OMDB_API_KEY = "9674d90"                //API Key - Open Movie DB
    let OMDB_URL = "http://www.omdbapi.com/"    //Open Movie DB API
    
    let MOVIE_GLU_KEY = "mZ7e3PiwO69tFDYCwi63D1ZoROh14OViR6yqzqu6"  //API Key - MovieGlu
    let MOVIE_GLU_URL = "https://api-gate.movieglu.com/"    //API for getting Now Playing movies
    let MOVIE_GLU_CLIENT = "WHYO"
    let MOVIE_GLU_AUTH = "Basic V0hZTzpJSkxXbk53a0l5cXg="
    let MOVIE_GLU_VERSION = "v102"
   
    let navBarGreen = UIColor(hexString: "5C9E41")      //Green colors from the test design documentation
    let tableCellGreen = UIColor(hexString: "BFDBB3")   //given from "EliteDesign"
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    var movies = ["Deadpool 2", "Avengers: Infinity War", "Sherlock Gnomes", "I Feel Pretty", "Life of the Party", "Breaking In", "The Guernsey Literary and Potato Peel Pie Society", "A Quiet Place", "Rampage", "Entebbe", "Peter Rabbit", "The Strangers: Prey at Night", "The Greatest Showman", "Tully", "Truth or Dare"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Nav controller does not exist")}
        navBar.barTintColor = navBarGreen
        navBar.tintColor = UIColor.flatWhite()
        searchBar.barTintColor = navBarGreen
        
        if realm.isEmpty {
            SVProgressHUD.show()    //Show loading to user
            loadBoxOfficeFilms()
        } else {
            filmDatabase = realm.objects(Film.self)
            boxOfficeFilms = filmDatabase?.filter("isNowPlaying == %@", true).sorted(byKeyPath: "title")
            tableViewCache = boxOfficeFilms
        }
       
    }

    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        
        SVProgressHUD.show()
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        loadBoxOfficeFilms()
    }
    

    // MARK: - Table view methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let filmCount = boxOfficeFilms?.count {

            return filmCount > 0 ? filmCount : 1    //List exists, show list OR Search cell
        }

        return 1        //List not loaded -> Show Loading cell
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "filmCell", for: indexPath)
      
        if boxOfficeFilms != nil {
            if boxOfficeFilms!.count == 0 {     //Case - filtered but did not find
                cell.imageView?.image = nil
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.isUserInteractionEnabled = false
                cell.textLabel?.text = "No results to display. Please try different search terms. Search for movie titles by hitting \"Search\"."
            }
            if boxOfficeFilms!.count > 0 {      //Case - displaying films like normal or filtered
                cell.textLabel?.text = boxOfficeFilms![indexPath.row].title
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.isUserInteractionEnabled = true
                
                if let poster = UIImage(data: (boxOfficeFilms?[indexPath.row].posterImage)!) {
                    cell.imageView?.image = poster
                }
            }
        } else {                                //Case - Films not yet loaded at launch
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.text = "Loading Data...Make sure you have an Internet connection"
            cell.isUserInteractionEnabled = false
        }
        
        cell.backgroundColor = ((indexPath.row % 2) == 1) ? tableCellGreen : UIColor.white
        
        return cell
    }
    
    
    
    //MARK: Networking with Alamofire
    
    func loadBoxOfficeFilms() {
        
        loadFromMDB(titles: movies)
        
//        let movieGluHeaders = ["client" : MOVIE_GLU_CLIENT, "x-api-key" : MOVIE_GLU_KEY, "Authorization" : MOVIE_GLU_AUTH, "api-version" : MOVIE_GLU_VERSION]
//        let nowPlayingURL = MOVIE_GLU_URL + "filmsNowShowing/?n=15"
//
//        Alamofire.request(nowPlayingURL, method: .get, headers: movieGluHeaders).responseJSON { response in
//
//            if response.result.isSuccess {
//
//                let nowPlayingJSON : JSON = JSON(response.result.value!)
//                self.decodeMovieGluJSON(nowPlayingJSON)
//
//            }
//        }
    }
    
    func loadFromMDB(titles: [String]) {
        print("Titles passed: \(titles)")
    
        for title in titles {
            let adjustedTitle = title.replacingOccurrences(of: " ", with: "-")
            let filmParams = ["t" : adjustedTitle, "apikey" : OMDB_API_KEY]
            
            Alamofire.request(OMDB_URL, method: .get, parameters: filmParams).responseJSON { response in
                
                if response.result.isSuccess {
                    
                    let filmJSON : JSON = JSON(response.result.value!)
                    
                    self.decodeMDBJSON(filmJSON)
                    print("JSON passed: \(filmJSON)")
                }
            }
        }
    }
    
    //MARK: Parsing with SwiftyJSON
    
    func decodeMovieGluJSON(_ json: JSON) {
        var nowPlayingTitles = [String]()
        
        let filmCount = json["count"].int!
        
        for index in 0..<filmCount {
            let title = json["films"][index]["film_name"].string!
            nowPlayingTitles.append(title)
        }
        
        loadFromMDB(titles: nowPlayingTitles)
        
    }
    
    
    // Movie Database JSON -- Create Film objects, load into Tableview
    func decodeMDBJSON(_ json : JSON, isNowPlaying: Bool = true) {
        
        let newFilm = Film()
        
//        if let title = json["Title"].string {
//            newFilm.title = title
//        } else {
//            print(json["Title"].string)
//            print("****JSON: \(json)")
//        }
        newFilm.title = json["Title"].string!
        newFilm.director = json["Director"].string!
        newFilm.cast = json["Actors"].string!               //Using explicit unwrapping because JSON is
        newFilm.criticRating = json["Metascore"].string!    //checked for validity above
        newFilm.imdbRating = json["imdbRating"].string!     //and these strings return "N/A" when empty
        newFilm.plot = json["Plot"].string!
        newFilm.ratingMPAA = json["Rated"].string!
        newFilm.releaseDate = json["Released"].string!
        newFilm.writer = json["Writer"].string!
        newFilm.isNowPlaying = isNowPlaying
        
        
        if let rottenTomatoRating = json["Ratings"][1]["Value"].string {
            newFilm.rottenTomatoesRating = rottenTomatoRating
        } else {
            newFilm.rottenTomatoesRating = "Not Available"
        }
        
        if let posterImageURL = json["Poster"].string {
    
            let url = URL(string: posterImageURL)
            
            do {
                newFilm.posterImage = try Data(contentsOf: url!)
            } catch {
                newFilm.posterImage = nil
            }
        }
        
        updateRealm(with: newFilm)
    }
    
    //MARK: Update Realm database
    func updateRealm(with film: Film) {
        
        //Check to see if film already exists in database
        let predicate = NSPredicate(format: "title == %@ && director == %@", argumentArray: [film.title, film.director])
        
        if let queryFilm = filmDatabase?.filter(predicate), let title = queryFilm.first?.title {
            
            if title == film.title {
                
                SVProgressHUD.dismiss(withDelay: 1)
                return
            }
        }
      
        //If it doesn't exist, add it to database
        do {
            try realm.write {
                realm.add(film)
                filmDatabase = realm.objects(Film.self)
            }
        } catch {
            print("Error loading film into Realm")
        }

        boxOfficeFilms = realm.objects(Film.self).sorted(byKeyPath: "title")
        tableViewCache = boxOfficeFilms
        
        tableView.reloadData()
        SVProgressHUD.dismiss(withDelay: 1) //Dismiss Progress HUD, Load Complete
    }
    
    // MARK: - Navigation

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destinationVC = segue.destination as? FilmViewController else {fatalError("Wrong destination view controller")}
        
        guard let selectedMovieCell = sender else {fatalError("Unexpected sender: \(sender!)")}
        
        guard let indexPath = tableView.indexPath(for: selectedMovieCell as! UITableViewCell) else {fatalError("The selected cell is not being displayed by the table")}
        
        destinationVC.film = boxOfficeFilms?[indexPath.row]
        
    }
    
}

    //MARK: Search Bar Delegate Methods

extension BoxOfficeTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let filterPredicate = NSPredicate(format: "title CONTAINS[cd] %@ || director CONTAINS[cd] %@ || %K CONTAINS[cd] %@", argumentArray: [searchBar.text!, searchBar.text!, "cast", searchBar.text!])
        
        boxOfficeFilms = filmDatabase?.filter(filterPredicate).sorted(byKeyPath: "title")
        
        tableView.reloadData()
        
        if searchText.count == 0 {
            boxOfficeFilms = tableViewCache
            tableView.reloadData()
        }
        
    }

}
