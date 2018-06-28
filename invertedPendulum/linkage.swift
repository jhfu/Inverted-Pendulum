//
//  linkage.swift
//  invertedPendulum
//
//  Created by F on 15/11/27.
//  Copyright © 2015年 F. All rights reserved.
//

import UIKit

class linkage {
    private var length: Double = 0
    private var linkWeight: Double = 0
    private var pendulumWeight: Double = 0
    private var lengthZoom:Double = 1
    private var linkWeightZoom:Double = 1
    private var pendulumWeightZoom:Double = 1
    //    var test:
    //    let A = Mat
    
    private var l=1.0,ml=1.0,mp=1.0
    private var gravityCenter = 1.0 , rotaryInertia = 1.0
    
    init(){}
    init(Length: Double, LinkWeight: Double, PendulumWeight: Double){
        length = Length
        linkWeight = LinkWeight
        pendulumWeight = PendulumWeight
        calculate()
    }
    private func calculate(){
        l = length * lengthZoom / 500
        ml = linkWeight * linkWeightZoom / 300
        mp = pendulumWeight * pendulumWeightZoom / 200
        gravityCenter = (l/2*ml+l*mp)/(ml+mp)
        rotaryInertia = ml*gravityCenter/l * square(gravityCenter) / 3
            + ml*(l-gravityCenter)/l * square(l-gravityCenter) / 3
            + mp * square(l-gravityCenter)
    }
    
    func zoomLength(times:Float){
        lengthZoom = Double(times)
        calculate()
    }
    func zoomWidth(times:Float){
        linkWeightZoom = Double(times)
        calculate()
    }
    func zoomRadius(times:Float){
        pendulumWeightZoom = Double(times)
        calculate()
    }
    
    func getLength()->(CGFloat){
        return CGFloat(length * lengthZoom)
    }
    func getWidth()->(CGFloat){
        return CGFloat(linkWeight * linkWeightZoom)
    }
    func getRadius()->(CGFloat){
        return CGFloat(pendulumWeight * pendulumWeightZoom)
    }
    func getGravityCenter()->(Double){
        return gravityCenter
    }
    func getRotaryInertia()->(Double){
        return rotaryInertia
    }
    func getMass()->(Double){
        return ml + mp
    }
    func getLengthForCalc()->(Double){
        return l
    }
}