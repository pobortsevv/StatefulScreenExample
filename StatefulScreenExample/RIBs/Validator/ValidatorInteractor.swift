//
//  ValidatorInteractor.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 23.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa

final class ValidatorInteractor: PresentableInteractor<ValidatorPresentable>, ValidatorInteractable{
	weak var router: ValidatorRouting?
	weak var listener: ValidatorListener?
	
	private let phoneNumber: String
	
	private let authorizationProvider: AuthorizationProfileProvider
	
	private let _state = BehaviorRelay<ValidatorInteractorState>(value: .userInput(error: nil))
	
	private let _screenDataModel: BehaviorRelay<ValidatorScreenDataModel>
	
	private let responses = Responses()

	private let disposeBag = DisposeBag()
	// TODO: Add additional dependencies to constructor. Do not perform any logic
	// in constructor.
	init(presenter: ValidatorPresentable,
			 authorizationProvider: AuthorizationProfileProvider,
			 phoneNumber: String) {
		 
		let screenDataModel = ValidatorScreenDataModel(phoneNumber: phoneNumber)
		_screenDataModel = BehaviorRelay(value: screenDataModel)
		self.authorizationProvider = authorizationProvider
		self.phoneNumber = phoneNumber
		super.init(presenter: presenter)
	}
	
	private func checkCode(code: String) {
		authorizationProvider.checkCode(code: code, completion: { [weak self] result in
			switch result {
			case .success: self?.responses.$correctCode.accept(true)
			case .failure(let error):
				switch error {
				case .validationError: self?.responses.$validationError.accept(error)
				case .networkError: self?.responses.$networkError.accept(error)
				}
			}
		})
	}
}

// MARK: - IOTransformer

extension ValidatorInteractor: IOTransformer {
	func transform(input viewOutput: ValidatorViewOutput) -> ValidatorInteractorOutput {
		let trait = StateTransformTrait(_state: _state, disposeBag: disposeBag)
		
		let refinedCode = viewOutput.codeTextChange
			.map { code -> String in
				let _code = code
					.removingCharacters(except: .arabicNumerals)
					.prefix(5)
				return String(_code)
			}
		
		let requests = makeRequests()
		
		StateTransform.transform(trait: trait,
														 viewOutput: viewOutput,
														 code: refinedCode,
														 responses: responses,
														 requests: requests,
														 screenDataModel: _screenDataModel,
														 disposeBag: disposeBag,
														 listener: listener)
		
		return ValidatorInteractorOutput(state: trait.readOnlyState, screenDataModel: _screenDataModel.asObservable())
	}
}

// MARK: - State transformation

extension ValidatorInteractor {
	private typealias State = ValidatorInteractorState
	
	private enum StateTransform: StateTransformer {
		/// case UserInput
		static let byUserInputState: (State) -> Bool = { state -> Bool in
			guard case .userInput = state else { return false }; return true
		}
		
		/// case SendingCodeCheckRequest
		static let bySendingCodeCheckRequestState: (State) -> Bool = { state in
			guard case .sendingCodeCheckRequest = state else { return false }; return true
		}
		
		static func transform(trait: StateTransformTrait<State>,
													viewOutput: ValidatorViewOutput,
													code: Observable<String>,
													responses: Responses,
													requests: Requests,
													screenDataModel: BehaviorRelay<ValidatorScreenDataModel>,
													disposeBag: DisposeBag,
													listener: ValidatorListener?) {
			StateTransform.transitions {
				// UserInput -> SendingCodeRequest
				code.filter { text in text.count == 5 }
					.filteredByState(trait.readOnlyState, filter: byUserInputState)
					.do(afterNext: requests.checkCode)
					.map { _ in State.sendingCodeCheckRequest }
				
				// SendingCodeRequest -> UserInput(error)
				responses.networkError
				  .filteredByState(trait.readOnlyState, filter: bySendingCodeCheckRequestState)
					.map { error in State.userInput(error: error) }
				
				responses.validationError
					.filteredByState(trait.readOnlyState, filter: bySendingCodeCheckRequestState)
					.map { error in State.userInput(error: error) }
				
				// SendingCodeRequest -> UpdateProfile
				responses.correctCode
					.filteredByState(trait.readOnlyState, filter: bySendingCodeCheckRequestState)
					.withLatestFrom(screenDataModel.asObservable(), resultSelector: { ($0, $1) })
					.do(afterNext: { _, number in requests.updateProfilePhoneNumber(number.phoneNumber)})
					.map {_ in State.updatingProfile}
				
				// UpdateProfile -> close
				responses.updatedProfile
					.filteredByState(trait.readOnlyState, filter: { state -> Bool in
						guard case .updatingProfile = state else { return false }; return true
					})
					.do(afterNext: { listener?.successAuth()})
					.map { _ in State.updatedProfile}
				
				
			}.bindToAndDisposedBy(trait: trait)

			updateScreenDataModel(screenDataModel: screenDataModel, codeText: code, disposeBag: disposeBag)
		}
		
		static func updateScreenDataModel(screenDataModel: BehaviorRelay<ValidatorScreenDataModel>,
																			codeText: Observable<String>,
																			disposeBag: DisposeBag) {
			let readOnlyScreenDataModel = screenDataModel.asObservable()
			
			codeText.withLatestFrom(readOnlyScreenDataModel, resultSelector: { ($0, $1) })
				.map { codeText, screenDataModel in
					mutate(value: screenDataModel, mutation: { $0.codeTextField = codeText })
				}
				.bind(to: screenDataModel)
				.disposed(by: disposeBag)
		}
	}
}

// MARK: - Help Methods

extension ValidatorInteractor {
	private func makeRequests() -> Requests {
		Requests(checkCode: { [weak self] code in self?.checkCode(code: code) },
						 updateProfilePhoneNumber: { [weak self] phoneNumber in self?.authorizationProvider.updatePhoneNumber(phoneNumber: phoneNumber)})
	}
}

// MARK: - Nested Types

extension ValidatorInteractor {
	private struct Responses {
		@PublishObservable var correctCode: Observable<Bool>
		@PublishObservable var updatedProfile: Observable<Void>
		@PublishObservable var networkError: Observable<AuthError>
		@PublishObservable var validationError: Observable<AuthError>
	}
	
	private struct Requests {
		let checkCode: (_ code: String) -> Void
		let updateProfilePhoneNumber: (_ phoneNumber: String) -> Void
	}
}
