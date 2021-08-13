//
//  AuthorizationBuilder.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 12.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs

final class AuthorizationBuilder: Builder<RootDependency>, AuthorizationBuildable {
	func build() -> AuthorizationRouting {
		let viewController = AuthorizationViewController.instantiateFromStoryboard()
		let interactor = AuthorizationInteractor()
		
		// После верстки
		VIPBinder.bind(viewController: viewController, interactor: interactor)
	
		return AuthorizationRouter(interactor: interactor, viewController: viewController)
		// TODO: Дополнить builder-ом следующего экрана
	}
}
