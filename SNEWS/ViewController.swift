//
//  ViewController.swift
//  SNEWS
//
//  Created by Sarthak Agrawal on 19/02/23.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(SnewSTableViewCell.self,
                       forCellReuseIdentifier: SnewSTableViewCell.identifier)
        return table
    }()
    
    private let searchVC = UISearchController(searchResultsController: nil)
    
    private var articles = [Article]()
    private var viewModels = [SnewsTableViewCellViewModel]()
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "SnewS"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    
        fetchTopStories()
        createSearchBar()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func createSearchBar(){
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
        
    }
    
    private func fetchTopStories(){
        apiCaller.shared.getTopStories{ [weak self] result in
            switch result{
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    SnewsTableViewCellViewModel(
                        title: $0.title,
                        subtitle: $0.description ?? "No Description" ,
                        imageURL: URL(string: $0.urlToImage ?? ""),
                        url: $0.url ?? "No link"
                    )
                })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.searchVC.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SnewSTableViewCell.identifier,
            for: indexPath
        ) as? SnewSTableViewCell else{
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = viewModels[indexPath.row]
        
        guard let url = URL(string: article.url ?? "") else{
            return
        }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    //Search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else{
            return
        }
        
        apiCaller.shared.search(with: text){ [weak self] result in
            switch result{
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    SnewsTableViewCellViewModel(
                        title: $0.title,
                        subtitle: $0.description ?? "No Description" ,
                        imageURL: URL(string: $0.urlToImage ?? ""),
                        url: $0.url ?? "No link"
                    )
                })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }


}

