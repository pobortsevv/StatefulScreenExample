//
//  ProfileEditorRouter.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 25.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs

final class ProfileEditorRouter: ViewableRouter<ProfileEditorInteractable, ProfileEditorViewControllable>, ProfileEditorRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: ProfileEditorInteractable, viewController: ProfileEditorViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
