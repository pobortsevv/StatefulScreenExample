//
//  AuthorizationViewController.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 12.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift
import UIKit

final class AuthorizationViewController: UIViewController, AuthorizationViewControllable {
	
	@IBOutlet weak var phoneNumberTextField: UITextField!
	@IBOutlet weak var getSMSButton: UIButton!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		uiChanges()
	}
	
	// Настраиваем и дополняем ui
	func uiChanges() {
		getSMSButton.layer.cornerRadius = 12.0
		phoneNumberTextField.layer.cornerRadius = 12.0
	}
	
}

extension AuthorizationViewController: BindableView {
	func getOutput() -> AuthorizationViewOutput {
		return AuthorizationViewOutput(getSMSButton: getSMSButton.rx.tap,
																	 phoneNunberTextField: phoneNumberTextField.rx.controlEvent([.editingChanged]))
	}
	
	func bindWith(_ input: Empty) {}
}


// MARK: - RibStoryboardInstantiatable

extension AuthorizationViewController: RibStoryboardInstantiatable {}
