//
//  ViewController.swift
//  AVPlayerViewController-Subtitles
//
//  Created by mhergon on 23/12/15.
//  Copyright © 2015 mhergon. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

class ViewController: UIViewController {
    
    var asset: AVAsset!
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var downloadTask: AVAssetDownloadTask!
    
    var accesslog: AVPlayerItemAccessLog!
    
    var playerViewController: AVPlayerViewController!
    
    // Key-value observing context
    private var playerItemContext = 0
    
    let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Actions
    @IBAction func showVideo(_ sender: UIButton) {
  
        //self.showOfflineVideo()
        self.showOnlineVideo()
 
    }
    
    func showOnlineVideo() {
        
        let urlString = "http://www.freiwasser.blog/spielwiese/peter/Basketballplatz_small.m4v"
        guard let url = URL(string: urlString) else {
            return
        }
        
        asset = AVAsset(url: url)
        
        
        // Create a new AVPlayerItem with the asset and an
        // array of asset keys to be automatically loaded
        playerItem = AVPlayerItem(asset: asset,
                                  automaticallyLoadedAssetKeys: requiredAssetKeys)
        
        // Register as an observer of the player item's status property
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.status),
                               options: [.old, .new],
                               context: &playerItemContext)
        
        // Associate the player item with the player
        player = AVPlayer(playerItem: playerItem)
        
    }
    
    func showOfflineVideo() {
        // Video file
        let videoFile = Bundle.main.path(forResource: "trailer_720p", ofType: "mov")
        
        // Subtitle file
        let subtitleFile = Bundle.main.path(forResource: "trailer_720p", ofType: "srt")
        let subtitleURL = URL(fileURLWithPath: subtitleFile!)
        
        // Movie player
        let moviePlayer = AVPlayerViewController()
        moviePlayer.player = AVPlayer(url: URL(fileURLWithPath: videoFile!))
        present(moviePlayer, animated: true, completion: nil)
        
        // Add subtitles
        //moviePlayer.addSubtitles().open(file: subtitleURL)
        moviePlayer.addSubtitles().open(file: subtitleURL, encoding: .utf8)
        
        // Change text properties
        moviePlayer.subtitleLabel?.textColor = .white
        moviePlayer.subtitleLabel?.font = UIFont(name: "Helvetica-Bold", size: 22)//UIFont.boldSystemFont(ofSize: 60)
        
        // Play
        moviePlayer.player?.play()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // Switch over status value
            switch status {
            case .readyToPlay:
                //playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
                if !player.isPlaying {
                    DispatchQueue.main.async {
                        self.play()
                    }
                    playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
                }
            case .failed:
                print("failed")
                print(playerItem.error?.localizedDescription ?? "unknown error")
            case .unknown:
                print("unknown")
            }
        }
    }
    
    func play() {
        
        // Movie player
        let moviePlayer = AVPlayerViewController()
        moviePlayer.player = player
        present(moviePlayer, animated: true, completion: nil)
        
        // Add subtitles
        
        let urlString = "http://www.freiwasser.blog/spielwiese/peter/Basketballplatz.srt"
        guard let subtitleURL = URL(string: urlString) else {
            return
        }
        
        moviePlayer.addSubtitles().open(file: subtitleURL, encoding: .utf8)
        
        // Change text properties
        moviePlayer.subtitleLabel?.textColor = .white
        moviePlayer.subtitleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        // Play
        moviePlayer.player?.play()
        
    }
    
    deinit {
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    }
    
    func subtitleParser() {
        
        // Subtitle file
        let subtitleFile = Bundle.main.path(forResource: "trailer_720p", ofType: "srt")
        let subtitleURL = URL(fileURLWithPath: subtitleFile!)
        
        // Subtitle parser
        let parser = Subtitles(file: subtitleURL, encoding: .utf8)
        
        // Do something with result
        _ = parser.searchSubtitles(at: 2.0) // Search subtitle at 2.0 seconds
        
    }
    
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

