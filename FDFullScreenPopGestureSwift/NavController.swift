//
//  NavController.swift
//  FDFullScreenPopGestureSwift
//
//  Created by MinLison on 2017/4/10.
//  Copyright © 2017年 MinLiSon. All rights reserved.
//

import UIKit

class NavController: UINavigationController {
	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		fd_pushViewController(viewController, animated: animated)
		super.pushViewController(viewController, animated: animated)
	}
}
