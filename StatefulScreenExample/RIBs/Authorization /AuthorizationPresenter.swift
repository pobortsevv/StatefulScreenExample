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
			case .routedToCodeCheck: return Void()
			case .userInput, .smsCodeRequestError, .sendingSMSCodeRequest: return nil
			}
		}
		.map{true}
		.startWith(false)
		.asDriverIgnoringError()
		
		// TODO: Следует задать вопрос: Что это и зачем оно нада?
		// Пока по этому аспекту нет инфы мы будем использовать dataLoaded
		// вместо isTyping
		let initialLoadingIndicatorVisible = LoadingIndicatorEvent(state: state)
		
		let showError = state.map { state -> ErrorMessageViewModel? in
			switch state {
			case let .smsCodeRequestError(error, _):
				return ErrorMessageViewModel(title: error.localizedDescription, buttonTitle: "Повторить")
			case .sendingSMSCodeRequest, .userInput, .routedToCodeCheck:
				return nil
			}
		}
		.asSignal(onErrorJustReturn: nil)
		
		return AuthorizationPresenterOutput(viewModel: viewModel,
																				isContentViewVisible: isContentViewVisible,
																				initialLoadingIndicatorVisible: initialLoadingIndicatorVisible,
																				phoneNumber: input.refinedPhone.asDriverIgnoringError(),
																				showError: showError)
	}
}

extension AuthorizationPresenter {
	private enum Helper: Namespace {
		static func viewModel(_ state: Observable<AuthorizationInteractorState>) -> Driver<AuthorizationViewModel> {
			return state.compactMap { state -> AuthorizationViewModel? in
				switch state {
				case .routedToCodeCheck:
					return AuthorizationViewModel()
				case .smsCodeRequestError, .sendingSMSCodeRequest, .userInput:
					return nil
				}
			}
			.distinctUntilChanged()
			.asDriverIgnoringError()
		}
	}
}
