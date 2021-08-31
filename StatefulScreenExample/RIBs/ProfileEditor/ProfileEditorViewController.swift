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
	// сделать аутлеты приватными
	@IBOutlet weak var nameTextField: CustomTextField!
	@IBOutlet weak var secondNameTextField: CustomTextField!
	@IBOutlet weak var phoneNumberTextField: CustomTextField!
	@IBOutlet weak var emailTextField: CustomTextField!
	
	@IBOutlet weak var emailValidationErrorLabel: UILabel!
	@IBOutlet weak var saveUpdateButton: UIButton!
	
	// удалить!
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

		emailValidationErrorLabel.text =  "Введен неверный email"
		phoneNumberTextField.isEnabled = false
		phoneNumberTextField.textColor = .gray
		phoneNumberTextField.layer.borderColor = UIColor.lightGray.cgColor
		phoneNumberTextField.layer.borderWidth = 1.0
		tapGestureInitialSetup()
	}
	
	// переименовать
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
	
	@objc private func doneButtonTapped() {
		view.endEditing(true)
	}
}

extension ProfileEditorViewController: BindableView {
	func getOutput() -> ProfileEditorViewOutput { viewOutput }
	
	func bindWith(_ input: ProfileEditorPresenterOutput) {
		disposeBag.insert {
			input.initialLoadingIndicatorVisible.drive(loadingIndicatorView.rx.isVisible,
																								 loadingIndicatorView.indicatorView.rx.isAnimating)
			input.firstName.drive(nameTextField.rx.text)
			input.lastName.drive(secondNameTextField.rx.text)
			input.phone.drive(phoneNumberTextField.rx.text)
			input.email.drive(emailTextField.rx.text)
			
			input.profileSuccessfullyEdited.emit(onNext: { _ in self.presentProfileSuccessUpdateAlert() } )
			
			input.isEmailValid.emit(onNext: { [weak self] isValid in
				guard let self = self else { return }
				self.emailValidationErrorLabel.isVisible = isValid ? false : true
				self.emailTextField.textColor = isValid ? .black : .red
				self.emailValidationErrorLabel.textColor = isValid ? .black : .red
				self.emailTextField.layer.borderColor = isValid ? nil : UIColor.red.cgColor
				self.emailTextField.layer.borderWidth = isValid ? 0 : 1
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
			nameTextField.rx.text.orEmpty.bind(to: viewOutput.$firstNameTextChange)
			secondNameTextField.rx.text.orEmpty.bind(to: viewOutput.$lastNameTextChange)
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
		@PublishControlEvent var firstNameTextChange: ControlEvent<String>
		@PublishControlEvent var lastNameTextChange: ControlEvent<String>
		@PublishControlEvent var emailTextChange: ControlEvent<String>
		@PublishControlEvent var retryButtonTap: ControlEvent<Void>
		@PublishControlEvent var alertButtonTap: ControlEvent<Void>
	}
}

// MARK: - Help Method

extension ProfileEditorViewController {
	private func presentProfileSuccessUpdateAlert() {
		self.profileSuccessfullyUpdated.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { [weak self] action in
			self?.viewOutput.$alertButtonTap.accept(Void())
		}))
		self.present(self.profileSuccessfullyUpdated, animated: true, completion: nil)
	}
}
