//
//  CommentsViewModel.swift
//  iOS xkcd Challenge
//
//  Created by David Troupe on 1/28/19.
//  Copyright © 2019 Studio. All rights reserved.
//

import Foundation

protocol CommicViewModelProtocol: class {
  var comics: [Comic] { get }
  var isLoading: Bool { get}
  
  init()
  
  func fetchComics(onError: ErrorCallback?, onSuccess: SuccessCallback?)
  func fetchMoreComics(onError: ErrorCallback?, onSuccess: MoreComicsCallback?)
  func numberOfSections() -> Int
  func numberOfRows() -> Int
}

final class ComicViewModel: CommicViewModelProtocol {
  var comics: [Comic] = []
  var isLoading: Bool = false
  
  func fetchComics(onError: ErrorCallback?, onSuccess: SuccessCallback?) {
    let ids = Array(1...15)
    
    RequestManager.shared.fetchComics(withIDs: ids, completionHandler: { comicArray in
      if comicArray.isEmpty {
        print("#37 -- I got nothing!")
        self.comics.removeAll()
        onError?(RequestError.noData.getError(withCode: 1))
        return
      }
      let sorted = comicArray.sorted { $0.number < $1.number}
      self.comics = sorted
      onSuccess?(true)
    })
  }
  
  func fetchMoreComics(onError: ErrorCallback?, onSuccess: MoreComicsCallback?) {
    guard !isLoading else { return }
    guard let lastID = comics.last?.number else { return }
    
    isLoading = true
    let initialCount = comics.count // qwe -- this isn't needed?
    let ids = Array(lastID + 1...lastID + 16)
    
    RequestManager.shared.fetchComics(withIDs: ids, completionHandler: { [weak self] comicArray in
      if comicArray.isEmpty {
        onError?(RequestError.noData.getError(withCode: 2))
        self?.isLoading = false
        return
      }
      
      let sorted = comicArray.sorted { $0.number < $1.number}
      let newComicCount = sorted.count
      self?.comics += sorted
      self?.isLoading = false
      onSuccess?(newComicCount)
    })
  }
  
  func numberOfSections() -> Int {
    return 1
  }
  
  func numberOfRows() -> Int {
    return comics.count
  }
}
