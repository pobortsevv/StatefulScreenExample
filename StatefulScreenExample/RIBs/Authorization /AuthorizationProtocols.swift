//
//  AuthorizationProtocols.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 12.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa

// MARK: - Builder

protocol AuthorizationBuildable: Buildable {
		func build() -> AuthorizationRouting
}

// MARK: - Router

protocol AuthorizationInteractable: Interactable {
		var router: AuthorizationRouting? { get set }
}

protocol AuthorizationViewControllable: ViewControllable {}

// MARK: - Interactor

protocol AuthorizationRouting: ViewableRouting {
		// TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
	// routesToNextScreens!!!
}

protocol AuthorizationPresentable: Presentable {}

// MARK: Outputs

/// В данном перечислении находятся сами состояния.
/// Необходимо объявить их здесь, реализовать переходы
/// в интеракторе
public enum AuthorizationInteractorState {
	case userInput
	case sendingSMSCodeRequest(phoneNumber: String)
//	case gotSMSCode(smsCode: String)
	case smsCodeRequestError(error: Error, phoneNumber: String)
	/// Перешли на экран ввода и проверки смс кода (терминальное состояние)
	case routedToCodeCheck
}

struct AuthorizationInteractorOutput {
	let state: Observable<AuthorizationInteractorState>
	let refinedPhone: Observable<String>
}

/// Здесь описаны состояния загрузки экрана, при входе на него
struct AuthorizationPresenterOutput {
	let viewModel: Driver<AuthorizationViewModel>
	let isContentViewVisible: Driver<Bool>
	
	let initialLoadingIndicatorVisible: Driver<Bool>
	
	let phoneNumber: Driver<String>
	let showError: Signal<ErrorMessageViewModel?>
}

protocol AuthorizationViewOutput {
	var getSMSButtonTap: ControlEvent<Void> {get}
	var phoneNumberTextChange: ControlEvent<String> {get}
	var retryButtonTap: ControlEvent<Void> {get}
}

struct AuthorizationViewModel: Equatable {
	//let phone: String?
}

extension AuthorizationInteractorState: GeneralizableState {
	public var isLoadingState: Bool {
		guard case .sendingSMSCodeRequest = self else { return false }
		return true
	}
	
	public var isDataLoadedState: Bool {
		guard case .routedToCodeCheck = self else { return false }
		return true
	}
	
	public var isLoadingErrorState: Bool {
		guard case .sendingSMSCodeRequest = self else { return false }
		return true
	}
}

extension AuthorizationInteractorState: LoadingIndicatableState {
	public var shouldLoadingIndicatorBeVisible: Bool {
		guard case .sendingSMSCodeRequest = self else { return false }
		return true
	}
}
