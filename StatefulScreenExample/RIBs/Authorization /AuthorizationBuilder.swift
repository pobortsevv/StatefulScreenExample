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
		let presenter = AuthorizationPresenter()
		let interactor = AuthorizationInteractor(presenter: presenter, authorizationProvider: dependency.profileProvider)
		
		// После верстки
		VIPBinder.bind(view: viewController, interactor: interactor, presenter: presenter)
	
		return AuthorizationRouter(interactor: interactor, viewController: viewController)
		// TODO: Дополнить builder-ом следующего экрана
	}
}
