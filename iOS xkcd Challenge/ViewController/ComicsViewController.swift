//
//  ComicsViewController.swift
//  iOS xkcd Challenge
//
//  Created by David Troupe on 1/28/19.
//  Copyright © 2019 Studio. All rights reserved.
//

import UIKit
import Anchorage

class ComicsViewController: UIViewController {
  
  private let viewModel: CommicViewModelProtocol
  private let tableView = UITableView()
  private final let cellIdentifier: String = "comicCell"
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.viewModel = ComicViewModel()
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.viewModel = ComicViewModel()
    super.init(coder: aDecoder)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    fetchComics()
  }
  
  private func setupUI() {
    view.addSubview(tableView)
    tableView.edgeAnchors == view.edgeAnchors
    tableView.backgroundColor = UIColor.white
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .none
    tableView.estimatedRowHeight = 300
    tableView.estimatedSectionHeaderHeight = 0
    tableView.estimatedSectionFooterHeight = 0
    tableView.register(ComicCell.self, forCellReuseIdentifier: cellIdentifier)
  }
  
  private func fetchComics() {
    viewModel.fetchComics(onError: { error in
      print("Error: \(error.localizedDescription)")
    }, onSuccess: { [weak self] success in
      self?.tableView.reloadData()
    })
  }
}

extension ComicsViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.numberOfSections()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRows()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ComicCell
    cell.configure(withComic: viewModel.comics[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard !viewModel.isLoading else { return }
    
    if indexPath.row == viewModel.comics.count - 5 && indexPath.row + 6 > viewModel.comics.count {
      viewModel.fetchMoreComics(onError: { error in
        print("#37 -- error getting more comics!")
      }, onSuccess: { [weak self] newComicCount in
        // should insert rows but reload because I'm lazy
        guard newComicCount > 0 else { return }
        
        let lastItemIndex = tableView.numberOfRows(inSection: 0) - 1
        let indexPaths = (lastItemIndex + 1 ... lastItemIndex + newComicCount).map { IndexPath(row: $0, section: 0) }
        self?.tableView.setContentOffset(tableView.contentOffset, animated: false)
        self?.tableView.beginUpdates()
        self?.tableView.insertRows(at: indexPaths, with: .none)
        self?.tableView.endUpdates()
      })
    }
  }
}

extension ComicsViewController: UITableViewDelegate {}
