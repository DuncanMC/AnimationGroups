//
//  ViewController.swift
//  AnimationGroups
//
//  Created by Duncan Champney on 9/2/20.
//  Based on a Stack Overflow post by Matt Neuburg @ https://stackoverflow.com/a/63710424/205185
//  Where he demonstrated a technique for using CAAnimationGroup objects to animate multiple CALayers.

import UIKit

class ViewController: UIViewController {


    let imageWidth: CGFloat = 50.0
    let imageHeight: CGFloat = 80.0
    var feetYPosition: CGFloat = 0
    let stepDuration = 0.25

    @IBOutlet weak var animateButton: UIButton!
    let leftfoot = CALayer()
    let rightfoot = CALayer()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        setup()
    }

    @IBAction func handleAnimateButton(_ sender: UIButton) {
        animateButton.isEnabled = false
        start()
    }

    func setup() {
        let left = (view.bounds.size.width - (imageWidth * 2 + 20)) / 2.0
        self.leftfoot.name = "left"
        self.leftfoot.contents = UIImage(named:"leftfoot")!.cgImage
        self.leftfoot.frame = CGRect(x: left, y: animateButton.frame.origin.y - (imageHeight + 10), width: imageWidth, height: imageHeight)
        self.view.layer.addSublayer(self.leftfoot)
        feetYPosition = self.leftfoot.position.y

        self.rightfoot.name = "right"
        self.rightfoot.contents = UIImage(named:"rightfoot")!.cgImage
        self.rightfoot.frame = CGRect(x: left + imageWidth + 20, y: animateButton.frame.origin.y - (imageHeight + 10), width: imageWidth, height: imageHeight)
        self.view.layer.addSublayer(self.rightfoot)

    }

    func start() {
        //Figure out how many pairs of steps will fit vertically on the screen
        let animationYRange = animateButton.frame.origin.y - (imageHeight * 2 + 10)
        let stepPairs = Int(animationYRange / (imageHeight * 2))

        guard stepPairs > 0 else {
            self.animateButton.isEnabled = true
            return

        }
        var stepStart = 0.0
        let firstLeftStep = CABasicAnimation(keyPath: "sublayers.left.position.y")

        firstLeftStep.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        //Make the first step half as far as the remaining.
        firstLeftStep.byValue = -imageHeight

        firstLeftStep.duration = stepDuration
        firstLeftStep.fillMode = .forwards

        func rightStepAfter(_ t: Double) -> CABasicAnimation {
            let rightStep = CABasicAnimation(keyPath: "sublayers.right.position.y")
            rightStep.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            rightStep.byValue = -(imageHeight * 2)
            rightStep.beginTime = t
            rightStep.duration = stepDuration
            rightStep.fillMode = .forwards
            return rightStep
        }
        func leftStepAfter(_ t: Double) -> CABasicAnimation {
            let leftStep = CABasicAnimation(keyPath: "sublayers.left.position.y")
            leftStep.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            leftStep.byValue = -(imageHeight * 2)
            leftStep.beginTime = t
            leftStep.duration = stepDuration
            leftStep.fillMode = .forwards
            return leftStep
        }

        let group = CAAnimationGroup()
        group.duration = (Double(stepPairs) * 2.0 + 1) * stepDuration

        //Leave the animation group animation active once complete.
        //(That way we can easily add another animation to return the feet to their
        //original locations.)
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false

        stepStart += stepDuration
        group.animations = [firstLeftStep]
        for _ in 1...stepPairs {
            group.animations?.append(rightStepAfter(stepStart))
            stepStart += stepDuration
            group.animations?.append(leftStepAfter(stepStart))
            stepStart += stepDuration
        }

        //Define a completion block to run when the animation is finished
        let animationCompletion: AnimationCompletion = { finished in
            guard finished else { return }
            self.doFinishAnimation()
        }

        //Attach a completion block to the animation
        group.setValue(animationCompletion, forKey: animationCompletionKey)
        group.delegate = self

        self.view.layer.add(group, forKey: nil)
    }

    func doFinishAnimation() {

        //Create another animation group to animate both image layers back to their starting position
        let group = CAAnimationGroup()
        group.duration = stepDuration * 2

        //Have the return animation begin after a short pause
        group.beginTime = CACurrentMediaTime() + 0.2
        group.fillMode = .forwards

        //Animate the right foot back to its original position
        let rightStep = CABasicAnimation(keyPath: "sublayers.right.position.y")
        rightStep.fillMode = .forwards
        rightStep.toValue = feetYPosition
        rightStep.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        rightStep.duration = stepDuration * 2
        group.animations = [rightStep]

        //Animate the left foot back to its original position at the same time
        let leftStep = CABasicAnimation(keyPath: "sublayers.left.position.y")
        leftStep.fillMode = .forwards
        leftStep.toValue = feetYPosition
        leftStep.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        leftStep.duration = stepDuration * 2

        //In the completion block, remove all animations and re-enable the animate button.
        let animationCompletion: AnimationCompletion = { finished in
            guard finished else { return }
            self.view.layer.removeAllAnimations()
            self.animateButton.isEnabled = true
        }

        group.animations?.append(leftStep)
        group.delegate = self

        //Attach a completion block to the group animation
        group.setValue(animationCompletion, forKey: animationCompletionKey)

        self.view.layer.add(group, forKey: nil)
    }
}
