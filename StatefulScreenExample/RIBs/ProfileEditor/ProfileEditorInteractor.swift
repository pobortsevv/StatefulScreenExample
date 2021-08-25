//
//  ProfileEditorInteractor.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 25.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift



final class ProfileEditorInteractor: PresentableInteractor<ProfileEditorPresentable>, ProfileEditorInteractable {
	weak var router: ProfileEditorRouting?
	
	private let profileProvider: AuthorizationProfileProvider

	// MARK: Internals
	
	private let _state = BehaviorRelay<ProfileEditorInteractorState>(value: .userInput)
	
	private let _screenDataModel: BehaviorRelay<ProfileEditorScreenDataModel>
	
	private let responses = Responses()
	
	private let disposeBag = DisposeBag()
	
	init(presenter: ProfileEditorPresentable,
			 profileProvider: AuthorizationProfileProvider) {
		self.profileProvider = profileProvider
		_screenDataModel = BehaviorRelay(value: ProfileEditorScreenDataModel())
		super.init(presenter: presenter)
	}
	
	private func updateProfile(profile: Profile) {
		//
	}
}

// MARK: - IOTransformer

extension ProfileEditorInteractor: IOTransformer {
	func transform(input viewOutput: ProfileEditorViewOutput) -> ProfileEditorInteractorOutput {
		let trait = StateTransformTrait(_state: _state, disposeBag: disposeBag)
		
		let requests = makeRequests()
		
		StateTransform.transform(trait: trait, viewOutput: viewOutput, response: responses, requests: requests, screenDataModel: _screenDataModel, disposeBag: disposeBag)
		
		return ProfileEditorInteractorOutput(state: trait.readOnlyState,
																				 screenDataModel: _screenDataModel.asObservable())
	}
}

extension ProfileEditorInteractor {
	private typealias State = ProfileEditorInteractorState
	
	/// State-Машина
	private enum StateTransform: StateTransformer {
		// Case .UserInput
		static let byUserInputState: (State) -> Bool = { state -> Bool in
			guard case .userInput = state else { return false }; return true
		}
		
		// Case .UpdatingProfile
		//
		
		static func transform(trait: StateTransformTrait<State>,
													viewOutput: ProfileEditorViewOutput,
													response: Responses,
													requests: Requests,
													screenDataModel: BehaviorRelay<ProfileEditorScreenDataModel>,
													disposeBag: DisposeBag) {
//			StateTransform.transitions {}.bindToAndDisposedBy(trait: trait)
			updateScreenDataModel(screenDataModel: screenDataModel, disposeBag: disposeBag)
		}
		
		static func updateScreenDataModel(screenDataModel: BehaviorRelay<ProfileEditorScreenDataModel>,
																			disposeBag: DisposeBag) {
			//let readOnlyScreenDataModel = screenDataModel.asObservable()
			
			//
		}
	}
}

// MARK: - Help Methods

extension ProfileEditorInteractor {
	private func makeRequests() -> Requests {
		Requests(updateProfile: { [weak self] profile in self?.updateProfile(profile: profile) })
	}
}


// MARK: - Nested Types

extension ProfileEditorInteractor {
	private struct Responses {
		@PublishObservable var profileUpdated: Observable<Bool>
		@PublishObservable var updationError: Observable<Error>
	}
	
	private struct Requests {
		let updateProfile: (_ profile: Profile) -> Void
	}
}
