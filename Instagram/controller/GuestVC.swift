//
//  GuestVC.swift
//  Instagram
//
//  Created by 吴洲洋 on 2021/9/20.
//

import UIKit

private let reuseIdentifier = "Cell"

var guestArray = [AVUser]()
class GuestVC: UICollectionViewController {
    var puuidArray = [String]()
    var picArray = [AVFile]()
    // 界面对象
    var refresher: UIRefreshControl!
    var page: Int = 12

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        super.viewDidLoad()
        // 允许垂直的拉拽刷新操作
        self.collectionView?.alwaysBounceVertical = true
        // 导航栏的顶部信息
        self.navigationItem.title = guestArray.last?.username
        // 定义导航栏中新的返回按钮
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(self.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn

        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.back(_:)))
        backSwipe.direction = .right
        self.view.addGestureRecognizer(backSwipe)

        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.collectionView?.addSubview(self.refresher)
    }

    @objc func back(_: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        // 从guestArray中移除最后一个AVUser
        if !guestArray.isEmpty {
            guestArray.removeLast()
        }
    }

    @objc func refresh() {
        self.collectionView?.reloadData()
        self.refresher.endRefreshing()
    }

    func loadPosts() {
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: guestArray.last?.username)
        query.limit = self.page
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - view.frame.height {
            loadMore()
        }
    }

    func loadMore() {
        if page <= picArray.count {
            page = page + 12
            let query = AVQuery(className: "Posts")
            query.whereKey("username", equalTo: guestArray.last?.username)
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
    

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using [segue destinationViewController].
         // Pass the selected object to the new view controller.
     }
     */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.picArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        self.picArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription)
            }
        }

        // Configure the cell

        return cell
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
        let infoQuery = AVQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestArray.last?.username)
        infoQuery.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            if error == nil {
                // 判断是否有用户数据
                guard let objects = objects, objects.count > 0 else {
                    return
                }
                // 找到用户的相关信息
                for object in objects {
                    header.fullnameLbl.text = ((object as AnyObject).object(forKey: "fullname") as? String)?.uppercased()
                    header.bioLbl.text = (object as AnyObject).object(forKey: "bio") as? String
                    header.bioLbl.sizeToFit()
                    header.webTxt.text = (object as AnyObject).object(forKey: "web") as? String
                    header.webTxt.sizeToFit()
                    let avaFile = (object as AnyObject).object(forKey: "ava") as? AVFile
                    avaFile?.getDataInBackground { (data: Data?, _: Error?) in
                        header.avaImg.image = UIImage(data: data!)
                    }
                }
            } else {
                print(error?.localizedDescription)
            }
        }

        let followeeQuery = AVUser.current()!.followeeQuery()
        followeeQuery.whereKey("user", equalTo: AVUser.current())
        followeeQuery.whereKey("followee", equalTo: guestArray.last)
        followeeQuery.countObjectsInBackground { (count: Int, error: Error?) in
            guard error == nil else { print(error?.localizedDescription); return }
            if count == 0 {
                header.button.setTitle("关 注", for: .normal)
                header.button.backgroundColor = .lightGray
            } else {
                header.button.setTitle("√ 已关注", for: .normal)
                header.button.backgroundColor = .green
            }
        }

        let posts = AVQuery(className: "Posts")
        posts.whereKey("username", equalTo: guestArray.last?.username)
        posts.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                header.posts.text = "\(count)"
            } else {
                print(error?.localizedDescription)
            }
        }

        // 访客的关注者数
        let followers = AVUser.followerQuery((guestArray.last?.objectId)!)
        followers.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                header.followers.text = "\(count)"
            } else {
                print(error?.localizedDescription)
            }
        }

        let followings = AVUser.followeeQuery((guestArray.last?.objectId)!)
        followings.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                header.followings.text = "\(count)"
            } else {
                print(error?.localizedDescription)
            }
        }

        // 单击posts label
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsTap(_:)))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        // 单击关注者label
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTap(_:)))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        // 单击关注label
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(followingsTap(_:)))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)

        return header
    }

    @objc func postsTap(_ recognizer: UITapGestureRecognizer) {
        if !self.picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            collectionView?.scrollToItem(at: index, at: UICollectionView.ScrollPosition.top, animated: true)
        }
    }

    @objc func followersTap(_ recognizer: UITapGestureRecognizer) {
        // 通过Identifier找到对应的ViewController
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
}
