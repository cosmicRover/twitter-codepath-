//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Joy Paul on 3/4/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController{

    //vars to handle tweets and tweet API
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    let tweetAPI = "https://api.twitter.com/1.1/statuses/home_timeline.json"
    
    //var for pull to refresh
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setsCellHeights()
        loadTweets()
        pullToRefresh()
    }
    
    // incoeporates pull to refresh
    func pullToRefresh(){
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    
    //configures cell height
    func setsCellHeights(){
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    //gets called to load tweets
    @objc func loadTweets(){
        numberOfTweets = 10
        let tweetParams = ["count" : numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetAPI, parameters: tweetParams as [String: Any], success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            
            for x in tweets{
                self.tweetArray.append(x)
            }
            
            self.tableView.reloadData()
            
            //refreshControl gets stopped once done
            self.myRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print(Error)
        })
        
    }
    
    //helps fetch more past tweets
    func loadMoreTweetsOnScrollEnd(){
        numberOfTweets = numberOfTweets + 10
        let tweetParams = ["count" : numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetAPI, parameters: tweetParams as [String: Any], success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            
            for x in tweets{
                self.tweetArray.append(x)
            }
            
            self.tableView.reloadData()
            
        }, failure: { (Error) in
            print(Error)
        })
    }
    
    //gets triggered when user scrolls to the bott0om of the tableView
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        indexPath.row + 1 == tweetArray.count ? loadMoreTweetsOnScrollEnd() : nil
    }
    
    // does logout call to api, writes to Userdefaults and sends user back to the isInitialView
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        debugPrint("logout pressed")
        TwitterAPICaller.client?.logout()
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        dismiss(animated: true, completion: nil)
    }
    

    //configures cell and returns it
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
        
        let userInfo = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.name.text = userInfo["name"] as? String
        cell.tweet.text = tweetArray[indexPath.row]["text"] as? String
        
        //fetches the user profile pic from the given pic url
        let profileImageUrl = URL(string: userInfo["profile_image_url_https"] as! String)
        let data = try? Data(contentsOf: profileImageUrl!)
        
        //if pic exits, runn this
        if let imageData = data{
            cell.profilePic.image = UIImage(data: imageData)
            
            //rounds and beautifies cell
            //cell.profilePic.layer.borderWidth = 1
            cell.profilePic.layer.masksToBounds = false
            //cell.profilePic.layer.borderColor = UIColor.black.cgColor
            cell.profilePic.layer.cornerRadius = cell.profilePic.frame.height/2
            cell.profilePic.clipsToBounds = true
        } else {
            cell.profilePic.image = #imageLiteral(resourceName: "profile-Icon")
        }
        
        return cell
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // # of cell sections on a row
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // # of cells
        return tweetArray.count
    }


}
