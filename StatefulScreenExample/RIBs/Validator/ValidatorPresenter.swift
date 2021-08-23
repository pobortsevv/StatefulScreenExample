//
//  ValidatorPresenter.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 23.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

final class ValidatorPresenter: ValidatorPresentable {}

// MARK: - IOTransformer

extension ValidatorPresenter: IOTransformer {
	func transform(input: ValidatorInteractorOutput) -> ValidatorPresenterOutput {
		//
		return ValidatorPresenterOutput()
	}
}
