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
	weak var router: AuthorizationRouting?
	
	private let authorizationProvider: AuthorizationProfileProvider
	
	// MARK: Internals
	
	// Задаем начальное состояние для нашего экрана
	private let _state = BehaviorRelay<AuthorizationInteractorState>(value: .userInput)
	
	private let _screenDataModel: BehaviorRelay<AuthorizationScreenDataModel>
	
	private let responses = Responses()
	
	private let externalEvents = ExternalEvents()
	
	private let disposeBag = DisposeBag()
	
	init(presenter: AuthorizationPresentable,
			 authorizationProvider: AuthorizationProfileProvider) {
		self.authorizationProvider = authorizationProvider
		_screenDataModel = BehaviorRelay(value: AuthorizationScreenDataModel())
		super.init(presenter: presenter)
	}
	
	private func recieveSMS(number: String?) {
		authorizationProvider.checkNumber(number) { [weak self] result in
			switch result {
			case .success(let code): self?.responses.$didRecieveSMS.accept(code)
			case .failure(let error): self?.responses.$authorizationError.accept(error)
			}
		}
	}
}

// Validator Listener
extension AuthorizationInteractor {
	func successAuth() {
		externalEvents.$successAuth.accept(Void())
	}
}

// MARK: - IOTransformer

extension AuthorizationInteractor: IOTransformer {
	func transform(input viewOutput: AuthorizationViewOutput) -> AuthorizationInteractorOutput {
		let trait = StateTransformTrait(_state: _state, disposeBag: disposeBag)
		
		let refinedPhone = viewOutput.phoneNumberTextChange
			.map { phoneNumber -> String in
				let _phoneNumber = phoneNumber
					.removingCharacters(except: .arabicNumerals)
					.prefix(11)
				
				return String(_phoneNumber)
			}
		
		let requests = makeRequests()
		let routes = makeRoutes()
		
		StateTransform.transform(trait: trait,
														 viewOutput: viewOutput,
														 phoneNumber: refinedPhone,
														 responses: responses,
														 requests: requests,
														 routes: routes,
														 screenDataModel: _screenDataModel,
														 disposeBag: disposeBag,
														 externalEvents: externalEvents)
		
		return AuthorizationInteractorOutput(state: trait.readOnlyState,
																				 screenDataModel: _screenDataModel.asObservable())
	}
}

extension AuthorizationInteractor {
	private typealias State = AuthorizationInteractorState
	
	/// Реализация переходов между состояниями
	private enum StateTransform: StateTransformer{
		/// case .userInput
		static let byUserInputState: (State) -> Bool = { state -> Bool in
			guard case .userInput = state else { return false }; return true
		}
		
		/// case .sendingSMSCodeRequest
		static let bySendingSMSCodeRequestState: (State) -> String? = { state in
			guard case .sendingSMSCodeRequest(let phoneNumber) = state else { return nil }; return phoneNumber
		}
	
		static func transform(trait: StateTransformTrait<State>,
													viewOutput: AuthorizationViewOutput,
													phoneNumber: Observable<String>,
													responses: Responses,
													requests: Requests,
													routes: Routes,
													screenDataModel: BehaviorRelay<AuthorizationScreenDataModel>,
													disposeBag: DisposeBag,
													externalEvents: ExternalEvents) {
			StateTransform.transitions {
				// userInput -> sendingSMSCodeRequest
				viewOutput.getSMSButtonTap.filteredByState(trait.readOnlyState, filter: byUserInputState)
					.withLatestFrom(phoneNumber)
					.do(afterNext: requests.recieveSMS)
					.map { phoneNumber in State.sendingSMSCodeRequest(phoneNumber: phoneNumber)}
				
				// sendingSMSCodeRequest -> responseError
				responses.authorizationError // filterMap позволяет проверить из правильного ли мы состояния переключаемся
					.filteredByState(trait.readOnlyState, filterMap: bySendingSMSCodeRequestState)
					.map { error, phoneNumber in State.smsCodeRequestError(error: error, phoneNumber: phoneNumber) }
				
				// responseError -> sendingSMSCodeRequest
				viewOutput.retryButtonTap.filteredByState(trait.readOnlyState, filterMap: { state -> String? in
					guard case let .smsCodeRequestError(_, phoneNumber) = state else { return nil }; return phoneNumber
				})
				.do(afterNext: requests.recieveSMS)
				.map { phoneNumber in State.sendingSMSCodeRequest(phoneNumber: phoneNumber) }
				
				// sendingSMSCodeRequest -> gotSMSCode
				responses.didRecieveSMS.filteredByState(trait.readOnlyState) { state in
					guard case .sendingSMSCodeRequest = state else { return false } ; return true
				}
				.observe(on: MainScheduler.instance)
				.withLatestFrom(screenDataModel.asObservable(), resultSelector: { ($0, $1) })
				.do(afterNext: { _, text in
					let formattedPhone = formatPhone(number: text.phoneNumberTextField)
					routes.routeToValidator(formattedPhone)
				})
				.map { code, _ in State.routedToCodeCheck(code: code) }
			}.bindToAndDisposedBy(trait: trait)
		
			updateScreenDataModel(screenDataModel: screenDataModel, phoneNumberText: phoneNumber, disposeBag: disposeBag)
			bindStatelessRouting(disposeBag: disposeBag, externalEvents: externalEvents, close: routes.close)
		}
		
		static func updateScreenDataModel(screenDataModel: BehaviorRelay<AuthorizationScreenDataModel>,
																			phoneNumberText: Observable<String>,
																			disposeBag: DisposeBag) {
			let readOnlyScreenDataModel = screenDataModel.asObservable()
			
			phoneNumberText.withLatestFrom(readOnlyScreenDataModel, resultSelector: { ($0, $1) })
				.map { phoneNumberText, screenDataModel in
					mutate(value: screenDataModel, mutation: { $0.phoneNumberTextField = phoneNumberText })
				}
				.bind(to: screenDataModel)
				.disposed(by: disposeBag)
		}
		
		static func bindStatelessRouting(disposeBag: DisposeBag,
																		 externalEvents: ExternalEvents,
																		 close:  @escaping VoidClosure) {
			externalEvents.successAuth.bind(onNext: close).disposed(by: disposeBag)
		}
	}
}

// MARK: - Help Methods

extension AuthorizationInteractor {
	private func makeRequests() -> Requests {
		Requests(recieveSMS: { [weak self] phoneNumber in self?.recieveSMS(number: phoneNumber) })
	}
	
	private func makeRoutes() -> Routes {
		Routes(routeToValidator: { [weak self] formattedPhoneNumber in self?.router?.routeToValidator(phoneNumber: formattedPhoneNumber) },
					 close: { [weak self] in self?.router?.close()})
	}
}

// MARK: - Nested Types

extension AuthorizationInteractor {
	private struct Responses {
		@PublishObservable var didRecieveSMS: Observable<String>
		@PublishObservable var authorizationError: Observable<Error>
	}
	
	private struct ExternalEvents {
		@PublishObservable var successAuth: Observable<Void>
	}
	
	private struct Requests {
		let recieveSMS: (_ phoneNumer: String) -> Void
	}
	
	private struct Routes {
		let routeToValidator: (_ phoneNumber: String) -> Void
		let close: VoidClosure
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
	
	public func compareLenght(with len: Int) -> String {
		if (self.count > len) {
			return String(self.prefix(len))
		}
		return self
	}
	
	/// Функция генерации  sms кода
	public static func randomCode() -> String {
		let len = 5
		let codeChars = "0123456789"
		let code = String((0..<len).compactMap{ _ in codeChars.randomElement() })
		return code
	}
}
