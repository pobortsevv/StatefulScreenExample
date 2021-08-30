//
//  ValidatorViewController.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 23.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa
import UIKit

final class ValidatorViewController: UIViewController, ValidatorViewControllable {
	@IBOutlet private weak var networkErrorLabel: UILabel!
	@IBOutlet private weak var phoneNumberLabel: UILabel!
	@IBOutlet private weak var codeTextField: UITextField!
	@IBOutlet private weak var codeErrorLabel: UILabel!
	
	// Provider view
	private let loadingIndicatorView = LoadingIndicatorView()
	
	// MARK: View Events
	
	private let viewOutput = ViewOutput()
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initailSetup()
	}
}

extension ValidatorViewController {
	private func initailSetup() {
		title = "Подтверждение кода"
		
		codeTextField.layer.cornerRadius = 12
		codeErrorLabel.text = ""
		
		view.addStretchedToBounds(subview: loadingIndicatorView)
		loadingIndicatorView.isVisible = false
	}
}

extension ValidatorViewController: BindableView {
	func getOutput() -> ValidatorViewOutput { viewOutput }
	
	func bindWith(_ input: ValidatorPresenterOutput) {
		disposeBag.insert {
			input.initialLoadingIndicatorVisible.drive(loadingIndicatorView.rx.isVisible,
																								 loadingIndicatorView.indicatorView.rx.isAnimating)
			
			input.code.drive(codeTextField.rx.text)
			input.showNumber.drive(phoneNumberLabel.rx.text)
			
			input.showNetworkError.emit(onNext: { [weak self] error in
				if let error = error {
					self?.networkErrorLabel.text = error
					self?.networkErrorLabel.textColor = .red
					self?.codeTextField.text = nil
				}
			})
			
			input.showValidationError.emit(onNext: { [weak self] error in
				if let error = error {
					self?.codeErrorLabel.text = error
					self?.codeErrorLabel.textColor = .red
					self?.codeTextField.text = nil
				}
			})
			
			codeTextField.rx.text.orEmpty.bind(to: viewOutput.$codeTextChange)
		}
	}
}

extension ValidatorViewController {
	private struct ViewOutput: ValidatorViewOutput {
		@PublishControlEvent var codeTextChange: ControlEvent<String>
	}
}

extension ValidatorViewController: RibStoryboardInstantiatable {}
