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

final class AuthorizationInteractor: Interactor, AuthorizationInteractable {
	// MARK: Dependecies
	
	weak var router: AuthorizationRouting?
	private let disposeBag = DisposeBag()
	
	// MARK: Internals
	
	// private let _state
	
	private let responses = Responses()
	
	override func didBecomeActive() {
		super.didBecomeActive()
		loadAuthorization()
	}

	private func loadAuthorization() {
		
	}
	
	
	
	
	
}


// MARK: - IOTransformer

extension AuthorizationInteractor: IOTransformer {
	func transform(input: AuthorizationViewOutput) -> Empty {
		
		// TODO: Здесь должны быть зависимости
		
//		input.getSMSButton.subscribe(onNext: {[weak self] in
//			print("kek")
//		}).disposed(by: disposeBag)
//
//		input.phoneNunberTextField.subscribe(onNext: {[]})
		
		return Empty()
	}
}

// MARK: - Help Methods

extension ProfileInteractor {
	private func makeRequests() -> Requests {
		Requests(loadAuthorization: { [weak self] in self?.loadProfile() })
	}
}

// MARK: - Nested Types

extension AuthorizationInteractor {
	private struct Responses {
		@PublishObservable var didLoadAuthorization: Observable<Profile>
		@PublishObservable var authorizationLoadingError: Observable<Error>
	}
	
	private struct Requests {
		let loadAuthorization: VoidClosure
	}
}
