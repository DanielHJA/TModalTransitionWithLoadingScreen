//
//  ViewController.swift
//  TransitionLoadingTest
//
//  Created by Daniel Hjärtström on 2018-07-12.
//  Copyright © 2018 Daniel Hjärtström. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var fadeTransitionManager: FadeTransitionManager = {
        return FadeTransitionManager(type: .modal)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func fetchData(_ sender: UIButton) {
        let vc = ResultsViewController()
        vc.transitioningDelegate = fadeTransitionManager
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
        
        delay(time: 5.0) {
            self.fadeTransitionManager.comepleteTransition = true
        }
    }
    
    func delay(time: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            closure()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
