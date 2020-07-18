//
//  LoaderViewController.swift
//  PDF_Upload
//
//  Created by Shubham Vinod Kamdi on 18/07/20.
//  Copyright © 2020 Persausive Tech. All rights reserved.
//

import UIKit
import SwiftyGif

class LoaderViewController: UIViewController {

    @IBOutlet weak var loader: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            let gif = try UIImage(gifName: "progress.gif")
                   self.loader.setGifImage(gif, loopCount: -1)
        }catch{
            //THROWS ERROR
        }
       
        // Do any additional setup after loading the view.
        
    }
    

}
