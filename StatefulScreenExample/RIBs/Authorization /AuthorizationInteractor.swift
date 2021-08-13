//
//  AuthorizationInteractor.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 12.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift

final class AuthorizationInteractor: Interactor, AuthorizationInteractable {
	weak var router: AuthorizationRouting?
	
	private let disposeBag = DisposeBag()
}

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
