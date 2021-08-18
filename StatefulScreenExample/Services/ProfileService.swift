//
//  ProfileService.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

protocol ProfileService: AnyObject {
  func profile(_ completion: @escaping (Result<Profile, Error>) -> Void)
  
  func updateEmail(_ newEmail: String, completion: @escaping (Result<Void, Error>) -> Void)
}

struct Profile {
	var firstName: String?
	var lastName: String?
	var email: String?
	let phone: String
}

extension Profile: Decodable {}
