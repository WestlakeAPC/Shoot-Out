//
//  InitialViewController.swift
//  Shoot Out
//
//  Created by Joseph Jin on 8/6/17.
//  Copyright © 2017 Westlake APC. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    let backgroundArray = [#imageLiteral(resourceName: "initialBackground"), #imageLiteral(resourceName: "initialBackground-2"), #imageLiteral(resourceName: "initialBackground-3"), #imageLiteral(resourceName: "initialBackground-4"), #imageLiteral(resourceName: "initialBackground-5"), #imageLiteral(resourceName: "initialBackground-6"), #imageLiteral(resourceName: "initialBackground-7")]

    @IBOutlet var backgroundView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        backgroundView.image = backgroundArray[Int(arc4random_uniform(UInt32(backgroundArray.count)))]

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
