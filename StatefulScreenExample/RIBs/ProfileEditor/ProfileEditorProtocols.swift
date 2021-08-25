//
//  ProfileEditorProtocols.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 25.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

// MARK: - Builder

protocol ProfileEditorBuildable: Buildable {
		func build() -> ProfileEditorRouting
}
 
// MARK: - Router

protocol ProfileEditorInteractable: Interactable {
		var router: ProfileEditorRouting? { get set }
}

protocol ProfileEditorViewControllable: ViewControllable {}

// MARK: - Interactor

protocol ProfileEditorRouting: ViewableRouting {
		// TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ProfileEditorPresentable: Presentable {}


// MARK: States

public enum ProfileEditorInteractorState {
	case userInput
//	case sendingSMSCodeRequest(phoneNumber: String)
//	case smsCodeRequestError(error: Error, phoneNumber: String)
//	/// Перешли на экран ввода и проверки смс кода (терминальное состояние)
//	case routedToCodeCheck(code: String)
}

//extension AuthorizationInteractorState: GeneralizableState {
//	public var isLoadingState: Bool {
//		guard case .sendingSMSCodeRequest = self else { return false }
//		return true
//	}
//
//	public var isDataLoadedState: Bool {
//		guard case .routedToCodeCheck = self else { return false }
//		return true
//	}
//
//	public var isLoadingErrorState: Bool {
//		guard case .smsCodeRequestError = self else { return false }
//		return true
//	}
//}
//
//extension AuthorizationInteractorState: LoadingIndicatableState {
//	public var shouldLoadingIndicatorBeVisible: Bool {
//		guard case .sendingSMSCodeRequest = self else { return false }
//		return true
//	}
//}

// MARK: Outputs

struct ProfileEditorInteractorOutput {
	let state: Observable<ProfileEditorInteractorState>
	let screenDataModel: Observable<ProfileEditorScreenDataModel>
}

struct ProfileEditorPresenterOutput {
//	let showCode: Driver<String>
//	let isContentViewVisible: Driver<Bool>
//
//	let initialLoadingIndicatorVisible: Driver<Bool>
//
//	let phoneNumber: Driver<String>
//	let	isButtonEnable: Driver<Bool>
//	let showError: Signal<ErrorMessageViewModel?>
}

protocol ProfileEditorViewOutput {
//	var getSMSButtonTap: ControlEvent<Void> { get }
//	var phoneNumberTextChange: ControlEvent<String> { get }
//	var retryButtonTap: ControlEvent<Void> { get }
}

// MARK: ScreenDataModel

struct ProfileEditorScreenDataModel {
//	var phoneNumberTextField: String
}

//extension ProfileEditorScreenDataModel {
//	init() {
//		phoneNumberTextField = ""
//	}
//}

