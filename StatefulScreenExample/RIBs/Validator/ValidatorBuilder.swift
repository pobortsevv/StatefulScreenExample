//
//  ValidatorBuilder.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 23.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs

final class ValidatorBuilder: Builder<RootDependency>, ValidatorBuildable {
    func build() -> ValidatorRouting {
			let viewController = ValidatorViewController.instantiateFromStoryboard()
			let presenter = ValidatorPresenter()
			let interactor = ValidatorInteractor(presenter: presenter)
			
			VIPBinder.bind(view: viewController, interactor: interactor, presenter: presenter)
		
			return ValidatorRouter(interactor: interactor, viewController: viewController)
	}
}
