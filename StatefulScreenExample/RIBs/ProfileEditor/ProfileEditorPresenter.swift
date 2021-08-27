//
//  ProfileEditorPresenter.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 25.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

final class ProfileEditorPresenter: ProfileEditorPresentable {}

// MARK: - IOTransformer

extension ProfileEditorPresenter: IOTransformer {
	func transform(input: ProfileEditorInteractorOutput) -> ProfileEditorPresenterOutput {
		let state = input.state
		
		let isContentViewVisible = state.compactMap { state -> Void? in
			switch state {
			case .routedToProfile: return Void()
			case .userInput, .updateProfileRequestError, .updatingProfile: return nil
			}
		}
		.map { true }
		.startWith(false)
		.asDriverIgnoringError()
		
		let initialLoadingIndicatorVisible = LoadingIndicatorEvent(state: state)
		
		let userName = input.screenDataModel.map { screenDataModel in
			return screenDataModel.nameTextField
		}
		.asDriverIgnoringError()
		
		let secondName = input.screenDataModel.map { screenDataModel in
			return screenDataModel.secondNameTextField
		}
		.asDriverIgnoringError()
		
		let phone = input.screenDataModel.map { screenDataModel in
			return screenDataModel.phoneNumberTextField
		}
		.asDriverIgnoringError()
		
		let email = input.screenDataModel.map { screenDataModel in
			return screenDataModel.emailTextField
		}
		.asDriverIgnoringError()
		
		let isEmailValid = input.screenDataModel.map { screenDataModel in
			return screenDataModel.isEmailValid
		}
		.asSignalIgnoringError()
		
		let showError = state.map { state -> ErrorMessageViewModel? in
			switch state {
			case let .updateProfileRequestError(error, _):
				return ErrorMessageViewModel(title: error.localizedDescription, buttonTitle: "Повторить")
			case .userInput, .routedToProfile, .updatingProfile:
				return nil
			}
		}
		.asSignalIgnoringError()
		
		return ProfileEditorPresenterOutput(isContentViewVisible: isContentViewVisible,
																				initialLoadingIndicatorVisible: initialLoadingIndicatorVisible,
																				userName: userName,
																				userSecondName: secondName,
																				email: email,
																				phone: phone,
																				isEmailValid: isEmailValid,
																				showError: showError)
	}
}
