//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Philip Alexander on 10/3/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    
    let myRefreshControl = UIRefreshControl();
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    
    @objc func loadTweets() {
        numberOfTweets = 20
        let reqUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let reqParams = ["count": numberOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(
            url: reqUrl,
            parameters: reqParams,
            success: { (tweets:[NSDictionary]) in
                self.tweetArray.removeAll()
                for tweet in tweets {
                    self.tweetArray.append(tweet)
                }
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
            },
            failure: { Error in
                print("Couldn't retrieve tweets!")
            })
    }
    
    func loadMoreTweets() {
        let reqUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweets+=20
        let reqParams = ["count": numberOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(
            url: reqUrl,
            parameters: reqParams,
            success: { (tweets:[NSDictionary]) in
                self.tweetArray.removeAll()
                for tweet in tweets {
                    self.tweetArray.append(tweet)
                }
                self.tableView.reloadData()
            },
            failure: { Error in
                print("Couldn't retrieve tweets!")
            })
        
    }
    
    

    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for:indexPath) as! TweetCell
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as? String
        
        let imageURL = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageURL!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        return cell
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }

}
