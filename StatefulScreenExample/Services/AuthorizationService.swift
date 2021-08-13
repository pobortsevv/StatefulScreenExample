//
//  AuthorizationService.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 13.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

protocol AuthorizationService: AnyObject{
	func profile(_ completion: @escaping (Result<Profile, Error>) -> Void)
}
