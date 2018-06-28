//
//  myView.swift
//  invertedPendulum
//
//  Created by F on 15/11/25.
//  Copyright © 2015年 F. All rights reserved.
//

import UIKit



class myView: UIView {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
//    let beginX:CGFloat = 50.0,beginY:CGFloat = 480.0
    
    var oscilloscopeCurveAngle1 = OscilloscopeCurve()
    var oscilloscopeCurveAngle2 = OscilloscopeCurve()
    var oscilloscopeCurveMotor = OscilloscopeCurve()
//    var oscilloscopeCurveCarPosition = OscilloscopeCurve()

    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        oscilloscopeCurveAngle1.drawAxis(context!)
        oscilloscopeCurveAngle1.updateCurve(context!)
        oscilloscopeCurveAngle2.updateCurve(context!)
        oscilloscopeCurveMotor.updateCurve(context!)
//        oscilloscopeCurveCarPosition.updateCurve(context!)

    }
}