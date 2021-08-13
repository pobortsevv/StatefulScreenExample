//
//  AuthorizationProtocols.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 12.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa

// MARK: - Builder

protocol AuthorizationBuildable: Buildable {
		func build() -> AuthorizationRouting
}

// MARK: - Router

protocol AuthorizationInteractable: Interactable {
		var router: AuthorizationRouting? { get set }
}

protocol AuthorizationViewControllable: ViewControllable {}

// MARK: - Interactor

protocol AuthorizationRouting: ViewableRouting {
		// TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
	// routesToNextScreens!!!
}

// MARK: Outputs

struct AuthorizationViewOutput {
	let getSMSButton: ControlEvent<Void>
	let phoneNunberTextField: ControlEvent<Void>
	// let retryButton: ControlEvent<Void>
}

