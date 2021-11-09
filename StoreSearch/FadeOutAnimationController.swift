//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by user206341 on 11/9/21.
//

import Foundation
import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           animations: {
                fromView.alpha = 0
            },
                           completion: {
                finished in
                transitionContext.completeTransition(finished)
            })
        }
    }
    
    
}
