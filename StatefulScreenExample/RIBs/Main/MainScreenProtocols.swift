//
//  MainScreenProtocols.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 08.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

// MARK: - Builder

protocol MainScreenBuildable: Buildable {
  func build() -> MainScreenRouting
}

// MARK: - Router

protocol MainScreenInteractable: Interactable {
  var router: MainScreenRouting? { get set }
}

protocol MainScreenViewControllable: ViewControllable {}

// MARK: - Interactor

protocol MainScreenRouting: ViewableRouting {
  func routeToStackViewProfile()
  func routeToAuthorization()
  func routeToTableViewProfile()
}

// MARK: Outputs

protocol MainScreenViewOutput {
	var stackViewButtonTap: ControlEvent<Void> { get }
	var tableViewButtonTap: ControlEvent<Void> { get }
	var authorizationButtonTap: ControlEvent<Void> { get }
}
