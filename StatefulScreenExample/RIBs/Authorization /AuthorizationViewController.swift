//
//  AuthorizationViewController.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 12.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa
import UIKit

final class AuthorizationViewController: UIViewController, AuthorizationViewControllable {
	@IBOutlet private weak var phoneNumberTextField: UITextField!
	@IBOutlet private weak var getSMSButton: UIButton!
	
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
	
extension AuthorizationViewController {
	private func initialSetup() {
		title = "Авторизация"
		getSMSButton.layer.cornerRadius = 12.0
		getSMSButton.isEnabled = false
		
		phoneNumberTextField.layer.cornerRadius = 12.0
		
		tapGestureInitialSetup()
	}
	
	private func tapGestureInitialSetup() {
		do {
			let tapGesture = UITapGestureRecognizer()
			getSMSButton.addGestureRecognizer(tapGesture)
			tapGesture.rx.event.mapAsVoid().bind(to: viewOutput.$getSMSButtonTap).disposed(by: disposeBag)
		}
	}
}


extension AuthorizationViewController: BindableView {
	func getOutput() -> AuthorizationViewOutput {
		//let phoneNumberTextField =
		return viewOutput
	}
	
	func bindWith(_ input: AuthorizationPresenterOutput) {
		disposeBag.insert {
			input.initialLoadingIndicatorVisible.drive(loadingIndicatorView.rx.isVisible)
			
			input.initialLoadingIndicatorVisible.drive(loadingIndicatorView.indicatorView.rx.isAnimating)
			
			phoneNumberTextField.rx.text.orEmpty.bind(to: viewOutput.$phoneNumberTextChange)
			
			input.phoneNumber.drive(phoneNumberTextField.rx.text)
		}
		
		input.showError.emit(onNext: { [unowned self] maybeViewModel in
			self.errorMessageView.isVisible = (maybeViewModel != nil)
			
			if let viewModel = maybeViewModel {
				self.errorMessageView.resetToEmptyState()
				
				self.errorMessageView.setTitle(viewModel.title, buttonTitle: viewModel.buttonTitle, action: {
					self.viewOutput.$retryButtonTap.accept(Void())
				})
			}
		}).disposed(by: disposeBag)
	}
}


// MARK: - RibStoryboardInstantiatable

extension AuthorizationViewController: RibStoryboardInstantiatable {}

// MARK: - View Output

extension AuthorizationViewController {
	private struct ViewOutput: AuthorizationViewOutput {
		@PublishControlEvent var getSMSButtonTap: ControlEvent<Void>
		@PublishControlEvent var phoneNumberTextChange: ControlEvent<String>
		@PublishControlEvent var retryButtonTap: ControlEvent<Void>
	}
}
