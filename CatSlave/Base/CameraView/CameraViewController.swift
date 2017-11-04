//
//  CameraViewController.swift
//  CatSlave
//
//  Created by Richard on 18/10/17.
//  Copyright © 2017 crow. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import AVKit

class CameraViewController: UIViewController {

    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var videoModeLabel: UILabel!
    @IBOutlet weak var playVideoButton: MyButton!
    
    var firebaseRef: DatabaseReference?
    var firebaseStorage: StorageReference?
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var videoDownloadURL: String?
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var currentUserId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoModeLabel.isHidden = true
        playVideoButton.isHidden = true
        currentUserId = appdelegate.currentUserID!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        firebaseRef = Database.database().reference(withPath: "\(currentUserId!)/data")
        _ = firebaseRef!.observe(DataEventType.value, with: { (snapshot) in
            // Get download URL from snapshot
            let dictionary = snapshot.value as! [String: AnyObject]
            let cameraDictionary = dictionary["camera"] as! [String: AnyObject]
            let videoDictionary = dictionary["video"] as! [String: AnyObject]
            
            let imageDownloadURL = cameraDictionary["imageSource"] as! String
            self.videoDownloadURL = videoDictionary["videoSource"] as? String
            
            if self.appDelegate.cameraTakingModeIsPhoto{
                self.catImageView.isHidden = false
                self.videoModeLabel.isHidden = true
                self.playVideoButton.isHidden = true
                
//                // Create a storage reference from the URL
//                let storageRef = Storage.storage().reference(forURL: imageDownloadURL)
//                // Download the data, assuming a max size of 1MB (you can change this as necessary)
//                storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
//                    let pic = UIImage(data: data!)
//                    self.catImageView.image = pic!
//                }
                if let image_url = URL(string: imageDownloadURL){
                    do{
                        let data = try Data(contentsOf: image_url)
                        self.catImageView.image = UIImage(data: data)
                    }catch let err{
                        self.showFailMessage(view: self.view, message: "Error happened when loading image: \(err)")
                    }
                }
            }else{
                self.catImageView.isHidden = true
                self.videoModeLabel.isHidden = false
                self.playVideoButton.isHidden = false
            }
        })
    }
    
    //play video button clicked
    @IBAction func playVideo(_ sender: Any) {
        if videoDownloadURL != nil{
            playVideoUsingURLString(urlString: videoDownloadURL!)
        }
    }
    
    //play video using AVPlayer and url
    func playVideoUsingURLString(urlString: String){
        let videoURL = URL(string: urlString)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
