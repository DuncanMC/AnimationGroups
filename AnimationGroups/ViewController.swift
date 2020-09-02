//
//  ViewController.swift
//  AnimationGroups
//
//  Created by Duncan Champney on 9/2/20.
//  Copyright © 2020 Duncan Champney. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CAAnimationDelegate {

    let imageWidth: CGFloat = 50.0
    let imageHeight: CGFloat = 80.0

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

        self.rightfoot.name = "right"
        self.rightfoot.contents = UIImage(named:"rightfoot")!.cgImage
        self.rightfoot.frame = CGRect(x: left + imageWidth + 20, y: animateButton.frame.origin.y - (imageHeight + 10), width: imageWidth, height: imageHeight)
        self.view.layer.addSublayer(self.rightfoot)

    }

    func start() {
        let stepDuration = 1.0


        //Figure out how many pairs of steps will fit vertically on the screen
        let animationYRange = animateButton.frame.origin.y - (imageHeight * 2 + 10)
        let stepPairs = Int(animationYRange / (imageHeight * 2))

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
        stepStart += stepDuration
        group.animations = [firstLeftStep]
        for _ in 1...stepPairs {
            group.animations?.append(rightStepAfter(stepStart))
            stepStart += stepDuration
            group.animations?.append(leftStepAfter(stepStart))
            stepStart += stepDuration
        }
        group.delegate = self
        self.view.layer.add(group, forKey: nil)
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.rightfoot.removeFromSuperlayer()
        self.leftfoot.removeFromSuperlayer()
        setup()
        animateButton.isEnabled = true
    }

}
