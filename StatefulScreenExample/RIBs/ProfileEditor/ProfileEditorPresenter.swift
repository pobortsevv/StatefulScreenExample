//
//  ProfileEditorPresenter.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 25.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

final class ProfileEditorPresenter: ProfileEditorPresentable {}

// MARK: - IOTransformer

extension ProfileEditorPresenter: IOTransformer {
	func transform(input: ProfileEditorInteractorOutput) -> ProfileEditorPresenterOutput {
		//
		
		return ProfileEditorPresenterOutput()
	}
}
