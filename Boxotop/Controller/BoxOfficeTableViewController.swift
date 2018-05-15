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
    
    
    var movies = ["Avengers: Infinity War", "Breaking In", "Life of the party", "Overboard", "A Quiet Place", "I Feel Pretty", "Rampage", "Tully", "Black Panther", "A Wrinkle In Time"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Nav controller does not exist")}
        navBar.barTintColor = navBarGreen
        navBar.tintColor = UIColor.flatWhite()
        searchBar.barTintColor = navBarGreen
        refreshButton.tintColor = UIColor.black
        
        if realm.isEmpty {
            SVProgressHUD.show()    //Show loading to user
            loadBoxOfficeFilms()
        } else {
            boxOfficeFilms = realm.objects(Film.self).sorted(byKeyPath: "title")
            tableViewCache = boxOfficeFilms
        }
        
    }

    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        
        SVProgressHUD.show()
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {fatalError("Crashed deleting on refresh")}
        
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
                cell.textLabel?.text = "Not found in box office movies,\rclick to search IMDB for movie title"
            }
            if boxOfficeFilms!.count > 0 {      //Case - displaying films like normal or filtered
                cell.textLabel?.text = boxOfficeFilms![indexPath.row].title
                
                if let poster = UIImage(data: (boxOfficeFilms?[indexPath.row].posterImage)!) {
                    cell.imageView?.image = poster
                }
            }
        } else {                                //Case - Films not yet loaded at launch
            cell.textLabel?.text = "Loading Data..."
        }
        
        cell.backgroundColor = ((indexPath.row % 2) == 1) ? tableCellGreen : UIColor.white
        
        return cell
    }
    
    
    
    //MARK: Networking with Alamofire
    
    func loadBoxOfficeFilms() {
        
        loadFromMDB(titles: movies)
        
        let movieGluHeaders = ["client" : MOVIE_GLU_CLIENT, "x-api-key" : MOVIE_GLU_KEY, "Authorization" : MOVIE_GLU_AUTH, "api-version" : MOVIE_GLU_VERSION]
        let nowPlayingURL = MOVIE_GLU_URL + "filmsNowShowing/?n=15"
        
        
//        Alamofire.request(nowPlayingURL, method: .get, headers: movieGluHeaders).responseJSON { response in
//            //print("Request: \(String(describing: response.request))")   // original url request
//            //print("Response: \(String(describing: response.response))") // http url response
//            //print("Result: \(response.result)")                         // response serialization result
//
//            if response.result.isSuccess {
//
//                let filmJSON : JSON = JSON(response.result.value!)
//
//                //self.updateUIWithData(json: filmJSON)
//
//            } else {
//
//            }
//
//            if let json = response.result.value {
//                print("JSON: \(json)") // serialized json response
//            }
//
//        }
    }
    
    func loadFromMDB(titles: [String]) {
    
        for title in titles {
            let adjustedTitle = title.replacingOccurrences(of: " ", with: "-")
            let filmParams = ["t" : adjustedTitle, "apikey" : OMDB_API_KEY]
            
            Alamofire.request(OMDB_URL, method: .get, parameters: filmParams).responseJSON { response in
                
                if response.result.isSuccess {
                    
                    let filmJSON : JSON = JSON(response.result.value!)
                    
                    self.decodeMDBJSON(filmJSON, saveToRealm: true)
                    
                }
            }
        }
    }
    
    //MARK: Parsing with SwiftyJSON
    
    func decodeMovieGluJSON(_ json: JSON) {
        
    }
    
    
    // Movie Database JSON -- Create Film objects, load into Tableview
    func decodeMDBJSON(_ json : JSON, saveToRealm: Bool) {
        
        let newFilm = Film()
        
        newFilm.title = json["Title"].string!               //Using explicit unwrapping because JSON is
        newFilm.cast = json["Actors"].string!               //checked for validity above
        newFilm.criticRating = json["Metascore"].string!    //and these strings return "N/A" when empty
        newFilm.director = json["Director"].string!
        newFilm.imdbRating = json["imdbRating"].string!
        newFilm.plot = json["Plot"].string!
        newFilm.ratingMPAA = json["Rated"].string!
        newFilm.releaseDate = json["Released"].string!
        newFilm.writer = json["Writer"].string!
        
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
        
        if saveToRealm {
            do {
                try realm.write {
                    realm.add(newFilm)
                }
            } catch {
                print("Error loading film into Realm")
            }
        } else {
            //Show movie search results
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
        
        boxOfficeFilms = tableViewCache?.filter(filterPredicate).sorted(byKeyPath: "title")
        
        tableView.reloadData()
        
        if searchText.count == 0 {
            boxOfficeFilms = tableViewCache
            tableView.reloadData()
        }
        
    }

}
