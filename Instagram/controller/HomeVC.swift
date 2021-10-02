//
//  HomeVC.swift
//  Instagram
//
//  Created by 吴洲洋 on 2021/9/19.
//

import UIKit

private let reuseIdentifier = "Cell"

class HomeVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    @objc private var refresher: UIRefreshControl!
    private var page: Int = 12
    private var puuidArray = [String]()
    private var picArray = [AVFile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.alwaysBounceVertical = true
        navigationItem.title = AVUser.current()?.username?.uppercased()
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(getter: refresher), for: UIControl.Event.valueChanged)
        collectionView?.addSubview(refresher)
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        loadPosts()
    }

    @objc func refresh() {
        collectionView?.reloadData()
    }

    func loadPosts() {
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: AVUser.current()?.username!)
        query.limit = page
        query.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            if error == nil {
                // 清空两个数组
                self.puuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)

                for object in objects! {
                    // 将查询到的数据添加到数组中
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                }
                self.collectionView?.reloadData()
            } else {
                print("加载Posts失败 \(String(describing: error?.localizedDescription))")
            }
        }
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using [segue destinationViewController].
         // Pass the selected object to the new view controller.
     }
     */

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return picArray.count * 20
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        picArray[0].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            } else {
                print("加载照片失败，\(String(describing: error?.localizedDescription))")
            }
        }
        // Configure the cell

        return cell
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - view.frame.height {
            loadMore()
        }
    }

    func loadMore() {
        if page <= picArray.count {
            page = page + 12
            let query = AVQuery(className: "Posts")
            query.whereKey("username", equalTo: AVUser.current()?.username)
            query.limit = page
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
              // 查询成功
              if error == nil {
                // 清空两个数组
                self.puuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                for object in objects! {
                  // 将查询到的数据添加到数组中
                  self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                  self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                }
                  print("loaded + \(self.page)")
                          self.collectionView?.reloadData()
                        }else {
                          print(error?.localizedDescription)
                        }
                      })
                    }
                  }
    

    // MARK: UICollectionViewDelegate

    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
         return true
     }
     */

    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
         return true
     }
     */

    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
         return false
     }

     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
         return false
     }

     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {

     }
     */

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("显示Home Header")

        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        header.fullnameLbl.text = (AVUser.current()?.object(forKey: "fullname") as? String)?.uppercased()
        header.webTxt.text = AVUser.current()?.object(forKey: "web") as? String
        header.webTxt.sizeToFit()
        header.bioLbl.text = AVUser.current()?.object(forKey: "bio") as? String
        header.bioLbl.sizeToFit()
        let avaQuery = AVUser.current()?.object(forKey: "ava") as! AVFile
        avaQuery.getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                header.avaImg.image = UIImage(data: data!)
            } else {
                print("加载用户头像失败:\(String(describing: error?.localizedDescription))")
            }
        }
        let currentUser = AVUser.current()!
        let postsQuery = AVQuery(className: "Posts")
        postsQuery.whereKey("username", equalTo: currentUser.username)
        postsQuery.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                header.posts.text = String(count)
            }
        }
        let followersQuery = AVQuery(className: "_Follower")
        followersQuery.whereKey("user", equalTo: currentUser)
        followersQuery.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                header.followers.text = String(count)
            }
        }

        let followeesQuery = AVQuery(className: "_Followee")
        followeesQuery.whereKey("user", equalTo: currentUser)
        followeesQuery.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                header.followings.text = String(count)
            }
        }

        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsTap(_:)))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)

        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTap(_:)))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)

        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(followingsTap(_:)))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)

        return header
    }

    @objc func postsTap(_ recognizer: UITapGestureRecognizer) {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            collectionView?.scrollToItem(at: index, at: UICollectionView.ScrollPosition.top, animated: true)
        }
    }

    @objc func followersTap(_ recognizer: UITapGestureRecognizer) {
        let followers = storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followers.user = AVUser.current()!.username!
        followers.show = "关 注 者"
        navigationController?.pushViewController(followers, animated: true)
    }

    @objc func followingsTap(_ recognizer: UITapGestureRecognizer) {
        let followings = storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followings.user = AVUser.current()!.username!
        followings.show = "关 注"
        navigationController?.pushViewController(followings, animated: true)
    }

    @IBAction func logout(_ sender: Any) {
        // 退出用户登录
        AVUser.logOut()
        // 从UserDefaults中移除用户登录记录
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.synchronize()
        // 设置应用程序的rootViewController为登录控制器
        let signIn = storyboard?.instantiateViewController(withIdentifier: "SignInVC")
        let sceneDelegate: SceneDelegate = view.window?.windowScene?.delegate as! SceneDelegate
        sceneDelegate.window?.rootViewController = signIn
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: view.frame.width / 3, height: view.frame.width / 3)
        return size
    }

    @objc func reload(notification: Notification) {
        collectionView?.reloadData()
    }
}
