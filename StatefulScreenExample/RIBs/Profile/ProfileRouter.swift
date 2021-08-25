//
//  ProfileRouter.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift

final class ProfileRouter: ViewableRouter<ProfileInteractable, ProfileViewControllable>, ProfileRouting {
	
	private let profileEditorBuilder: ProfileEditorBuildable
	private let disposeBag = DisposeBag()
	
  init(interactor: ProfileInteractable,
			 viewController: ProfileViewControllable,
			 profileEditorBuilder: ProfileEditorBuildable) {
		self.profileEditorBuilder = profileEditorBuilder
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }
  
	func routeToEdit(profile: Profile) {
		let router = profileEditorBuilder.build()
		attachChild(router)
		
		viewController.uiviewController.navigationController?.pushViewController(router.viewControllable.uiviewController, animated: true)
	
		detachWhenClosed(child: router, disposedBy: DisposeBag())
	}
	
  func routeToEmailChange() {
    showStubAlert(title: "Смена e-mail")
  }
  
  func routeToEmailAddition() {
    showStubAlert(title: "Добавление e-mail")
  }
  
  func routeToOrdersList() {
    showStubAlert(title: "Список заказов")
  }
  
  private func showStubAlert(title: String) {
    let message = "Вместо этого сообщения в боевом проекте производится роутинг на нужный экран"
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    
    viewController.uiviewController.present(alert, animated: true, completion: nil)
  }
}
