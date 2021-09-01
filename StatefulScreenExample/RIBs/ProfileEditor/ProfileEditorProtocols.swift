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
	/// ProfileEditor - модуль для редактирования аккаунта пользователя
	func build(profile: Profile) -> ProfileEditorRouting
}
 
// MARK: - Router

protocol ProfileEditorInteractable: Interactable {
	var router: ProfileEditorRouting? { get set }
}

protocol ProfileEditorViewControllable: ViewControllable {}

// MARK: - Interactor

protocol ProfileEditorRouting: ViewableRouting {
	func close()
}

protocol ProfileEditorPresentable: Presentable {}

// MARK: States

enum ProfileEditorInteractorState {
	case userInput
	case updatingProfile(profile: Profile)
	case updateProfileError(error: Error, profile: Profile)
	case routedToProfile
}

extension ProfileEditorInteractorState: GeneralizableState {
	public var isLoadingState: Bool {
		guard case .updatingProfile = self else { return false }
		return true
	}

	public var isDataLoadedState: Bool {
		guard case .routedToProfile = self else { return false }
		return true
	}

	public var isLoadingErrorState: Bool {
		guard case .updateProfileError = self else { return false }
		return true
	}
}

extension ProfileEditorInteractorState: LoadingIndicatableState {
	public var shouldLoadingIndicatorBeVisible: Bool {
		guard case .updatingProfile = self else { return false }
		return true
	}
}

// MARK: Outputs

struct ProfileEditorInteractorOutput {
	let state: Observable<ProfileEditorInteractorState>
	let screenDataModel: Observable<ProfileEditorScreenDataModel>
}

struct ProfileEditorPresenterOutput {
	let initialLoadingIndicatorVisible: Driver<Bool>
	let firstName: Driver<String>
	let lastName: Driver<String>
	let email: Driver<String>
	let phone: Driver<String>
	let isEmailValid: Signal<Bool>
	let profileSuccessfullyEdited: Signal<Bool>
	let showError: Signal<ErrorMessageViewModel?>
}

protocol ProfileEditorViewOutput {
	var updateProfileButtonTap: ControlEvent<Void> { get }
	var firstNameTextChange: ControlEvent<String> { get }
	var lastNameTextChange: ControlEvent<String> { get }
	var emailTextChange: ControlEvent<String> { get }
	var retryButtonTap: ControlEvent<Void> { get }
	var alertButtonTap: ControlEvent<Void> { get }
}

// MARK: ScreenDataModel

struct ProfileEditorScreenDataModel {
	var firstNameTextField: String
	var lastNameTextField: String
	let phoneNumberTextField: String
	var emailTextField: String
	var isEmailValid: Bool
}

extension ProfileEditorScreenDataModel {
	init (profile: Profile) {
		firstNameTextField = (profile.firstName ?? "")
		lastNameTextField = (profile.lastName ?? "")
		phoneNumberTextField = profile.phone
		emailTextField = (profile.email ?? "")
		isEmailValid = true
	}
	
//	init (email: String) {
//
//	}
}

