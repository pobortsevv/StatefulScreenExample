//
//  AuthorizationInteractor.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 12.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

final class AuthorizationInteractor: PresentableInteractor<AuthorizationPresentable>, AuthorizationInteractable {
	// MARK: Dependecies
	
	weak var router: AuthorizationRouting?
	
	private let authorizationProvider: AuthorizationProfileProvider
//	private var phoneNumber: String?
	
	// MARK: Internals
	
	// Задаем начальное состояние для нашего экрана
	private let _state = BehaviorRelay<AuthorizationInteractorState>(value: .userInput)
	
	private let responses = Responses()
	
	private let disposeBag = DisposeBag()
	
	init(presenter: AuthorizationPresentable,
			 authorizationProvider: AuthorizationProfileProvider) {
		self.authorizationProvider = authorizationProvider
		super.init(presenter: presenter)
	}
	
	override func didBecomeActive() {
		super.didBecomeActive()
		
		/// Использовать данную функцию только при нажатии пользователем кнопки
		/// "Получить смс"
		//recieveSMS()
	}

	private func recieveSMS(number: String?) {
		authorizationProvider.checkNumber(number) { [weak self] result in
			switch result {
			case .success(let signal): self?.responses.$didRecieveSMS.accept(signal)
			case .failure(let error): self?.responses.$authorizationError.accept(error)
			}
		}
	}
}

// MARK: - IOTransformer

extension AuthorizationInteractor: IOTransformer {
	func transform(input viewOutput: AuthorizationViewOutput) -> AuthorizationInteractorOutput {
		let trait = StateTransformTrait(_state: _state, disposeBag: disposeBag)
		
		let refinedPhone = viewOutput.phoneNumberTextChange
			.startWith("")
			.map { phoneNumber in
				phoneNumber.removingCharacters(except: .arabicNumerals)
			}
			.distinctUntilChanged()
		
		let requests = makeRequests()
		
		StateTransform.transform(trait: trait, viewOutput: viewOutput, phoneNumber: refinedPhone, responses: responses, requests: requests)
		
		return AuthorizationInteractorOutput(state: trait.readOnlyState, refinedPhone: refinedPhone)
	}
}


extension AuthorizationInteractor {
	private typealias State = AuthorizationInteractorState
	
	/// Реализация переходов между состояниями
	private enum StateTransform: StateTransformer{
		/// case .userInput
		static let byUserInputState: (State) -> Bool = { state -> Bool in
			guard case .userInput = state else {return false}; return true
		}
		
		/// case .sendingSMSCodeRequest
		static let bySendingSMSCodeRequestState: (State) -> String? = { state in
			guard case .sendingSMSCodeRequest(let phoneNumber) = state else { return nil }; return phoneNumber
		}
		
		/// case .gotSMSCode
//		static let byGotSMSCode: (State) -> Bool = { state -> Bool in
//			guard case .gotSMSCode = state else {return false}; return true
//		}
	
		static func transform(trait: StateTransformTrait<State>,
													viewOutput: AuthorizationViewOutput,
													phoneNumber: Observable<String>,
													responses: Responses,
													requests: Requests) {
			StateTransform.transitions {
				// userInput -> sendingSMSCodeRequest
				viewOutput.getSMSButtonTap.filteredByState(trait.readOnlyState, filter: byUserInputState)
					.withLatestFrom(phoneNumber)
					.do(afterNext: requests.recieveSMS)
					.map { phoneNumber in State.sendingSMSCodeRequest(phoneNumber: phoneNumber)}
				
				// sendingSMSCodeRequest -> responseError
				responses.authorizationError
					.filteredByState(trait.readOnlyState, filterMap: bySendingSMSCodeRequestState)
					.map { error, phoneNumber in State.smsCodeRequestError(error: error, phoneNumber: phoneNumber) }
	//				.filteredByState(trait.readOnlyState, filter: bySendingSMSCodeRequestState)
	//				.map { error in State.responseError(error) }
				
				// responseError -> userInput
				viewOutput.retryButtonTap.filteredByState(trait.readOnlyState, filterMap: { state -> String? in
					guard case let .smsCodeRequestError(_, phoneNumber) = state else { return nil }; return phoneNumber
				})
				.do(afterNext: requests.recieveSMS)
				.map { phoneNumber in State.sendingSMSCodeRequest(phoneNumber: phoneNumber) }
				
				// sendingSMSCodeRequest -> gotSMSCode
				responses.didRecieveSMS.filteredByState(trait.readOnlyState, compactMapAsFilter: bySendingSMSCodeRequestState)
					.map { _ in State.routedToCodeCheck }
			}.bindToAndDisposedBy(trait: trait)
		}
	}
}


// MARK: - Help Methods

extension AuthorizationInteractor {
	private func makeRequests() -> Requests {
		Requests(recieveSMS: { [weak self] phoneNumber in self?.recieveSMS(number: phoneNumber) })
	}
}

// MARK: - Nested Types

extension AuthorizationInteractor {
	private struct Responses {
		@PublishObservable var didRecieveSMS: Observable<Void>
		@PublishObservable var authorizationError: Observable<Error>
	}
	
	private struct Requests {
		let recieveSMS: (_ phoneNumer: String) -> Void
//		let recieveInput: VoidClosure
	}
}

extension CharacterSet {
	/// "0123456789"
	public static let arabicNumerals = CharacterSet(charactersIn: "0123456789")
}

extension String {
	/// Удалятся все символы (Unicode Scalar'ы) кроме символов из указанного CharacterSet. Например все кроме цифр
	public func removingCharacters(except characterSet: CharacterSet) -> String {
		let scalars = unicodeScalars.filter(characterSet.contains(_:))
		return String(scalars)
	}
	
	/// Удалятся все символы (Unicode Scalar'ы), которые соответствуют указанному CharacterSet.
	/// Например все точки и запятые
	public func removingCharacters(in characterSet: CharacterSet) -> String {
		let scalars = unicodeScalars.filter { !characterSet.contains($0) }
		return String(scalars)
	}
}
