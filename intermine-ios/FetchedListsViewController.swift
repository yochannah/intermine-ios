//
//  FetchedListsViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/16/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class FetchedListsViewController: LoadingTableViewController {
    
    
    private var viewsQuery: String?
    private var currentOffset: Int = 0
    private var params: [String: String]?
    private var type: String?
    
    private var lists: [[String: String]] = [] {
        didSet {
            if self.lists.count > 0 {
                UIView.transition(with: self.tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                }, completion: nil)
                self.hideNothingFoundView()
            } else {
                self.showNothingFoundView()
            }
        }
    }
    
    // MARK: Load from storyboard
    
    class func fetchedListsViewController(withMineUrl: String, viewsQuery: String, type: String) -> FetchedListsViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FetchedListsVC") as? FetchedListsViewController
        vc?.mineUrl = withMineUrl
        vc?.viewsQuery = viewsQuery
        vc?.type = type
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideMenuButton = true
        self.loadTemplateResultsWithOffset(offset: self.currentOffset)

    }
    
    private func loadTemplateResultsWithOffset(offset: Int) {
        self.params?["start"] = "\(offset)"
        if let mineUrl = self.mineUrl, let queryString = self.viewsQuery {
            IntermineAPIClient.fetchSingleList(mineUrl: mineUrl, queryString: queryString, completion: { (res, params, error) in
                self.params = params
                self.processDataResult(res: res, data: &self.lists)
                if self.currentOffset == 0 {
                    self.stopSpinner()
                }
                if let error = error {
                    self.alert(message: NetworkErrorHandler.getErrorMessage(errorType: error))
                }
            })
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FetchedCell.identifier, for: indexPath) as! FetchedCell
        cell.representedData = lists[indexPath.row]
        if let type = self.type {
            cell.typeColor = TypeColorDefine.getBackgroundColor(categoryType: type)
        }
        return cell
    }
    
    // MARK: Scroll view delegate
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maximumOffset - currentOffset <= 10.0) {
            if self.lists.count > General.pageSize && self.currentOffset + General.pageSize < self.lists.count {
                self.currentOffset += General.pageSize
                self.loadTemplateResultsWithOffset(offset: self.currentOffset)
            }
        }
    }

}
