//
//  AuthorizationProvider.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 17.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

protocol AuthorizationProfileProvider: AnyObject {
	func checkNumber(_ number: String?, completion: @escaping (Result<Void, Error>) -> Void)
}
