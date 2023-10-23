//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell

            // Get the movie associated table view row
            let post = posts[indexPath.row]

            // Configure the cell (i.e., update UI elements like labels, image views, etc.)

            // Unwrap the optional poster path
        if let photo = post.photos.first {

            let url = photo.originalSize.url
                // Use the Nuke library's load image function to (async) fetch and load the image from the image URL.
                Nuke.loadImage(with: url, into: cell.postImageView)
            }

            // Set the text on the labels
            cell.postContentLabel.text = post.summary

            // Return the cell for use in the respective table view row
            return cell
    }
    

    @IBOutlet weak var postTableView: UITableView!
    
    private var posts: [Post] = []
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
        // Add the refresh control to the table view
            if #available(iOS 10.0, *) {
                postTableView.refreshControl = refreshControl
            } else {
                postTableView.addSubview(refreshControl)
            }
        
        postTableView.dataSource = self
        
        fetchPosts()
    }


    @objc func refreshTableData() {
        // Fetch new data or perform any necessary updates
        fetchPosts()
        // After updating the data, reload the table view
        self.postTableView.reloadData()

        // End the refreshing process
        refreshControl.endRefreshing()
    }

    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in
                    self?.posts = blog.response.posts
                    let posts = blog.response.posts
                    self?.postTableView.reloadData()

                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
