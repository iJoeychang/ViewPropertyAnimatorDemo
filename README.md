UIViewPropertyAnimator 是在 iOS 10 中引入的，可以用来创建易于交互，可中断，可逆的视图动画。

在  iOS 10 之前，我们只能使用 UIView.animate(withDuration:...) 进行 view-based animations，这些 UIView  API 不能 pause 或者 stop 正在运行的动画。为了 reverse, speed up, or slow 一个动画，开发者需要使用 layer-based CAAnimation animations 。

UIViewPropertyAnimator 使得创建上述所述动画变得更容易，它是一个类，可以让我们保持运行动画、调整当前运行的动画、以及提供动画当前状态的详细信息。

下面我们来认识认识 UIViewPropertyAnimator 。

###### Basic animations

我们可以像下面这样创建一个简单的 UIViewPropertyAnimator：

```
    let scale = UIViewPropertyAnimator(duration: 0.33, curve: .easeIn)
    scale.addAnimations {
      self.tableView.alpha = 1.0
    }
    scale.addAnimations({
      self.tableView.transform = .identity
    }, delayFactor: 13.33)
    scale.addCompletion { _ in
      print("ready")
    }
    scale.startAnimation() // 这里是触发动画执行事件

```

##### Adding animations

```
scale.addAnimations({ 
       self.tableView.transform = .identity 
}, delayFactor: 0.33)
```

上面方法后一个参数是 delayFactor 而不是 delay，这是因为我们不提供延迟以秒为单位的绝对值，而是提供 animator 剩余持续时间的一个延迟时间计算公式（介于0.0和1.0之间）。

以上动画延迟时间计算公式（factor）：
```
delayFactor(0.33) * remainingDuration(=duration 0.33) = delay of 0.11 seconds
```

如果还没有开始动画，remainingDuration 等于 total duration。这里动画还没有开始，remainingDuration 和 total duration 都等于 0.33 秒。

想象你的 animator 已经在运行，你决定在中途添加一些新的动画。 在这种情况下，剩余持续时间将不等于总持续时间，因为自启动动画以来已经过了一段时间。如图所示：

![remaining duration](https://upload-images.jianshu.io/upload_images/130752-89e70190e01c25fb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

delayFactor 可让我们根据剩余的可用时间来安排延迟动画。 此外，这可确保延迟时间不能设置为长于剩余运行时间。

![delayFactor](https://upload-images.jianshu.io/upload_images/130752-1402c69cdec8504c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###### 抽象 animations 工具类

如果你在每个需要动画 controller 中都写很多动画相关的代码，这样会让你多写出很多重复的代码，费力又不讨好。刚开始工作的时候，我老大就说，“你看你写的代码就知道你不是个老手”，因为我写的代码太乱了，不会抽取公共方法。

像这里的动画，就可以抽取一个动画类，将动画相关的代码组织在该类中，其它地方需要用，直接调用该类的方法就好了。这样可以让代码看起来简洁、舒爽（nicer, shorter, and cleaner）。

新建 AnimatorFactory.swift 类，实现如下方法：

```
import UIKit

class AnimatorFactory {

  static func scaleUp(view: UIView) -> UIViewPropertyAnimator {
    let scale = UIViewPropertyAnimator(duration: 0.33, curve: .easeIn)
    scale.addAnimations {
      view.alpha = 1.0
    }
    scale.addAnimations({
      view.transform = CGAffineTransform.identity
    }, delayFactor: 0.33)
    scale.addCompletion {_ in
      print("ready")
    }
    return scale
  }
  
  @discardableResult
  static func jiggle(view: UIView) -> UIViewPropertyAnimator {
    return UIViewPropertyAnimator.runningPropertyAnimator( withDuration: 0.33, delay: 0, animations: {
          UIView.animateKeyframes(withDuration: 1, delay: 0, animations: {
              UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {// rotates the given view to the left
                view.transform = CGAffineTransform(rotationAngle: -.pi/8)
              }
              UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.75) {// rotates it to the right
                view.transform = CGAffineTransform(rotationAngle: +.pi/8)
              }
              UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 1.0) {// brings it back home — er, I mean resets its transform.
                view.transform = CGAffineTransform.identity
              }
          }, completion: nil
            
          )
        }, completion: {_ in
            view.transform = .identity
        }
    )
  }
  
  @discardableResult
  static func fade(view: UIView, visible: Bool) -> UIViewPropertyAnimator {
    return UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
      view.alpha = visible ? 1 : 0
    }, completion: nil)
  }
}
```

当一个类方法有值返回时候，外部调用，如果没有接受方法返回的值，Xcode 将报警告，这时候添加 @discardableResult 注释，可以避免警告。


其它地方（controller）调用 工具类方法示例：

```
func iconJiggle() { 
    AnimatorFactory.jiggle(view: icon) 
}

func toggleBlur(_ blurred: Bool) { 
    AnimatorFactory.fade(view: blurView, visible: blurred) 
}
```


###### 防止重叠动画

```
func iconJiggle() {
    if let animator = animator, animator.isRunning {
      return
    }
    animator = AnimatorFactory.jiggle(view: icon)
}
```
在 iconJiggle() 方法的开头检查是否设置了 animator ，如果是，检查它是否正在运行（isRunning）。 如果动画正在运行中，动画还没结束，你再次点击 icon ，动画又重新开始，如果我们希望每次动画可以完整执行完毕后再次动画，这时可以添加过滤条件：如果动画正在执行，再次点击， iconJiggle() 方法直接 return 掉。以此达到防止重叠动画。

最终效果：

![UIViewPropertyAnimator](https://upload-images.jianshu.io/upload_images/130752-e4561d022bd202c0.gif?imageMogr2/auto-orient/strip)

