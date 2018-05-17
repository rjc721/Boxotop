//
//  BoxOfficeTableViewController.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/14/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//
//  Use of Movieglu API is Restricted to 75 Requests
//  If limit is reached, uncomment lines 33 and 218, comment lines 207 through 216
//  to use Movies Array as substitute for titles returned from Movieglu

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
    
    //var movies = ["Deadpool 2", "Avengers: Infinity War", "Sherlock Gnomes", "I Feel Pretty", "Life of the Party", "Breaking In", "The Guernsey Literary and Potato Peel Pie Society", "A Quiet Place", "Rampage", "Entebbe", "Peter Rabbit", "The Strangers: Prey at Night", "The Greatest Showman", "Tully", "Truth or Dare"]   //If Movieglu API request limit reached
    
    enum TableViewDisplayType {
        case nowPlaying
        case reviewed
        case searchHistory
        case searchResults
    }
    
    var tableDisplayType: TableViewDisplayType = .nowPlaying
    var tableTypeBeforeSearch: TableViewDisplayType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Nav controller does not exist")}
        navBar.barTintColor = navBarGreen
        navBar.tintColor = UIColor.flatBlack()
        navBar.titleTextAttributes = [NSAttributedStringKey.font : UIFont(name: "Futura-Bold", size: 24.0)!]
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    //MARK: - Refresh Button Tapped
    
    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        
        SVProgressHUD.show()
        tableDisplayType = .nowPlaying
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        loadBoxOfficeFilms()    //Refresh button reloads movies Now Playing
    }
    
    //MARK: - Sort Button Tapped
    
    @IBAction func sortingButtonTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let nowPlayingAction = UIAlertAction(title: "Show Now Playing", style: .default) { (action) in
            
            self.tableViewDisplayFilms = self.boxOfficeFilms
            self.tableDisplayType = .nowPlaying
            self.searchBar.text = ""
            self.searchBar.resignFirstResponder()
            self.tableView.reloadData()
        }
        let reviewedAlert = UIAlertAction(title: "Reviewed Films", style: .default) { (action) in
            self.tableViewDisplayFilms = self.filmDatabase?.filter("userRating > %@", 0)
            self.tableDisplayType = .reviewed
            self.searchBar.text = ""
            self.searchBar.resignFirstResponder()
            self.tableView.reloadData()
        }
        let historyAction = UIAlertAction(title: "Search History", style: .default) { (action) in
            self.tableViewDisplayFilms = self.filmDatabase?.filter("isNowPlaying == %@", false).sorted(byKeyPath: "title")
            self.tableDisplayType = .searchHistory
            self.searchBar.text = ""
            self.searchBar.resignFirstResponder()
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(nowPlayingAction)
        alert.addAction(reviewedAlert)
        alert.addAction(historyAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Tableview methods
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch tableDisplayType {
        case .nowPlaying:
            return "Now Playing"
        case .reviewed:
            return "Reviewed Films"
        case .searchHistory:
            return "Search History"
        case .searchResults:
            return "Search Results"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30.0
    }
    
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
                
                var cellText = ""
                switch tableDisplayType {
                case .nowPlaying:
                    cellText = "No films meet your filter terms. Hit Search to search for titles online!"
                case .reviewed:
                    cellText = "You haven't reviewed any films yet or your filter terms match no results."
                case .searchHistory:
                    cellText = "No films in search history match. Hit Search to find movies online!"
                case .searchResults:
                    cellText = "Search yielded no results"
                }
                cell.textLabel?.text = cellText
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
        
        //searchOMDB(movieTitles: movies, searchType: .boxOffice)   //If Movieglu API request limit reached
    }
    
    //MARK: - Open Movie Database API and JSON Parsing
    func searchOMDB(movieTitles: [String], searchType: SearchType) {
        
        movieDBAPIHandler.searchOpenMDB(titles: movieTitles) { (json, movieTitle, error)  in
            if error != nil {
                print("OMDB API Error finding \(movieTitle): \(error!)")
            } else {
               
                if let searchResultsJSON = json {
                    
                    let (searchResults, idArray) = self.movieJSONParser.parseSearchResultsJSON(searchResultsJSON, movieTitle: movieTitle)
                    
                    switch searchType {
                    case .boxOffice:
                        self.checkForMostRelevant(in: searchResults)
                    case .user:
                        self.loadMoviesFromOMDB(using: idArray, searchType: .user)
                       
                    }
                }
            }
        }
    }
    
    //Only checking relevance on box office search
    //Relevance for User searches is determined by OMDB
    func checkForMostRelevant(in results: [SearchResultOMDB]) {
        
        let searchChecker = SearchRelevanceChecker()
        let matchingFilm = searchChecker.check(results: results)
        
        loadMoviesFromOMDB(using: [matchingFilm], searchType: .boxOffice)
    }
    
    func loadMoviesFromOMDB(using imdbIDs: [String], searchType: SearchType) {
       
        movieDBAPIHandler.loadFromOMDB(imdbIDs: imdbIDs) { (json, imdbID, error) in
            if error != nil {
                print("Error Loading imdbID: \(imdbID), \(error!)")
            } else {
              
                if let loadResultsJSON = json {
                    let newFilm = self.movieJSONParser.createFilm(from: loadResultsJSON, imdbID: imdbID, searchType: searchType)
                    self.updateRealm(with: newFilm)
                    
                }
            }
        }
    }
  
    //MARK: - Database Methods - Realm
    
    func updateRealm(with film: Film) {
        
        let duplicateChecker = DuplicateFilmChecker()
        let filmExistsInDatabase = duplicateChecker.searchDatabaseFor(film: film)
        
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
        
        updateUI()
    }
 
    func updateUI() {
        
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
        SVProgressHUD.dismiss() //Dismiss Progress HUD, Load Complete
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
            SVProgressHUD.show()
            tableTypeBeforeSearch = tableDisplayType
            tableDisplayType = .searchResults
            
            searchOMDB(movieTitles: [searchBar.text!], searchType: .user)
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print(tableDisplayType)
       
        let filterPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        switch tableDisplayType {
        case .nowPlaying:
            tableViewDisplayFilms = boxOfficeFilms?.filter(filterPredicate).sorted(byKeyPath: "title")
        case .reviewed:
            tableViewDisplayFilms = filmDatabase?.filter("userRating > %@", 0).filter(filterPredicate).sorted(byKeyPath: "title")
        case .searchHistory:
            tableViewDisplayFilms = filmDatabase?.filter("isNowPlaying == %@", false).filter(filterPredicate).sorted(byKeyPath: "title")
        default: break
        }
        
        tableView.reloadData()
        
        if searchText.count == 0 {
            
            if tableTypeBeforeSearch != nil {
                tableDisplayType = tableTypeBeforeSearch!
                tableTypeBeforeSearch = nil
            }
           
            switch tableDisplayType {
            case .nowPlaying:
                tableViewDisplayFilms = boxOfficeFilms
            case .reviewed:
                tableViewDisplayFilms = filmDatabase?.filter("userRating > %@", 0)
            case .searchHistory:
                tableViewDisplayFilms = filmDatabase?.filter("isNowPlaying == %@", false).sorted(byKeyPath: "title")
            default: break
            }
            
            tableView.reloadData()
        }
    }
}
