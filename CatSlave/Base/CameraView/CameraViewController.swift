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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoModeLabel.isHidden = true
        playVideoButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        firebaseRef = Database.database().reference(withPath: "UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data")
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
    
    func load_image(image_url_string:String)
    {
        let image_url = URL(string: image_url_string)!
        _ = URLSession.shared.dataTask(with: image_url){(data, response, error) in
            if error != nil{
                self.showFailMessage(view: self.view, message: "Error loading Image")
            }else{
                var documentsDirectory: String?
                var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                if paths.count > 0{
                    documentsDirectory = paths[0]
                    let savePath = documentsDirectory! + image_url_string
                    FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
                    DispatchQueue.main.async {
                        self.catImageView.image = UIImage(named: savePath)
                    }
                }
            }
            
        }
    }
    
    @IBAction func playVideo(_ sender: Any) {
        if videoDownloadURL != nil{
            playVideoUsingURLString(urlString: videoDownloadURL!)
        }
    }
    
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
