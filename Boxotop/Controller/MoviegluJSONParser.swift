//
//  MoviegluJSONParser.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/16/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import Foundation
import SwiftyJSON

class MoviegluJSONParser {
    
    func decodeMovieGluJSON(_ json: JSON) -> [String] {
        var nowPlayingTitles = [String]()
        
        let filmCount = json["count"].int!
        
        for index in 0..<filmCount {
            let title = json["films"][index]["film_name"].string!
            nowPlayingTitles.append(title)
        }
        
        return nowPlayingTitles
    }
}
