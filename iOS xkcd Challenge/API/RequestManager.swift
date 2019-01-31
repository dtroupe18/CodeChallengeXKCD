//
//  RequestManager.swift
//  iOS xkcd Challenge
//
//  Created by David Troupe on 1/28/19.
//  Copyright © 2019 Studio. All rights reserved.
//

import Foundation

// Generic callbacks
typealias ErrorCallback = (Error) -> Void
typealias DataCallback = (Data) -> Void
typealias SuccessCallback = (Bool) -> Void
typealias MoreComicsCallback = (Int) -> Void

// Specific type callbacks
typealias ComicCallback = ([Comic]) -> Void

enum RequestError: String, Error {
  case badURL = "Error URL is not working!"
  case noData = "No Data!"
  case decodeFailed = "Failed to decode!"
  
  func getError(withCode code: Int) -> Error {
    return NSError(domain: "", code: code, userInfo: [NSLocalizedDescriptionKey : self.rawValue]) as Error
  }
}

class RequestManager {
  
  private init() {
    // Prevents another instance from being created
  }
  
  static let shared = RequestManager()
  
  private final let endUrlString: String = "info.0.json"
  private final let baseUrlString: String = "http://xkcd.com/"
  
  private func createUrlForComic(number: Int) -> URL? {
    return URL(string: "\(baseUrlString)\(number)/\(endUrlString)")
  }
  
  private func createUrlsFor(ids: [Int]) -> [URL] {
    var urls: [URL] = []
    
    for id in ids {
      if let idURL = createUrlForComic(number: id) {
        urls.append(idURL)
      }
    }
    
    return urls
  }
  
  func fetchComics(withIDs ids: [Int], completionHandler: ComicCallback?) {
    
    let urls = createUrlsFor(ids: ids)
    var comics: [Comic] = []
    
    let group = DispatchGroup()
    let serialQueue = DispatchQueue(label: "serialQueue")
    
    urls.forEach { url in
      group.enter() // add download to this process
      URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
        
        guard let data = data, error == nil else { group.leave(); return }
        
        do {
          let comic = try JSONDecoder().decode(Comic.self, from: data)
          
          serialQueue.async {
            comics.append(comic)
            group.leave()
          }
        } catch {
          print("Decode Error: \(error)")
          group.leave()
        }
        }.resume()
    }
    
    group.notify(queue: .main) {
      // this will be executed once for each group.enter() call, a group.leave() has been executed
      completionHandler?(comics)
    }
  }
}
