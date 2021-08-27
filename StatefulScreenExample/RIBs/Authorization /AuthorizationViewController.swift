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
import NotificationCenter

final class AuthorizationViewController: UIViewController, AuthorizationViewControllable {
	@IBOutlet private weak var phoneNumberTextField: FixedTextField!
	@IBOutlet private weak var getSMSButton: UIButton!
	
	// Notification
	private let notificationCenter = UNUserNotificationCenter.current()
	
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
		notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
			guard granted else { return }
		}
		notificationCenter.delegate = self
		
		getSMSButton.layer.cornerRadius = 12
		phoneNumberTextField.layer.cornerRadius = 12
		
		view.addStretchedToBounds(subview: errorMessageView)
		view.addStretchedToBounds(subview: loadingIndicatorView)
		errorMessageView.isVisible = false
		
		tapGestureInitialSetup()
	}
	
	private func tapGestureInitialSetup() {
		let toolbar = UIToolbar()
		
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(doneButtonTapped))
		
		toolbar.setItems([flexSpace, doneButton], animated: true)
		toolbar.sizeToFit()
		
		phoneNumberTextField.inputAccessoryView = toolbar
	}
}

extension AuthorizationViewController: BindableView {
	func getOutput() -> AuthorizationViewOutput { viewOutput }
	
	func bindWith(_ input: AuthorizationPresenterOutput) {
		disposeBag.insert {
			input.initialLoadingIndicatorVisible.drive(loadingIndicatorView.rx.isVisible,
																								 loadingIndicatorView.indicatorView.rx.isAnimating)
			
			input.phoneNumber.drive(phoneNumberTextField.rx.text)
			
			input.isButtonEnable.do(onNext: { [weak self] isEnabled in
				switch isEnabled {
				case true:
					self?.getSMSButton?.alpha = 1
					self?.view.endEditing(true)
				case false:
					self?.getSMSButton?.alpha = 0.3
				}
			}).drive(getSMSButton.rx.isEnabled)
			
			input.showCode.drive(onNext: { [weak self] smsCode in
				self?.sendNotification(code: smsCode)
				UIPasteboard.general.string = smsCode
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
			
			getSMSButton.rx.tap.bind(to: viewOutput.$getSMSButtonTap)
			
			phoneNumberTextField.rx.text.orEmpty.bind(to: viewOutput.$phoneNumberTextChange)
		}
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

// MARK: - Notifications Methods

extension AuthorizationViewController: UNUserNotificationCenterDelegate {
	/// Получаю уведомление, когда приложение открыто
	func userNotificationCenter(_ center: UNUserNotificationCenter,
															willPresent notification: UNNotification,
															withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert, .sound])
	}
	
	/// Функция выполняется, когда мы нажимаем на уведомление
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		if let code = UIPasteboard.general.string {
			print(code)
		}
	}
	
	private func sendNotification(code: String) {
		let content = UNMutableNotificationContent()
		content.title = "Your sms code"
		content.body = code
		content.sound = .default
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
		
		let request = UNNotificationRequest(identifier: "sms code", content: content, trigger: trigger)
		
		notificationCenter.add(request)
	}
}

// MARK: - Help Method

extension AuthorizationViewController {
	@objc private func doneButtonTapped() {
		view.endEditing(true)
	}
}
