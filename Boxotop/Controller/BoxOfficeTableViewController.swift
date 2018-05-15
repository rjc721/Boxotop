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

class BoxOfficeTableViewController: UITableViewController {
    
    let realm = try! Realm()            //Initiate Realm for persistent storage
    var boxOfficeFilms: Results<Film>?  // to avoid unnecessary networking
    
    let OMDB_API_KEY = "9674d90"                //API Key - Open Movie DB
    let OMDB_URL = "http://www.omdbapi.com/"    //Open Movie DB API
    let MOVIE_GLU_KEY = "99999"                 //API Key - MovieGlu
    let MOVIE_GLU_URL = "https://api-gate.movieglu.com/"    //API for getting Now Playing movies
    
    let movieGluParams = ["n" : "10", "api" : "99980980"]   //Not real for the moment
    
    let testParams = ["s" : "a-quiet-place", "apikey" : "9674d90"]
    let testOpenMovieAPIAddress = "http://www.omdbapi.com/?s=a-quiet-place&y=2018&apikey=9674d90" //TEST
    
    let navBarGreen = UIColor(hexString: "5C9E41")
    let tableCellGreen = UIColor(hexString: "BFDBB3")
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    
    var movies = ["Avengers: Infinity War", "Breaking In", "Life of the party", "Overboard", "A Quiet Place", "I Feel Pretty", "Rampage", "Tully", "Black Panther", "A Wrinkle In Time"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        
        self.navigationController?.navigationBar.barTintColor = navBarGreen
        searchBar.barTintColor = navBarGreen
        refreshButton.tintColor = UIColor.black
        
        if realm.isEmpty {
            loadBoxOfficeFilms(url: MOVIE_GLU_URL, parameters: movieGluParams)
        } else {
            boxOfficeFilms = realm.objects(Film.self).sorted(byKeyPath: "title")
        }
        
    }

    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {fatalError("Crashed deleting on refresh")}
        
        loadBoxOfficeFilms(url: MOVIE_GLU_URL, parameters: movieGluParams)
    }
    

    // MARK: - Table view methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return boxOfficeFilms?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "filmCell", for: indexPath)
        
        if boxOfficeFilms != nil {
            cell.textLabel?.text = boxOfficeFilms![indexPath.row].title
        } else {
            cell.textLabel?.text = "Loading Data..."
        }

        cell.backgroundColor = ((indexPath.row % 2) == 1) ? tableCellGreen : UIColor.white
        
        return cell
    }
    
    
    
    //MARK: Networking with Alamofire
    func loadBoxOfficeFilms(url: String, parameters: [String : String]) {
        
        loadFromMDB(titles: movies)
        
//        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
//            //print("Request: \(String(describing: response.request))")   // original url request
//            //print("Response: \(String(describing: response.response))") // http url response
//            //print("Result: \(response.result)")                         // response serialization result
//
//            if response.result.isSuccess {
//
//                let filmJSON : JSON = JSON(response.result.value!)
//
//                self.updateUIWithData(json: filmJSON)
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
                    
                    self.decodingJSON(json: filmJSON)
                    
                } else {
                    
                }
                
                if let json = response.result.value {
                    print("JSON: \(json)") // serialized json response
                }
            }
        }
    }
    
    //MARK: Parsing with SwiftyJSON
    func decodingJSON(json : JSON) {
        
        let newFilm = Film()
        newFilm.title = json["Title"].string!
        newFilm.cast = json["Actors"].string!
        //newFilm.criticRating = json["Metascore"].double!
        newFilm.director = json["Director"].string!
        //newFilm.imdbRating = json["imdbRating"].double!
        newFilm.plot = json["Plot"].string!
        newFilm.ratingMPAA = json["Rated"].string!
        newFilm.releaseDate = json["Released"].string!
        //newFilm.rottenTomatoesRating = json["Ratings"][2]["Value"].string!
        
        do {
            try realm.write {
                realm.add(newFilm)
            }
        } catch {
            print("Error loading film into Realm")
        }
        
        boxOfficeFilms = realm.objects(Film.self).sorted(byKeyPath: "title")
        tableView.reloadData()
        
        //If known
        /*
         let title = json[][]
        */
        
        //If searching
        //let title = json["Search"][1]["Title"]
        //let resultsNum = json["totalResults"]
        //print("Title 1 is: \(resultsNum)")
        
    }
    
    // MARK: - Navigation

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destinationVC = segue.destination as? FilmViewController else {fatalError("Wrong destination view controller")}
        
        guard let selectedMovieCell = sender else {fatalError("Unexpected sender: \(sender!)")}
        
        guard let indexPath = tableView.indexPath(for: selectedMovieCell as! UITableViewCell) else {fatalError("The selected cell is not being displayed by the table")}
        
        destinationVC.film = boxOfficeFilms?[indexPath.row]
        
    }
    
}

extension BoxOfficeTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            //movies = movies?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title")
            tableView.reloadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            
        }
    }

}
