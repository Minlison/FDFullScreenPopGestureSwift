# FDFullScreenPopGestureSwift
FDFullScreenPopGesture Swift 版本

## 仿 [FDFullScreenPopGesture](https://github.com/forkingdog/FDFullscreenPopGesture.git) 的 Swift 版本.

## 因为 Swift 对 method swizzle 支持不友好, 因此,在该版本中, 使用了 protocol 方法,需要主动调用.

```

class BaseViewController : UIViewController  {
	override func viewWillAppear(_ animated: Bool) {
		fd_viewWillAppear(animated)
	}
}

class BaseNavController: UINavigationController {
	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		fd_pushViewController(viewController, animated: animated)
		super.pushViewController(viewController, animated: animated)
	}
}

```
如果要使用  FDFullScreenPopGestureSwift 需要在基类里面, 实现上面的两个方法.

感谢 [FDFullScreenPopGesture](https://github.com/forkingdog/FDFullscreenPopGesture.git)