//
//  ProfileService.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RxCocoa
import RxSwift

protocol ProfileService: AnyObject {
	var profileEdited: Observable<Profile> { get }
  func profile(_ completion: @escaping (Result<Profile, Error>) -> Void)
}

struct Profile {
	var firstName: String?
	var lastName: String?
	var email: String?
	let phone: String
	var authorized: Bool
}

extension Profile: Decodable {}
