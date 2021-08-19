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
	@IBOutlet private weak var phoneNumberTextField: UITextField!
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
		
		getSMSButton.layer.cornerRadius = 12.0
		
		phoneNumberTextField.layer.cornerRadius = 12.0
		phoneNumberTextField.rx.text.subscribe(onNext: { _ in
			if let text = self.phoneNumberTextField.text {
				self.phoneNumberTextField.text = String(text.prefix(10))
			}
			self.getSMSButton.isHighlighted = self.phoneNumberTextField.text?.count != 10
			self.getSMSButton.isEnabled = self.phoneNumberTextField.text?.count == 10
			self.getSMSButton.alpha = self.getSMSButton.isEnabled ? 1 : 0.3
		}).disposed(by: disposeBag)
		
		view.addStretchedToBounds(subview: errorMessageView)
		view.addStretchedToBounds(subview: loadingIndicatorView)
		errorMessageView.isVisible = false
		
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
			
			input.showCode.drive(onNext: { [unowned self] smsCode in
				sendNotification(code: smsCode)
				UIPasteboard.general.string = smsCode
			})
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

// MARK: - Notifications Methods

extension AuthorizationViewController: UNUserNotificationCenterDelegate {
	
	/// Получаю уведомление, когда приложение открыто
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
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
