//
//  HistoryTableViewController.swift
//  ChanceOfWeather
//
//  Created by Jonathan Archille on 12/19/16.
//  Copyright © 2016 The Iron Yard. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController
{

    var savedHistory = [Weather]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return savedHistory.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        
        let forecast = savedHistory[indexPath.row]
        cell.textLabel?.text = forecast.locationName
        
        return cell
    }

}
