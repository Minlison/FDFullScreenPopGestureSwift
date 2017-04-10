//
//  FDFullScreenPopGestureSwift.swift
//  FDFullScreenPopGestureSwift
//
//  Created by MinLison on 2017/4/10.
//  Copyright © 2017年 MinLiSon. All rights reserved.
//

import UIKit
/// runtime key
fileprivate struct RuntimeKey {
	static let fullscreenPopGestureKey = UnsafeRawPointer.init(bitPattern: "fullscreenPopGestureKey".hashValue)
	static let viewControllerBasedNavigationBarAppearanceEnabledKey = UnsafeRawPointer.init(bitPattern: "viewControllerBasedNavigationBarAppearanceEnabledKey".hashValue)
	static let interactivePopDisabledKey = UnsafeRawPointer.init(bitPattern: "interactivePopDisabledKey".hashValue)
	static let prefersNavigationBarHiddenKey = UnsafeRawPointer.init(bitPattern: "prefersNavigationBarHiddenKey".hashValue)
	static let interactivePopMaxAllowedInitialDistanceToLeftEdgeKey = UnsafeRawPointer.init(bitPattern: "interactivePopMaxAllowedInitialDistanceToLeftEdg".hashValue)
	static let willAppearInjectBlockKey = UnsafeRawPointer.init(bitPattern: "willAppearInjectBlockKey".hashValue)
	static let popGestureRecognizerDelegateKey = UnsafeRawPointer.init(bitPattern: "popGestureRecognizerDelegateKey".hashValue)
}

// 替换 FDFullScreenPopGesture 原有的 method_change 方法
protocol FDFullScreenPopGestureNav {
	func fd_pushViewController(_ viewController: UIViewController, animated: Bool)
}
// 替换 FDFullScreenPopGesture 原有的 method_change 方法
protocol FDFullScreenPopGestureVC {
	func fd_viewWillAppear(_ animation: Bool)
}
// 替换 FDFullScreenPopGesture 原有的 method_change 方法
protocol FDFullScreenPopGestureSwift : FDFullScreenPopGestureNav, FDFullScreenPopGestureVC{}

extension UINavigationController : UIGestureRecognizerDelegate, FDFullScreenPopGestureNav  {
	
	/// The gesture recognizer that actually handles interactive pop.
	
	var fullscreenPopGestureRecognizer : UIPanGestureRecognizer {
		
		guard let obj = objc_getAssociatedObject(self, RuntimeKey.fullscreenPopGestureKey) as? UIPanGestureRecognizer else {
			
			let gesture = UIPanGestureRecognizer()
			gesture.maximumNumberOfTouches = 1
			objc_setAssociatedObject(self, RuntimeKey.fullscreenPopGestureKey, gesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			
			return gesture
		}
		
		return obj
	}
	
	/// A view controller is able to control navigation bar's appearance by itself,
	/// rather than a global way, checking "fd_prefersNavigationBarHidden" property.
	/// Default to YES, disable it if you don't want so.
	var viewControllerBasedNavigationBarAppearanceEnabled : Bool {
		get {
			guard let obj = objc_getAssociatedObject(self, RuntimeKey.viewControllerBasedNavigationBarAppearanceEnabledKey) as? Bool else {
				self.viewControllerBasedNavigationBarAppearanceEnabled = true
				return true
			}
			return obj
		}
		set {
			objc_setAssociatedObject(self, RuntimeKey.viewControllerBasedNavigationBarAppearanceEnabledKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
		}
	}
	
	
	private var popGestureRecognizerDelegate: FullscreenPopGestureRecognizerDelegate {
		get {
			guard let obj = objc_getAssociatedObject(self, RuntimeKey.popGestureRecognizerDelegateKey) as? FullscreenPopGestureRecognizerDelegate else {
				let newValue = FullscreenPopGestureRecognizerDelegate()
				newValue.navigationController = self
				objc_setAssociatedObject(self, RuntimeKey.popGestureRecognizerDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
				return newValue
			}
			return obj
		}
	}
	
	/// MARK: - Must call
	func fd_pushViewController(_ viewController: UIViewController, animated: Bool) {
		if interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(fullscreenPopGestureRecognizer) == false {
			
			interactivePopGestureRecognizer?.view?.addGestureRecognizer(fullscreenPopGestureRecognizer)
			
			let internalTargets = interactivePopGestureRecognizer?.value(forKey: "targets") as? Array<NSObject>
			let internalTarget = internalTargets?.first?.value(forKey: "target")
			let internalAction = NSSelectorFromString("handleNavigationTransition:")
			if internalTarget != nil  {
				fullscreenPopGestureRecognizer.delegate = popGestureRecognizerDelegate
				fullscreenPopGestureRecognizer.addTarget(internalTarget!, action: internalAction)
				interactivePopGestureRecognizer?.isEnabled = false
			}
		}
		
		setupViewControllerBasedNavigationBarAppearanceIfNeeded(viewController)
	}
	
	func setupViewControllerBasedNavigationBarAppearanceIfNeeded(_ appearingVC: UIViewController) {
		if !viewControllerBasedNavigationBarAppearanceEnabled {
			return
		}
		let block : FDViewControllerWillAppearInjectBlock = { [weak self] (vc:UIViewController,animation:Bool) in
			self?.setNavigationBarHidden(vc.prefersNavigationBarHidden, animated: animation)
		}
		appearingVC.willAppearInjectBlock = block
		let disappearVC = viewControllers.last
		if disappearVC != nil && disappearVC?.willAppearInjectBlock != nil {
			disappearVC?.willAppearInjectBlock = block
		}
	}

}

extension UIViewController : FDFullScreenPopGestureVC {
	
	// 替换 FDFullScreenPopGesture 原有的 method_change 方法
	func fd_viewWillAppear(_ animation: Bool) {
		if willAppearInjectBlock != nil {
			willAppearInjectBlock!(self,animation)
		}
	}

	
	/// Whether the interactive pop gesture is disabled when contained in a navigation
	/// stack.
	var interactivePopDisabled : Bool {
		get {
			guard let obj = objc_getAssociatedObject(self, RuntimeKey.interactivePopDisabledKey) as? Bool else {
				return false
			}
			return obj
		}
		set {
			objc_setAssociatedObject(self, RuntimeKey.interactivePopDisabledKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
		}
	}
	
	/// Indicate this view controller prefers its navigation bar hidden or not,
	/// checked when view controller based navigation bar's appearance is enabled.
	/// Default to NO, bars are more likely to show.
	var prefersNavigationBarHidden : Bool {
		get {
			guard let obj = objc_getAssociatedObject(self, RuntimeKey.prefersNavigationBarHiddenKey) as? Bool else {
				return false
			}
			return obj
		}
		set {
			objc_setAssociatedObject(self, RuntimeKey.prefersNavigationBarHiddenKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
		}
	}
	
	/// Max allowed initial distance to left edge when you begin the interactive pop
	/// gesture. 0 by default, which means it will ignore this limit.
	var interactivePopMaxAllowedInitialDistanceToLeftEdge : Float {
		get {
			guard let obj = objc_getAssociatedObject(self, RuntimeKey.interactivePopMaxAllowedInitialDistanceToLeftEdgeKey) as? Float else {
				return 0.0
			}
			return obj
		}
		set {
			objc_setAssociatedObject(self, RuntimeKey.interactivePopMaxAllowedInitialDistanceToLeftEdgeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
		}
	}
	
	fileprivate typealias FDViewControllerWillAppearInjectBlock = (_ vc: UIViewController, _ animated: Bool) -> Void
	
	fileprivate var willAppearInjectBlock : FDViewControllerWillAppearInjectBlock? {
		get {
			return objc_getAssociatedObject(self, RuntimeKey.willAppearInjectBlockKey) as? FDViewControllerWillAppearInjectBlock
		}
		set {
			if let newValue = newValue {
				objc_setAssociatedObject(self, RuntimeKey.willAppearInjectBlockKey, newValue, .OBJC_ASSOCIATION_COPY)
			}
		}
	}
}

private class FullscreenPopGestureRecognizerDelegate : NSObject, UIGestureRecognizerDelegate {
	
	var navigationController : UINavigationController?
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		
		guard let navigationController = navigationController else {
			return false
		}
		
		guard navigationController.viewControllers.count > 1, let topViewController = navigationController.viewControllers.last else {
			return false
		}
		
		guard topViewController.interactivePopDisabled == false else {
			return false
		}
		
		let beginingLocation = gestureRecognizer.location(in: gestureRecognizer.view)
		let maxAllowedInitialDistance = topViewController.interactivePopMaxAllowedInitialDistanceToLeftEdge;
		
		if maxAllowedInitialDistance > 0 && Float(beginingLocation.x) > maxAllowedInitialDistance {
			return false
		}
		
		guard let trasition = navigationController.value(forKey: "_isTransitioning") as? Bool else {
			return false
		}
		
		guard trasition == false, let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
			return false
		}
		
		let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
		if translation.x <= 0 {
			return false
		}
		
		return true
	}
}
