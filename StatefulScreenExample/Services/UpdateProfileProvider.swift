//
//  UpdateAuthorizationProvider.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 13.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

protocol UpdateProfileProvider: AnyObject {
	var profile: Profile { get }
	
	func updateProfile(_ profile: Profile, completion: @escaping (Result<Void, Error>) -> Void)
}
