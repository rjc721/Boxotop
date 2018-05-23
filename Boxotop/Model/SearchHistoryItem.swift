//
//  SearchHistoryItem.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/22/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//
//  Save user search history and display in tableview

import Foundation
import RealmSwift

class SearchHistoryItem: Object {
    @objc dynamic var searchQuery: String = ""
}
