//
//  UpdateProfileProviderImp.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 13.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import Foundation

final class ProfileProviderImp: UpdateProfileProvider, AuthorizationProfileProvider {
	private(set) var profile = Profile(firstName: "Иван", lastName: nil, email: nil, phone: "79991235467")
	
	func updateProfile(_ profile: Profile, completion: @escaping (Result<Void, Error>) -> Void) {
		DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + .random(in: 0.5...2)) { [weak self] in
		let isSuccess = Bool.random()
		let result: Result<Void, Error>
		switch isSuccess {
		case false:
			result = .failure(NetworkError())
		case true:
			result = .success(Void())
			self?.profile = profile
		}
		completion(result)

		}
	}
	
	func checkNumber(_ number: String?, completion: @escaping (Result<String, Error>) -> Void) {
		DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + .random(in: 0.5...2)) {
			let isSuccess = Bool.random()
			let result: Result<String, Error>
			switch isSuccess {
			case false:
				result = .failure(NetworkError())
			case true:
				result = .success("".randomCode())
			}
		completion(result)
			print(result)
		}
	}
}



struct NetworkError: LocalizedError {
	var errorDescription: String? { "Произошла сетевая ошибка" }
}
