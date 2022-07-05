//
//  ViewController.swift
//  ios-dca-calculator
//
//  Created by ibrahim uysal on 3.07.2022.
//

import UIKit
import Combine

class SearchTableViewController: UITableViewController {
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name or symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    @Published private var searchQuery = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        observeForm()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
    }
    
    private func observeForm() {
        
        $searchQuery
            .debounce(for: .milliseconds(750), scheduler: RunLoop.main, options: nil)
            .sink { [unowned self] (searchQuery) in
                self.apiService.fetchSymbolsPublisher(keywords: searchQuery).sink { (completion) in
                    switch completion {
                    case .failure(let error):
                        print(error)
                    case .finished: break
                    }
                } receiveValue: { (searchResults) in
                    print(searchResults)
                }.store(in: &self.subscribers)
            }.store(in: &subscribers)
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        return cell
    }
    
}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text, !searchQuery.isEmpty else { return }
        self.searchQuery = searchQuery
    }
    
}
