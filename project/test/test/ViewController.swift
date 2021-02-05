//
//  ViewController.swift
//  test
//
//  Created by matiastang on 2021/1/15.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    var ageLabe:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        
    }
    
    deinit {
        
    }
}

extension ViewController {
    
    private func setUI() {
        
        ageLabe = UILabel.init(frame: .init(x: 0, y: 0, width: 180, height: 50))
        ageLabe?.text = "10"
//        ageLabe.co
        
        
//        edgesForExtendedLayout
        nameLabel.text = "name"
        
        if #available(ios 10, *) {
            
        } else {
            
        }
    }
    
}

