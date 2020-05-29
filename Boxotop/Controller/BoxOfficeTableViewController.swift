//
//  BoxOfficeTableViewController.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/14/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//
//  Use of Movieglu API is Restricted to 75 Requests
//  If limit is reached, uncomment lines 33 and 290, comment lines 276 through 288
//  to use Movies Array as substitute for titles returned from Movieglu

import UIKit
import RealmSwift
import SVProgressHUD

class BoxOfficeTableViewController: UITableViewController, OpenMovieDBDelegate {
    
    private let realm = try! Realm()                    //Initiate Realm as database
    private var boxOfficeFilms: Results<Film>?          //Contains movies Now Playing
    private var tableViewDisplayFilms: Results<Film>?   //Contains movies being shown in table
    private var filmDatabase: Results<Film>?            //Complete database
    private var searchHistory: Results<SearchHistoryItem>?  //Search history
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    private var searchType: SearchType?
    
    private let movieDBAPIHandler = OpenMDBAPIHandler()
    
    private let imageCache = NSCache<NSString, UIImage>()
    
//    var movies = ["Solo: A Star Wars Story", "Deadpool 2", "Sherlock Gnomes", "Avengers: Infinity War", "Show Dogs", "I Feel Pretty", "Peter Rabbit", "On Chesil Beach", "Life of the Party", "The Little Vampire", "A Quiet Place", "The Greatest Showman", "Duck Duck Goose"]   //If Movieglu API request limit reached
    
    enum TableViewDisplayType {
        case nowPlaying
        case reviewed
        case searchHistory
        case searchResults
    }
    
    private var tableDisplayType: TableViewDisplayType = .nowPlaying
    private var tableTypeBeforeSearch: TableViewDisplayType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        searchType = .boxOffice
        
        movieDBAPIHandler.delegate = self
        
        setupNavBar()
        loadDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    func setupNavBar() {
        
        //Green color from the test design documentation from "Elite Design"
        let navBarGreen = UIColor(red: 0.36, green: 0.62, blue: 0.255, alpha: 1)
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Nav controller does not exist")}
        navBar.barTintColor = navBarGreen
        navBar.tintColor = UIColor.black
        navBar.titleTextAttributes = [NSAttributedStringKey.font : UIFont(name: "Futura-Bold", size: 24.0)!]
        searchBar.barTintColor = UIColor.white
    }
    
    func loadDatabase() {
        if realm.isEmpty {
            SVProgressHUD.show()    //Show loading to user
            loadBoxOfficeFilms()    //Database empty on first use, load films
        } else {
            filmDatabase = realm.objects(Film.self)
            boxOfficeFilms = filmDatabase?.filter("isNowPlaying == %@", true).sorted(byKeyPath: "title")
            tableViewDisplayFilms = boxOfficeFilms
            searchHistory = realm.objects(SearchHistoryItem.self)
        }
    }
    
    //MARK: - Refresh Button Tapped
    
    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        
        searchType = .boxOffice
        
        SVProgressHUD.show()
        tableDisplayType = .nowPlaying
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        loadBoxOfficeFilms()    //Reloads movies Now Playing
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
            self.tableViewDisplayFilms = self.filmDatabase?.filter("userRating > %@", 0).sorted(byKeyPath: "title")
            self.tableDisplayType = .reviewed
            self.searchBar.text = ""
            self.searchBar.resignFirstResponder()
            self.tableView.reloadData()
        }
        let historyAction = UIAlertAction(title: "Search History", style: .default) { (action) in
            self.tableDisplayType = .searchHistory
            self.searchBar.text = ""
            self.searchBar.resignFirstResponder()
            self.tableView.reloadData()
        }
        let deleteAction = UIAlertAction(title: "Delete Search History", style: .destructive) { (action) in
            
            let searchItems = self.searchHistory
            
            if searchItems != nil {
                
                DispatchQueue.main.async {
                    do {
                        try self.realm.write {
                            self.realm.delete(searchItems!)
                            self.tableView.reloadData()
                        }
                    } catch let error {
                        print("Realm delete error: \(error)")
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(nowPlayingAction)
        alert.addAction(reviewedAlert)
        alert.addAction(historyAction)
        
        if let searchCount = searchHistory?.count, searchCount > 0 {
            alert.addAction(deleteAction)
        }
        
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
        
        if tableDisplayType == .searchHistory {
            if let searchCount = searchHistory?.count {
                return searchCount  > 0 ? searchCount : 1 //Either search history or "no history" cell
            }
            return 1
            
        } else {
            if let filmCount = tableViewDisplayFilms?.count {
                
                return filmCount > 0 ? filmCount : 1    //List exists, show list OR Search cell
            }
            
            return 1        //List not loaded -> Show Loading cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "filmCell", for: indexPath)
        let tableCellGreen = UIColor(red: 0.75, green: 0.859, blue: 0.7, alpha: 1)
        
        if tableDisplayType == .searchHistory {
            cell.imageView?.image = nil
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.isUserInteractionEnabled = false
            
            if searchHistory == nil || searchHistory?.count == 0 {
                cell.textLabel?.text = "Your search history is empty, use Search bar to find your favorite movies!"
            } else {
                cell.textLabel?.text = searchHistory![indexPath.row].searchQuery
            }
        } else {
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
                    case .searchResults:
                        cellText = "Search yielded no results or timed out, please try again."
                    default: break
                    }
                    cell.textLabel?.text = cellText
                }
                if tableViewDisplayFilms!.count > 0 {      //Case - displaying films like normal or filtered
                    let film = tableViewDisplayFilms![indexPath.row]
                    
                    cell.textLabel?.text = film.title
                    cell.textLabel?.numberOfLines = 0
                    cell.textLabel?.lineBreakMode = .byWordWrapping
                    cell.isUserInteractionEnabled = true
                    
                    if let cachedImage = imageCache.object(forKey: NSString(string: film.imdbID)) {
                        cell.imageView?.image = cachedImage
                    } else {
                        let imageToCache = UIImage(data: film.posterImage) ?? #imageLiteral(resourceName: "defaultPhoto")
                        cell.imageView?.image = imageToCache
                        imageCache.setObject(imageToCache, forKey: NSString(string: film.imdbID))
                    }
                }
            } else {                                //Case - Films not yet loaded at launch
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.textLabel?.text = "Loading Data...Make sure you have an Internet connection"
                cell.isUserInteractionEnabled = false
            }
        }
    
        cell.backgroundColor = ((indexPath.row % 2) == 1) ? tableCellGreen : UIColor.white
        
        return cell
    }
    
    
    //MARK: - Movieglu API
    
    func loadBoxOfficeFilms() {
        
        updateNowPlayingFlags()
        
        let movieAPIHandler = MoviegluAPIHandler()

        movieAPIHandler.getNowPlayingFilms { (titles, ids, err) in

            if err == nil {
                guard let titles = titles else {fatalError("Titles not returned from Movieglu")}
                guard let ids = ids else {fatalError("id problems")}
//                self.movieDBAPIHandler.searchOpenMDB(for: titles)
                self.movieDBAPIHandler.loadFromOMDB(with: ids, isBoxOfficeLoad: true)


            } else {
                print("Movieglu Error: \(String(describing: err))")
            }
        }
        
//           movieDBAPIHandler.searchOpenMDB(for: movies) //If Movieglu API request limit reached
        
    }
    
    //MARK: - Open Movie Database API and JSON Parsing
   
    func receivedOMDBSearchResults(result: OmdbResponseToS, movieTitle: String, isError: Bool) {
        
        if isError {
            SVProgressHUD.dismiss()
            self.tableView.isUserInteractionEnabled = true
            
        } else {
            
            let searchInterpreter = SearchResponseInterpreter()
            let (searchResultsArray, imdbIDsArray) = searchInterpreter.interpretResults(result: result, movieTitle: movieTitle)
            
            switch searchType! {
            case .boxOffice:
//                self.checkForMostRelevant(in: searchResultsArray)
                print("changed the way box office films are found, by id now rather than name")
            case .user:
                self.movieDBAPIHandler.loadFromOMDB(with: imdbIDsArray, isBoxOfficeLoad: false)
            }
        }
    }
    
    //Only checking relevance on box office search
    //Relevance for User searches is determined by OMDB
//    func checkForMostRelevant(in results: [SearchResultOMDB]) {
//
//        let searchChecker = SearchRelevanceChecker()
//        let matchingFilm = searchChecker.check(results: results)
//
//        movieDBAPIHandler.loadFromOMDB(with: [matchingFilm])
//    }
  
    func receivedOMDBLoadResults(result: OmdbIDResponse, imdbID: String, isError: Bool) {
        if isError {
            
            SVProgressHUD.dismiss()
            self.tableView.isUserInteractionEnabled = true
            
        } else {
            let movieCreator = FilmCreator()
            
            guard let type = searchType else {fatalError("Search type not set")}
            
            let newFilm = movieCreator.createFilm(from: result, imdbID: imdbID, searchType: type)
            
            self.updateRealm(with: newFilm)
        }
    }
    
    //MARK: - Database Methods - Realm
    
    func updateRealm(with film: Film) {
        
        let duplicateChecker = DuplicateFilmChecker()
        
        guard let typeSearch = searchType else {fatalError("Search type unexpectedly nil")}
        let filmExistsInDatabase = duplicateChecker.searchDatabaseFor(film: film, searchType: typeSearch)
        
        //If it doesn't exist, add it to database
        if !filmExistsInDatabase {
            do {
                try realm.write {
                    realm.add(film)
                    filmDatabase = realm.objects(Film.self)
                    //boxOfficeFilms = filmDatabase?.filter("isNowPlaying == %@", true).sorted(byKeyPath: "title")
                }
            } catch {fatalError("Error loading film into Realm")}
        }
        
        updateUI()
    }
    
    func updateNowPlayingFlags() {
        
        if boxOfficeFilms != nil {
            do {
                try realm.write {
                    //only save rated films and now playing
                    if let objectsToDelete = filmDatabase?.filter("isNowPlaying == %@ AND userRating == %@", false, 0) {
                        realm.delete(objectsToDelete)
                    }
                    
                    for film in boxOfficeFilms! {   //reset now playing Bool to false to check if
                        film.isNowPlaying = false   //film is still now playing in DuplicateFilmChecker
                        
                    }
                }
            } catch {fatalError("Failed to reset Now Playing flags")}
        }
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
        tableView.isUserInteractionEnabled = true
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
        
        searchType = .user
        
        guard let searchQuery = searchBar.text else {fatalError("Search bar Text is nil?")}
        
        if !searchQuery.isEmpty {
            
            let searchItem = SearchHistoryItem()
            searchItem.searchQuery = searchBar.text!
            
            do {
                try realm.write {
                    
                    //only save rated films and now playing
                    if let objectsToDelete = filmDatabase?.filter("isNowPlaying == %@ AND userRating == %@", false, 0) {
                        realm.delete(objectsToDelete)
                    }
                    
                    realm.add(searchItem)
                    searchHistory = realm.objects(SearchHistoryItem.self)
                    
                }
            } catch let error {
                print("Saving search item error: \(error)")
            }
            
            SVProgressHUD.show()
            tableView.isUserInteractionEnabled = false
            tableTypeBeforeSearch = tableDisplayType
            tableDisplayType = .searchResults
            
            movieDBAPIHandler.searchOpenMDB(for: [searchBar.text!])
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
     
        let filterPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        switch tableDisplayType {
        case .nowPlaying:
            tableViewDisplayFilms = boxOfficeFilms?.filter(filterPredicate).sorted(byKeyPath: "title")
        case .reviewed:
            tableViewDisplayFilms = filmDatabase?.filter("userRating > %@", 0).filter(filterPredicate).sorted(byKeyPath: "title")
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
                tableViewDisplayFilms = filmDatabase?.filter("userRating > %@", 0).sorted(byKeyPath: "title")
            default: break
            }
            tableView.reloadData()
        }
    }
}
