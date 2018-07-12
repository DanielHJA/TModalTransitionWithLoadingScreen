//
//  FadeTransitionManager.swift
//  Transitionbasic
//
//  Created by Daniel Hjärtström on 2018-06-12.
//  Copyright © 2018 Daniel Hjärtström. All rights reserved.
//

import UIKit

enum NavigationType {
    case modal, navigation
}

protocol ExecuteWorkItemDelegate: class {
    func executeWorkItem()
}

class FadeTransitionManager: NSObject, UIViewControllerTransitioningDelegate {
    
    private let type: NavigationType
    weak var delegate: ExecuteWorkItemDelegate?
    
    var comepleteTransition = false {
        didSet {
            delegate?.executeWorkItem()
        }
    }
    
    let presentationAnimation = FadeTransitionAnimation(status: .push, type: .modal)

    
    init(type: NavigationType) {
        self.type = type
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        delegate = presentationAnimation
        return presentationAnimation
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let temp = FadeTransitionAnimation(status: .pop, type: type)
        return temp
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationControl(presentedViewController: presented, presenting: presenting)
    }
    
}

class PresentationControl: UIPresentationController {
    
    let dimView: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return temp
    }()
    
    lazy var indicator: UIActivityIndicatorView = {
        let temp = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        temp.frame = containerView!.frame
        temp.startAnimating()
        return temp
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override func presentationTransitionWillBegin() {
            dimView.frame = self.containerView!.bounds
            dimView.alpha = 1.0
            containerView?.insertSubview(dimView, at: 0)
            dimView.addSubview(indicator)
            
            let transitionCoordinator = presentingViewController.transitionCoordinator
            transitionCoordinator?.animate(alongsideTransition: { [weak self] (_) -> () in
            self?.dimView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentedViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { [weak self] (_) -> () in
            self?.dimView.alpha = 0.0
            self?.indicator.removeFromSuperview()
        })
        
    }
}


class FadeTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning, ExecuteWorkItemDelegate {

    private let status: UINavigationControllerOperation
    private let type: NavigationType
    private var workItem: DispatchWorkItem!
    
    init(status: UINavigationControllerOperation, type: NavigationType) {
        self.status = status
        self.type = type
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        
        guard let from = transitionContext.viewController(forKey: .from) else { return }
        guard let to = transitionContext.viewController(forKey: .to) else { return }
        
        guard let fromView = from.view else { return }
        guard let toView = to.view else { return }
        
        let duration = self.transitionDuration(using: transitionContext)
        
        if status == .push {
            container.addSubview(toView)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

            toView.alpha = 0
            
            workItem = DispatchWorkItem(block: {
                UIView.animate(withDuration: duration, animations: {
                    toView.alpha = 1.0
                }, completion: { (completion) in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            })
        }
        
        if status == .pop {
            
            if type == .navigation {
                container.insertSubview(toView, belowSubview: fromView)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

            } else {
                UIView.animate(withDuration: duration, animations: {
                    fromView.alpha = 0
                }, completion: { (completion) in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            }
        }
    }

    func executeWorkItem() {
        workItem.perform()
    }
}
