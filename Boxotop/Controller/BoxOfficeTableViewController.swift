//
//  BoxOfficeTableViewController.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/14/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import UIKit
import ChameleonFramework

class BoxOfficeTableViewController: UITableViewController {
    
    var movies = ["Avengers", "Breaking In", "Life of the party", "Overboard", "A Quiet Place", "I Feel Pretty", "Rampage", "Tully", "Black Panther", "A Wrinkle In Time"]

    override func viewDidLoad() {
        super.viewDidLoad()

    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return movies.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "filmCell", for: indexPath)
        cell.textLabel?.text = movies[indexPath.row]
        cell.backgroundColor = ((indexPath.row % 2) == 1) ? UIColor.flatMintColorDark() : UIColor.white


        return cell
    }
    
    // MARK: - Navigation

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destinationVC = segue.destination as? MovieViewController else {fatalError("Wrong destination view controller")}
        
        guard let selectedMovieCell = sender else {fatalError("Unexpected sender: \(sender!)")}
        
        guard let indexPath = tableView.indexPath(for: selectedMovieCell as! UITableViewCell) else {fatalError("The selected cell is not being displayed by the table")}
        
        destinationVC.movie = movies[indexPath.row]
        
    }
    

}
