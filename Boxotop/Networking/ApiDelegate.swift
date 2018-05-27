//
//  ApiDelegate.swift
//  Boxotop
//
//  Created by Ryan Chingway on 5/27/18.
//  Copyright © 2018 Ryan Chingway. All rights reserved.
//

import Foundation

class ApiDelegate: NSObject, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    var dataCompletionHandler: ((Data, String?, String?, ApiCallType, Bool) -> Void)?
    var retryHandler: ((URLSessionDataTask, ApiCallType, String?, String?) -> Void)?
    
    var task: URLSessionDataTask?
    let retryTimer: Double = 10
    var isTaskRetry: Bool?
    
    var hasReceivedResponse = false
    private var timer: Timer?
    
    var movieTitle: String?     //Custom properties for Movie Database API, passthrough variables
    var imdbID: String?
    var callType: ApiCallType?
    
    private var myData: Data?
   
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        hasReceivedResponse = true
        
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("Data Task Error: \(error!)")
        }
        
        if let compHandler = dataCompletionHandler, let data = myData {
            
            guard let apiCallType = callType else {fatalError("call type not set")}
            
            switch apiCallType {
            case .load:
                guard let id = imdbID else {fatalError("imdbID not set")}
                compHandler(data, nil, id, apiCallType, error != nil)
            case .search:
                guard let title = movieTitle else {fatalError("title not set")}
                compHandler(data, title, nil, apiCallType, error != nil)
            }
        
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {

        myData = data
    }
    
    func scheduleTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: retryTimer, repeats: false) { (timer) in
            self.checkForResponse()
        }
    }
    
    func checkForResponse() {
        
        if hasReceivedResponse {
            timer?.invalidate()
        } else {
            
            if isTaskRetry == true {
                print("Task failed second time too")
                task?.cancel()  //Task gets one retry only
            
            } else {
                print("Timer went off, retrying task...")
                //return to try task over again
               
                if let redoHandler = retryHandler, let taskToRetry = task {
                    
                    guard let apiCallType = callType else {fatalError("call type not set")}
                    
                    switch apiCallType {
                    case .load:
                        guard let id = imdbID else {fatalError("imdbID not set")}
                        redoHandler(taskToRetry, apiCallType, nil, id)
                    case .search:
                        guard let title = movieTitle else {fatalError("title not set")}
                        redoHandler(taskToRetry, apiCallType, title, nil)
                    }
                }
            
            }
        }
    }
    
}
