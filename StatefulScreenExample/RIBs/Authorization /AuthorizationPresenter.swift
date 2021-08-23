//
//  AuthorizationPresenter.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 15.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

final class AuthorizationPresenter: AuthorizationPresentable {}

// MARK: - IOTransformer

extension AuthorizationPresenter: IOTransformer {
	func transform(input: AuthorizationInteractorOutput) -> AuthorizationPresenterOutput {
		let state = input.state
		
		let viewModel = Helper.viewModel(state)
		
		let isContentViewVisible = state.compactMap { state -> Void? in
			switch state {
			case .routedToCodeCheck: return Void()//routeToValidator()
			case .userInput, .smsCodeRequestError, .sendingSMSCodeRequest: return nil
			}
		}
		.map { true }
		.startWith(false)
		.asDriverIgnoringError()
		
		let initialLoadingIndicatorVisible = LoadingIndicatorEvent(state: state)
		
		let showError = state.map { state -> ErrorMessageViewModel? in
			switch state {
			case let .smsCodeRequestError(error, _):
				return ErrorMessageViewModel(title: error.localizedDescription, buttonTitle: "Повторить")
			case .sendingSMSCodeRequest, .userInput, .routedToCodeCheck:
				return nil
			}
		}
		.asSignalIgnoringError()
		
		let phoneNumber = input.screenDataModel.map { screenDataModel -> String in
			return formatPhone(number: screenDataModel.phoneNumberTextField)
		}
		.asDriverIgnoringError()
		
		let buttonAvailability = input.screenDataModel.map { screenDataModel -> Bool in
			return screenDataModel.phoneNumberTextField.count == 11
		}
		.asDriverIgnoringError()
		
		return AuthorizationPresenterOutput(showCode: viewModel,
																				isContentViewVisible: isContentViewVisible,
																				initialLoadingIndicatorVisible: initialLoadingIndicatorVisible,
																				phoneNumber: phoneNumber,
																				isButtonEnable: buttonAvailability,
																				showError: showError)
	}
}

extension AuthorizationPresenter {
	private enum Helper: Namespace {
		static func viewModel(_ state: Observable<AuthorizationInteractorState>) -> Driver<String> {
			return state.compactMap { state -> String? in
				switch state {
				case let .routedToCodeCheck(code):
					return code
				case .smsCodeRequestError, .sendingSMSCodeRequest, .userInput:
					return nil
				}
			}
			.distinctUntilChanged()
			.asDriverIgnoringError()
		}
	}
}
