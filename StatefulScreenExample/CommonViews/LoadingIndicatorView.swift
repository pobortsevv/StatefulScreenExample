//
//  LoadingIndicatorView.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import UIKit
import Lottie

final class LoadingIndicatorView: UIView {
	// Create Animation object
	let animation = Animation.named("Watermelon")
	
//	// Load animation to AnimationView
	
//	animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
//
//	// Add animationView as subview
//	view.addSubview(animationView)
//
//	// Play the animation
//	animationView.play()
	
  let indicatorView = UIActivityIndicatorView()
	let animationView = AnimationView()
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    initialSetup()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
		animationView.frame = frame
    initialSetup()
  }
  
  private func initialSetup() {
    backgroundColor = UIColor.black.withAlphaComponent(0.15)
    
    indicatorView.translatesAutoresizingMaskIntoConstraints = false
		animationView.animation = animation
    addSubview(indicatorView)
		animationView.play()
    
    let constraints: [NSLayoutConstraint] = [
      indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
      indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
    ]
    
    NSLayoutConstraint.activate(constraints)
  }
}
