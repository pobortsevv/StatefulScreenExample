//
//  ValidatorProtocols.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 23.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

// MARK: - Builder

protocol ValidatorBuildable: Buildable {
		func build() -> ValidatorRouting
}

// MARK: - Router

protocol ValidatorInteractable: Interactable {
		var router: ValidatorRouting? { get set }
}

protocol ValidatorViewControllable: ViewControllable {}

// MARK: - Interactor

protocol ValidatorRouting: ViewableRouting {
		// TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ValidatorPresentable: Presentable {}

// MARK: States

public enum ValidatorInteractorState {
	case userInput
	case sendingCodeCheckRequest(code: String)
	case updateProfile
	case routedToMainScreen
}

extension ValidatorInteractorState: GeneralizableState {
	public var isLoadingState: Bool {
		guard case .sendingCodeCheckRequest = self else { return false }
		return true
	}
	
	public var isDataLoadedState: Bool {
		guard case .routedToMainScreen = self else { return false }
		return true
	}
	
	public var isLoadingErrorState: Bool {
		guard case .sendingCodeCheckRequest = self else { return false }
		return true
	}
}

extension ValidatorInteractorState: LoadingIndicatableState {
	public var shouldLoadingIndicatorBeVisible: Bool {
		guard case .sendingCodeCheckRequest = self else { return false }
		return true
	}
}

// MARK: Outputs

// TODO: Заполнить аутпуты
struct ValidatorInteractorOutput {
	let state: Observable<ValidatorInteractorState>
	let screenDataModel: Observable<ValidatorScreenDataModel>
}

struct ValidatorPresenterOutput {
//	let showCode: Driver<String>
//	let isContentViewVisible: Driver<Bool>
//
//	let initialLoadingIndicatorVisible: Driver<Bool>
//
//	let phoneNumber: Driver<String>
//	let	isButtonEnable: Driver<Bool>
//	let showError: Signal<ErrorMessageViewModel?>
}

protocol ValidatorViewOutput {
//	var getSMSButtonTap: ControlEvent<Void> { get }
//	var phoneNumberTextChange: ControlEvent<String> { get }
//	var retryButtonTap: ControlEvent<Void> { get }
}

// MARK: ScreenDataModel

struct ValidatorScreenDataModel {
	var codeTextField: String
}

extension ValidatorScreenDataModel {
	init() {
		codeTextField = ""
	}
}
