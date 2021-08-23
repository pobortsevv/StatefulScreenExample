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
	

	private let _state = BehaviorRelay<ValidatorInteractorState>(value: .userInput)
	
	private let _screenDataModel: BehaviorRelay<ValidatorScreenDataModel>

	private let disposeBag = DisposeBag()
	// TODO: Add additional dependencies to constructor. Do not perform any logic
	// in constructor.
	override init(presenter: ValidatorPresentable) {
		_screenDataModel = BehaviorRelay(value: ValidatorScreenDataModel())
		super.init(presenter: presenter)
	}

	override func didBecomeActive() {
			super.didBecomeActive()
			// TODO: Implement business logic here.
	}

	override func willResignActive() {
			super.willResignActive()
			// TODO: Pause any business logic.
	}
}

// MARK: - IOTransformer

extension ValidatorInteractor: IOTransformer {
	func transform(input viewOutput: ValidatorViewOutput) -> ValidatorInteractorOutput {
		let trait = StateTransformTrait(_state: _state, disposeBag: disposeBag)
		return ValidatorInteractorOutput(state: trait.readOnlyState, screenDataModel: _screenDataModel.asObservable())
	}
}
