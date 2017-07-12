//
//  ResultsTableViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/11/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit


class TemplatesViewController: LoadingTableViewController {

    private var templatesList: TemplatesList? {
        didSet {
            if let templatesList = self.templatesList {
                if templatesList.size() > 0 {
                    self.tableView.reloadData()
                    self.hideNothingFoundView()
                } else {
                    self.showNothingFoundView()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if  let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: AppManager.sharedManager.selectedMine), let mineUrl = mine.url {
            self.mineUrl = mineUrl
            self.fetchTemplates(mineUrl: mineUrl)
        }
    }

    override func mineSelected(_ notification: NSNotification) {
        self.startSpinner()
        self.templatesList = TemplatesList(withTemplates: [], mine: mineUrl)
        self.hideNothingFoundLabel()
        if let mineName = notification.userInfo?["mineName"] as? String {
            if let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: mineName) {
                self.configureNavBar(mine: mine, shouldShowMenuButton: true)
                if let mineUrl = mine.url {
                    self.mineUrl = mineUrl
                    self.fetchTemplates(mineUrl: mineUrl)
                }
            }
        }
    }
    
    private func fetchTemplates(mineUrl: String) {
        IntermineAPIClient.fetchTemplates(mineUrl: mineUrl) { (templatesList, error) in
            guard let list = templatesList else {
                self.stopSpinner()
                self.showNothingFoundView()
                if let error = error {
                    self.alert(message: NetworkErrorHandler.getErrorMessage(errorType: error))
                }
                return
            }
            self.templatesList = list
            self.stopSpinner()
        }
    }
    
    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.templatesList {
            return list.size()
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TemplateTableViewCell.identifier, for: indexPath) as! TemplateTableViewCell
        if let template = templatesList?.templateAtIndex(index: indexPath.row) {
            cell.template = template
        }
        return cell
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let template = templatesList?.templateAtIndex(index: indexPath.row),
            let templateDetail = TemplateDetailTableViewController.templateDetailTableViewController(withTemplate: template) {
            self.navigationController?.pushViewController(templateDetail, animated: true)
        }
    }
}
