//
//  AuthorizationRouter.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 12.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift


final class AuthorizationRouter: ViewableRouter<AuthorizationInteractable, AuthorizationViewControllable>, AuthorizationRouting {

	private let validatorBuilder: ValidatorBuildable
	
	private let disposeBag = DisposeBag()
	
	// TODO: Добавить buildable в аргументы для следующего экрана
	init(interactor: AuthorizationInteractable,
								viewController: AuthorizationViewControllable,
								validatorBuilder: ValidatorBuildable) {
		self.validatorBuilder = validatorBuilder
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}
	
	func routeToValidator(phoneNumber: String) {
		let router = validatorBuilder.build(phoneNumber: phoneNumber)
		attachChild(router)
		viewController.uiviewController.present(router.viewControllable.uiviewController, animated: true)
//		viewController.uiviewController.navigationController?.pushViewController(router.viewControllable.uiviewController, animated: true)
		
		detachWhenClosed(child: router, disposedBy: disposeBag)
	}
}
