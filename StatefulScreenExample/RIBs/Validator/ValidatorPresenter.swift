//
//  ValidatorPresenter.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 23.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

final class ValidatorPresenter: ValidatorPresentable {
	private let phoneNumber: String
	init(phoneNumber: String) {
		self.phoneNumber = phoneNumber
	}
}

// MARK: - IOTransformer

extension ValidatorPresenter: IOTransformer {
	func transform(input: ValidatorInteractorOutput) -> ValidatorPresenterOutput {
		let state = input.state
		
		let showNumber = input.screenDataModel.map { screenDataModel -> String in
			return screenDataModel.phoneNumber
		}.asDriverIgnoringError()
		
		let isContentViewVisible = state.compactMap { state -> Void? in
			switch state {
			case .userInput: return Void()
			case .sendingCodeCheckRequest, .updatingProfile, .updatedProfile: return nil
			}
		}
		.map { true }
		.startWith(false)
		.asDriverIgnoringError()
		
		let initialLoadingIndicatorVisible = LoadingIndicatorEvent(state: state)
		
		let code = input.screenDataModel.map { screenDataModel -> String in
			return screenDataModel.codeTextField
		}
		.asDriverIgnoringError()
		
		let showNetworkError = state.map { state -> String? in
			switch state {
			case let .userInput(error):
				switch error {
				case .validationError:
					return nil
				case .networkError:
					return error?.localizedDescription
				case .none:
					return nil
				}
			case .sendingCodeCheckRequest, .updatingProfile, .updatedProfile:
				return nil
			}
		}.asSignalIgnoringError()
		
		let showValidationError = state.map { state -> String? in
			switch state {
			case let .userInput(error):
				switch error {
				case .validationError:
					return error?.localizedDescription
				case .networkError:
					return nil
				case .none:
					return nil
				}
			case .sendingCodeCheckRequest, .updatingProfile, .updatedProfile:
				return nil
			}
		}.asSignalIgnoringError()
		
		return ValidatorPresenterOutput(showNumber: showNumber, isContentViewVisible: isContentViewVisible, initialLoadingIndicatorVisible: initialLoadingIndicatorVisible, code: code, showNetworkError: showNetworkError, showValidationError: showValidationError)
	}
}

//extension ValidatorPresenter {
//	private enum Helper: Namespace {
//		static func
//	}
//}
