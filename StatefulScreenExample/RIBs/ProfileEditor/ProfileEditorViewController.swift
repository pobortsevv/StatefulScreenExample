//
//  ProfileEditorViewController.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 25.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa
import UIKit

final class ProfileEditorViewController: UIViewController, ProfileEditorPresentable, ProfileEditorViewControllable {
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var secondNameTextField: UITextField!
	@IBOutlet weak var phoneNumberTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	
	@IBOutlet weak var saveUpdateButton: UIButton!
	
	// Provider views
	private let loadingIndicatorView = LoadingIndicatorView()
	private let errorMessageView = ErrorMessageView()
	
	// MARK: View Events
	
	private let viewOutput = ViewOutput()
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initialSetup()
	}
}

extension ProfileEditorViewController {
	private func initialSetup() {
		title = "Редактировать"
		
		nameTextField.layer.cornerRadius = 12
		secondNameTextField.layer.cornerRadius = 12
		phoneNumberTextField.layer.cornerRadius = 12
		emailTextField.layer.cornerRadius = 12
		
		view.addStretchedToBounds(subview: errorMessageView)
		view.addStretchedToBounds(subview: loadingIndicatorView)
		errorMessageView.isVisible = false
		
		phoneNumberTextField.isEnabled = false
	}
}

extension ProfileEditorViewController: BindableView {
	func getOutput() -> ProfileEditorViewOutput { viewOutput }
	
	func bindWith(_ input: ProfileEditorPresenterOutput) {
		//
	}
}

// MARK: - RibStoryboardInstantiatable

extension ProfileEditorViewController: RibStoryboardInstantiatable {}

// MARK: - ViewOutput

extension ProfileEditorViewController {
	private struct ViewOutput: ProfileEditorViewOutput {
//		@PublishControlEvent var getSMSButtonTap: ControlEvent<Void>
//		@PublishControlEvent var phoneNumberTextChange: ControlEvent<String>
		@PublishControlEvent var retryButtonTap: ControlEvent<Void>
	}
}
