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
import SVProgressHUD

class BoxOfficeTableViewController: UITableViewController {
    
    let realm = try! Realm()                    //Initiate Realm as database
    var boxOfficeFilms: Results<Film>?          //Contains movies Now Playing
    var tableViewDisplayFilms: Results<Film>?   //Contains movies being shown in table
    var filmDatabase: Results<Film>?            //Complete database
    
    let navBarGreen = UIColor(hexString: "5C9E41")      //Green colors from the test design documentation
    let tableCellGreen = UIColor(hexString: "BFDBB3")   //given from "EliteDesign"
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    let movieDBAPIHandler = OpenMDBAPIHandler()
    let movieJSONParser = OpenMDBJSONParser()
    
    var movies = ["Deadpool 2", "Avengers: Infinity War", "Sherlock Gnomes", "I Feel Pretty", "Life of the Party", "Breaking In", "The Guernsey Literary and Potato Peel Pie Society", "A Quiet Place", "Rampage", "Entebbe", "Peter Rabbit", "The Strangers: Prey at Night", "The Greatest Showman", "Tully", "Truth or Dare"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Nav controller does not exist")}
        navBar.barTintColor = navBarGreen
        navBar.tintColor = UIColor.flatWhite()
        searchBar.barTintColor = navBarGreen
        tableView.rowHeight = 80.0
        
        if realm.isEmpty {
            SVProgressHUD.show()    //Show loading to user
            loadBoxOfficeFilms()    //Database empty on first use, load films
        } else {
            filmDatabase = realm.objects(Film.self)
            boxOfficeFilms = filmDatabase?.filter("isNowPlaying == %@", true).sorted(byKeyPath: "title")
            tableViewDisplayFilms = boxOfficeFilms
        }
    }
    
    //MARK: - Refresh Button Tapped
    
    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        
        SVProgressHUD.show()
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        loadBoxOfficeFilms()    //Refresh button reloads movies Now Playing
    }
    
    //MARK: - Sort Button Tapped
    
    @IBAction func sortingButtonTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: "Choose Display Preference", preferredStyle: .actionSheet)
        
        let nowPlayingAction = UIAlertAction(title: "Show Now Playing", style: .default) { (action) in
            
            self.tableViewDisplayFilms = self.boxOfficeFilms
            self.tableView.reloadData()
        }
        let historyAction = UIAlertAction(title: "Search History", style: .default) { (action) in
            self.tableViewDisplayFilms = self.filmDatabase?.filter("isNowPlaying == %@", false).sorted(byKeyPath: "title")
            self.tableView.reloadData()
        }
        let allAction = UIAlertAction(title: "Show All", style: .default) { (action) in
            self.tableViewDisplayFilms = self.filmDatabase?.sorted(byKeyPath: "title")
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(nowPlayingAction)
        alert.addAction(historyAction)
        alert.addAction(allAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Table view methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let filmCount = tableViewDisplayFilms?.count {
            
            return filmCount > 0 ? filmCount : 1    //List exists, show list OR Search cell
        }
        
        return 1        //List not loaded -> Show Loading cell
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "filmCell", for: indexPath)
        
        if tableViewDisplayFilms != nil {
            if tableViewDisplayFilms!.count == 0 {     //Case - filtered but did not find
                cell.imageView?.image = nil
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.isUserInteractionEnabled = false
                cell.textLabel?.text = "No results to display. Please try different search terms. Search for movie titles by hitting \"Search\"."
            }
            if tableViewDisplayFilms!.count > 0 {      //Case - displaying films like normal or filtered
                cell.textLabel?.text = tableViewDisplayFilms![indexPath.row].title
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.isUserInteractionEnabled = true
                cell.imageView?.image = UIImage(data: tableViewDisplayFilms![indexPath.row].posterImage) ?? #imageLiteral(resourceName: "defaultPhoto")
                
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
    
    
    //MARK: - Movieglu API and JSON Parsing
    
    func loadBoxOfficeFilms() {
        let movieAPIHandler = MoviegluAPIHandler()
        let moviegluParser = MoviegluJSONParser()
        
        movieAPIHandler.getNowPlayingFilms { (json, error) in
            if error != nil {
                print("Movieglu API Error: \(error!)")
            } else {
                if let boxOfficeJSON = json {
                    let movies = moviegluParser.decodeMovieGluJSON(boxOfficeJSON)
                    self.searchOMDB(movieTitles: movies, searchType: .boxOffice)
                }
            }
        }
    }
    
    //MARK: - Open Movie Database API and JSON Parsing
    func searchOMDB(movieTitles: [String], searchType: SearchType) {
        
        movieDBAPIHandler.searchOpenMDB(titles: movieTitles) { (json, movieTitle, error)  in
            if error != nil {
                print("OMDB API Error finding \(movieTitle): \(error!)")
            } else {
                if let searchResultsJSON = json {
                    
                    switch searchType {
                    case .boxOffice:
                        guard let searchResults = self.movieJSONParser.parseSearchResultsJSON(searchResultsJSON, movieTitle: movieTitle, searchType: searchType) as? [SearchResultOMDB] else {fatalError("Error with JSON Parser")}
                        self.checkForMostRelevant(in: searchResults)
                    case .user:
                        
                    }
                    
                }
            }
        }
        
    }
    
    func checkForMostRelevant(in results: [SearchResultOMDB]) {
        
        let searchChecker = SearchRelevanceChecker()
        let matchingFilm = searchChecker.check(results: results)
        
        movieDBAPIHandler.loadFromOMDB(imdbIDs: [matchingFilm]) { (json, error) in
            <#code#>
        }
        
    }
  
    
    //MARK: Update Realm database
    func updateRealm(with film: Film) {
        
        //Check to see if film already exists in database
        var filmExistsInDatabase = false
        
        let predicate = NSPredicate(format: "imdbID == %@", film.imdbID)
        
        if let queryFilm = filmDatabase?.filter(predicate), let ID = queryFilm.first?.imdbID {
            
            if ID == film.imdbID {
                
                filmExistsInDatabase = true
                SVProgressHUD.dismiss(withDelay: 1)
            }
        }
        
        //If it doesn't exist, add it to database
        if !filmExistsInDatabase {
            do {
                try realm.write {
                    realm.add(film)
                    filmDatabase = realm.objects(Film.self)
                    boxOfficeFilms = filmDatabase?.filter("isNowPlaying == %@", true).sorted(byKeyPath: "title")
                }
            } catch {
                fatalError("Error loading film into Realm")
            }
        }
 
        //  If search bar is empty, we are loading Now Playing films
        //  Else: when a User search comes in, we want to display those results
        if searchBar.text!.isEmpty {
            boxOfficeFilms = filmDatabase?.filter("isNowPlaying == %@", true).sorted(byKeyPath: "title")
            tableViewDisplayFilms = boxOfficeFilms
        } else {
            let filterPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            tableViewDisplayFilms = filmDatabase?.filter(filterPredicate).sorted(byKeyPath: "title")
        }
        
        tableView.reloadData()
        SVProgressHUD.dismiss(withDelay: 1) //Dismiss Progress HUD, Load Complete
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destinationVC = segue.destination as? FilmViewController else {fatalError("Wrong destination view controller")}
        
        guard let selectedMovieCell = sender else {fatalError("Unexpected sender: \(sender!)")}
        
        guard let indexPath = tableView.indexPath(for: selectedMovieCell as! UITableViewCell) else {fatalError("The selected cell is not being displayed by the table")}
        
        destinationVC.film = tableViewDisplayFilms?[indexPath.row]
        
    }
    
}

//MARK: - Search Bar Delegate Methods

extension BoxOfficeTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchQuery = searchBar.text else {fatalError("Search bar Text is nil?")}
        
        if !searchQuery.isEmpty {
            //User search: boxOfficeSearch is false
            searchOMDB(titles: [searchBar.text!], boxOfficeSearch: false)
            
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        let filterPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        tableViewDisplayFilms = filmDatabase?.filter(filterPredicate).sorted(byKeyPath: "title")
        
        tableView.reloadData()
        
        if searchText.count == 0 {
            tableViewDisplayFilms = boxOfficeFilms
            tableView.reloadData()
        }
        
    }
    
}
