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

	//	private let Билдер след экрана
	private let disposeBag = DisposeBag()
	
	// TODO: Добавить buildable в аргументы для следующего экрана
	override init(interactor: AuthorizationInteractable, viewController: AuthorizationViewControllable) {
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}
	
	func routeToCheckSMSCode() {
		// let router = checkSMSCode.build()
//		attachChild(router)
		//viewController.uiviewController.navigationController?.pushViewController(router.viewControllable.uiviewController,
		 //animated: true)
		// detachWhenClosed(child: router, disposedBy: disposeBag)
	}
}
