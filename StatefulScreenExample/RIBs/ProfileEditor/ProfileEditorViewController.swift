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
	@IBOutlet weak var nameTextField: FixedTextField!
	@IBOutlet weak var secondNameTextField: FixedTextField!
	@IBOutlet weak var phoneNumberTextField: FixedTextField!
	@IBOutlet weak var emailTextField: FixedTextField!
	
	@IBOutlet weak var emailValidationErrorLabel: UILabel!
	@IBOutlet weak var saveUpdateButton: UIButton!
	
	private let profileSuccessfullyUpdated = UIAlertController(title: "Профиль успешно обновлён",
																														 message: nil,
																														 preferredStyle: UIAlertController.Style.alert)
	
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
		saveUpdateButton.layer.cornerRadius = 12
		
		view.addStretchedToBounds(subview: errorMessageView)
		view.addStretchedToBounds(subview: loadingIndicatorView)
		errorMessageView.isVisible = false
		loadingIndicatorView.isVisible = false

		phoneNumberTextField.isEnabled = false
		phoneNumberTextField.textColor = .gray
		phoneNumberTextField.layer.borderColor = UIColor.lightGray.cgColor
		phoneNumberTextField.layer.borderWidth = 1.0
		tapGestureInitialSetup()
	}
	
	private func tapGestureInitialSetup() {
		let toolbar = UIToolbar()
		
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(doneButtonTapped))
		
		doneButton.tintColor = .green
		toolbar.setItems([flexSpace, doneButton], animated: true)
		toolbar.sizeToFit()
		
		nameTextField.inputAccessoryView = toolbar
		secondNameTextField.inputAccessoryView = toolbar
		emailTextField.inputAccessoryView = toolbar
	}
}

extension ProfileEditorViewController: BindableView {
	func getOutput() -> ProfileEditorViewOutput { viewOutput }
	
	func bindWith(_ input: ProfileEditorPresenterOutput) {

		disposeBag.insert {
			input.initialLoadingIndicatorVisible.drive(loadingIndicatorView.rx.isVisible,
																								 loadingIndicatorView.indicatorView.rx.isAnimating)
			input.userName.drive(nameTextField.rx.text)
			input.userSecondName.drive(secondNameTextField.rx.text)
			input.phone.drive(phoneNumberTextField.rx.text)
			input.email.drive(emailTextField.rx.text)
			
			input.profileSuccessfullyEdited.emit(onNext: { [weak self] _ in
				self?.profileSuccessfullyUpdated.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
					self?.viewOutput.$alertButtonTap.accept(Void())
				}))
				DispatchQueue.main.async(execute: {
					self?.present(self!.profileSuccessfullyUpdated, animated: true, completion: nil)
				})
			})
			
			input.isEmailValid.emit(onNext: { [weak self] isValid in
				if isValid {
					self?.emailValidationErrorLabel.isVisible = false
					self?.emailTextField.textColor = .black
					self?.emailTextField.layer.borderColor = .none
					self?.emailTextField.layer.borderWidth = 0.0
				} else {
					self?.emailValidationErrorLabel.textColor = .red
					self?.emailValidationErrorLabel.text = "Введен неверный email"
					self?.emailValidationErrorLabel.isVisible = true
					self?.emailTextField.textColor = .red
					self?.emailTextField.layer.borderColor = UIColor.red.cgColor
					self?.emailTextField.layer.borderWidth = 1.0
				}
				
			})
			
			input.showError.emit(onNext: { [unowned self] maybeViewModel in
				self.errorMessageView.isVisible = (maybeViewModel != nil)
		
				if let viewModel = maybeViewModel {
					self.errorMessageView.resetToEmptyState()

					self.errorMessageView.setTitle(viewModel.title, buttonTitle: viewModel.buttonTitle, action: {
						self.viewOutput.$retryButtonTap.accept(Void())
					})
				}
			})
			nameTextField.rx.text.orEmpty.bind(to: viewOutput.$nameTextChange)
			secondNameTextField.rx.text.orEmpty.bind(to: viewOutput.$secondNameTextChange)
			emailTextField.rx.text.orEmpty.bind(to: viewOutput.$emailTextChange)
			saveUpdateButton.rx.tap.bind(to: viewOutput.$updateProfileButtonTap)
		}
	}
}

// MARK: - RibStoryboardInstantiatable

extension ProfileEditorViewController: RibStoryboardInstantiatable {}

// MARK: - ViewOutput

extension ProfileEditorViewController {
	private struct ViewOutput: ProfileEditorViewOutput {
		@PublishControlEvent var updateProfileButtonTap: ControlEvent<Void>
		@PublishControlEvent var nameTextChange: ControlEvent<String>
		@PublishControlEvent var secondNameTextChange: ControlEvent<String>
		@PublishControlEvent var emailTextChange: ControlEvent<String>
		@PublishControlEvent var retryButtonTap: ControlEvent<Void>
		@PublishControlEvent var alertButtonTap: ControlEvent<Void>
	}
}

// MARK: - Help Method

extension ProfileEditorViewController {
	@objc private func doneButtonTapped() {
		view.endEditing(true)
	}
}
