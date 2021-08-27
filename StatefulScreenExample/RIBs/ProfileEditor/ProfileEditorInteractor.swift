//
//  ProfileEditorInteractor.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 25.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift



final class ProfileEditorInteractor: PresentableInteractor<ProfileEditorPresentable>, ProfileEditorInteractable {
	weak var router: ProfileEditorRouting?
	
	private let profileProvider: AuthorizationProfileProvider

	// MARK: Internals
	
	private let _state = BehaviorRelay<ProfileEditorInteractorState>(value: .userInput)
	
	private let _screenDataModel: BehaviorRelay<ProfileEditorScreenDataModel>
	
	private let responses = Responses()
	private let emailValidation = EmailValidation()
	
	private let disposeBag = DisposeBag()
	
	init(presenter: ProfileEditorPresentable,
			 profileProvider: AuthorizationProfileProvider,
			 profile: Profile) {
		self.profileProvider = profileProvider
		let screenDataModel = ProfileEditorScreenDataModel(firstName: profile.firstName,
																											 secondName: profile.lastName,
																											 phoneNumber: profile.phone,
																											 email: profile.email)
		_screenDataModel = BehaviorRelay(value: screenDataModel)
		super.init(presenter: presenter)
	}
	
	private func updateProfile(profile: Profile) {
		profileProvider.updateProfile(profile) { [weak self] result in
			switch result {
			case .success: self?.responses.$profileUpdated.accept(Void())
			case .failure(let error): self?.responses.$updateError.accept(error)
			}
		}
	}
	
	private func checkEmail(email: String) -> Bool {
		if email != "" {
			if email.contains("@") == false || email.firstIndex(of: "@") != email.lastIndex(of: "@") {
				emailValidation.$isValid.accept(false)
				return false
			}
		}
		return true
	}
}

// MARK: - IOTransformer

extension ProfileEditorInteractor: IOTransformer {
	func transform(input viewOutput: ProfileEditorViewOutput) -> ProfileEditorInteractorOutput {
		let trait = StateTransformTrait(_state: _state, disposeBag: disposeBag)
		
		let refinedName = viewOutput.nameTextChange
			.map { name -> String in
				let _name = name
					.removingCharacters(except: .letters)
				
				return String(_name)
			}
		
		let refinedSecondName = viewOutput.secondNameTextChange
			.map { secondName -> String in
				let _secondName = secondName
					.removingCharacters(except: .letters)
				
				return String(_secondName)
			}
		
		let refinedEmail = viewOutput.emailTextChange
			.map { email -> String in
				let _email = email
					.removingCharacters(in: .whitespacesAndNewlines)
				
				return String(_email)
			}
		
		let requests = makeRequests()
		let routes = makeRoutes()
		let validationEmailRequests = makeValidationEmailRequests()
		
		
		StateTransform.transform(trait: trait,
														 viewOutput: viewOutput,
														 name: refinedName,
														 secondName: refinedSecondName,
														 email: refinedEmail,
														 response: responses,
														 requests: requests,
														 validationEmailRequests: validationEmailRequests,
														 routes: routes,
														 emailValidation: emailValidation,
														 screenDataModel: _screenDataModel,
														 disposeBag: disposeBag)
		
		return ProfileEditorInteractorOutput(state: trait.readOnlyState,
																				 screenDataModel: _screenDataModel.asObservable())
	}
}

extension ProfileEditorInteractor {
	private typealias State = ProfileEditorInteractorState
	
	/// State-Машина
	private enum StateTransform: StateTransformer {
		// Case .UserInput
		static let byUserInputState: (State) -> Bool = { state -> Bool in
			guard case .userInput = state else { return false }; return true
		}
		
		// Case .UpdatingProfile
		static let byUpdatingProfileState: (State) -> Profile? = { state in
			guard case .updatingProfile(let profile) = state else { return nil }; return profile
		}
		
		static func transform(trait: StateTransformTrait<State>,
													viewOutput: ProfileEditorViewOutput,
													name: Observable<String>,
													secondName: Observable<String>,
													email: Observable<String>,
													response: Responses,
													requests: Requests,
													validationEmailRequests: ValidateEmail,
													routes: Routes,
													emailValidation: EmailValidation,
													screenDataModel: BehaviorRelay<ProfileEditorScreenDataModel>,
													disposeBag: DisposeBag) {
			StateTransform.transitions {
				// UserInput -> UpdatingProfile
				viewOutput.updateProfileButtonTap.filteredByState(trait.readOnlyState, filter: byUserInputState)
					.withLatestFrom(screenDataModel.asObservable(), resultSelector: { ($0, $1) })
					.filter { _, text -> Bool in validationEmailRequests.checkEmail(text.emailTextField)}
					.do(afterNext: { _, text in
						requests.updateProfile(Profile(firstName: text.nameTextField,
																					 lastName: text.secondNameTextField,
																					 email: text.emailTextField,
																					 phone: text.phoneNumberTextField,
																					 authorized: true))
					})
					.map { _, text in State.updatingProfile(profile: Profile(firstName: text.nameTextField,
																																	 lastName: text.secondNameTextField,
																																	 email: text.emailTextField,
																																	 phone: text.phoneNumberTextField,
																																	 authorized: true))}
				
				// UpdatingProfile -> UpdateProfileRequestError
				response.updateError
					.filteredByState(trait.readOnlyState, filterMap: byUpdatingProfileState)
					.map { error, profile in State.updateProfileRequestError(error: error, profile: profile) }
				
				// UpdateProfileRequestError -> UpdatingProfile
				viewOutput.retryButtonTap.filteredByState(trait.readOnlyState, filterMap: { state -> Profile? in
					guard case let .updateProfileRequestError(_, profile) = state else { return nil }; return profile
				} )
				.do(afterNext: requests.updateProfile)
				.map { profile in State.updatingProfile(profile: profile) }
				
				// UpdatingProfile -> routeToProfile
				response.profileUpdated
					.filteredByState(trait.readOnlyState, filter: { state -> Bool in
						guard case .updatingProfile = state else { return false }; return true
					})
					.observe(on: MainScheduler.instance)
					.do(afterNext: routes.close)
					.map { _ in State.routedToProfile}
				
			}.bindToAndDisposedBy(trait: trait)
			
			updateScreenDataModel(emailValidation: emailValidation,
														screenDataModel: screenDataModel,
														nameText: name,
														secondNameText: secondName,
														emailText: email,
														disposeBag: disposeBag)
			
		}
		
		static func updateScreenDataModel(emailValidation: EmailValidation,
																			screenDataModel: BehaviorRelay<ProfileEditorScreenDataModel>,
																			nameText: Observable<String>,
																			secondNameText: Observable<String>,
																			emailText: Observable<String>,
																			disposeBag: DisposeBag) {
			let readOnlyScreenDataModel = screenDataModel.asObservable()
			
			disposeBag.insert {
				emailValidation.isValid
					.withLatestFrom(readOnlyScreenDataModel, resultSelector: { ($0, $1) })
					.map { isValid, screenDataModel in
						mutate(value: screenDataModel, mutation: { $0.isEmailValid = isValid})
					}
					.bind(to: screenDataModel)
				
				nameText.withLatestFrom(readOnlyScreenDataModel, resultSelector: { ($0, $1) })
					.map { name, screenDataModel in
						mutate(value: screenDataModel, mutation: { $0.nameTextField = name } )
					}
					.bind(to: screenDataModel)
				secondNameText.withLatestFrom(readOnlyScreenDataModel, resultSelector: { ($0, $1) })
					.map { secondName, screenDataModel in
						mutate(value: screenDataModel, mutation: { $0.secondNameTextField = secondName } )
					}
					.bind(to: screenDataModel)
				emailText.withLatestFrom(readOnlyScreenDataModel, resultSelector: { ($0, $1) })
					.map { email, screenDataModel in
						mutate(value: screenDataModel, mutation: { $0.emailTextField = email } )
					}
					.bind(to: screenDataModel)
				emailText.withLatestFrom(readOnlyScreenDataModel, resultSelector: { ($0, $1) })
					.map { email, screenDataModel in
						mutate(value: screenDataModel, mutation: { $0.isEmailValid = true } )
					}
					.bind(to: screenDataModel)
			}
			
		}
	}
}

// MARK: - Help Methods

extension ProfileEditorInteractor {
	private func makeRequests() -> Requests {
		Requests(updateProfile: { [weak self] profile in self?.updateProfile(profile: profile) })
	}
	
	private func makeRoutes() -> Routes {
		Routes(close: { [weak self] in self?.router?.close()} )
	}
	
	private func makeValidationEmailRequests() -> ValidateEmail {
		ValidateEmail(checkEmail: { [weak self] email in (self?.checkEmail(email: email))!})
	}
}

// MARK: - Nested Types

extension ProfileEditorInteractor {
	private struct Responses {
		@PublishObservable var profileUpdated: Observable<Void>
		@PublishObservable var updateError: Observable<Error>
	}
	
	private struct EmailValidation {
		@PublishObservable var isValid: Observable<Bool>
	}
	
	private struct Requests {
		let updateProfile: (_ profile: Profile) -> Void
	}
	
	private struct ValidateEmail {
		let checkEmail: (_ email: String) -> Bool
	}
	
	private struct Routes {
		let close: () -> Void
	}
	
	struct ValidationEmailError: LocalizedError {
		var errorDescription: String? { "Введен неверный email" }
	}
}
