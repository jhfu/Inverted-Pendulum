//
//  twoOrderInvertedPendulum.swift
//  invertedPendulum
//
//  Created by F on 15/11/25.
//  Copyright © 2015年 F. All rights reserved.
//

import Foundation
import UIKit

let gravity = 9.8
let carMass = 1.0
let c0 = 20.0, c1 = 0.0071 * 0.1, c2 = 0.0071 * 0.1


class twoOrderInvertedPendulum {

    private var _angle1:Double = 0.0
    private var _angle2:Double = 0.0
    private var _angle1Speed = 0.0, _angle2Speed = 0.0
    private var _carPosition = 0.0 , _carSpeed = 0.0
    
    private var _simulationStep:Double = 1
    private var _kpCar=1.0,_kdCar=1.0,_kpAngle1=1.0,_kdAngle1=1.0, _kpAngle2=1.0,_kdAngle2=1.0
    private var _disturbance = 0.0
    private var drivingForce = 0.0

    
    private var m0 = carMass, m1=linkage1Data.getMass(), m2=linkage2Data.getMass(),l1=linkage1Data.getGravityCenter(),L1=linkage1Data.getLengthForCalc(),l2=linkage2Data.getGravityCenter(),J1=linkage1Data.getRotaryInertia(),J2=linkage2Data.getRotaryInertia(),g=gravity
    
    private var MMatrix = [Double](count : 9, repeatedValue : 0.0)
    private var MInvMatrix = [Double](count : 9, repeatedValue : 0.0)
    private var NMInvMatrix = [Double](count : 9, repeatedValue : 0.0)
    private var CMatrix = [c0,0.0,    0,c1+c2,0,    0,0,c2]
    private var GMatrix = [0.0 ,0 ,0]
    private var FMatrix = [0.0, 0, 0]
    
    private var dotx1 = [0.0, 0, 0],x1=[0.0, 0, 0], dotx2 = [0.0, 0, 0] ,x2=[0.0, 0, 0]
    
    private var temp33 = [Double](count : 9, repeatedValue : 0.0)
    private var temp31 = [0.0, 0, 0]
    
    func updateModelParameters(){
        m0 = carMass;m1=linkage1Data.getMass(); m2=linkage2Data.getMass();l1=linkage1Data.getGravityCenter();L1=linkage1Data.getLengthForCalc();l2=linkage2Data.getGravityCenter();J1=linkage1Data.getRotaryInertia();J2=linkage2Data.getRotaryInertia();
    }
    
    private func fourOrderRungeKutta(){
        var x0 = [0.0, 0, 0,  0, 0, 0]
        x0[0] = x1[0]
        x0[1] = x1[1]
        x0[2] = x1[2]
        x0[3] = x2[0]
        x0[4] = x2[1]
        x0[5] = x2[2]
        var k = [[0.0, 0, 0,  0, 0, 0],[0.0, 0, 0,  0, 0, 0],[0.0, 0, 0,  0, 0, 0],[0.0, 0, 0,  0, 0, 0]]
        
        dif()
        k[0][0] = dotx1[0]
        k[0][1] = dotx1[1]
        k[0][2] = dotx1[2]
        k[0][3] = dotx2[0]
        k[0][4] = dotx2[1]
        k[0][5] = dotx2[2]
        
        
        for i in 0..<3{     x1[i] = x0[i] + k[0][i] * _simulationStep / 2   }
        for i in 3..<6{     x2[i-3] = x0[i] + k[0][i] * _simulationStep / 2 }
        dif()
        k[1][0] = dotx1[0]
        k[1][1] = dotx1[1]
        k[1][2] = dotx1[2]
        k[1][3] = dotx2[0]
        k[1][4] = dotx2[1]
        k[1][5] = dotx2[2]
        
        for i in 0..<3{
            x1[i] = x0[i] + k[1][i] * _simulationStep / 2
        }
        for i in 3..<6{
            x2[i-3] = x0[i] + k[1][i] * _simulationStep / 2
        }
        dif()
        k[2][0] = dotx1[0]
        k[2][1] = dotx1[1]
        k[2][2] = dotx1[2]
        k[2][3] = dotx2[0]
        k[2][4] = dotx2[1]
        k[2][5] = dotx2[2]
        
        for i in 0..<3{
            x1[i] = x0[i] + k[2][i] * _simulationStep
        }
        for i in 3..<6{
            x2[i-3] = x0[i] + k[2][i] * _simulationStep
        }
        dif()
        k[3][0] = dotx1[0]
        k[3][1] = dotx1[1]
        k[3][2] = dotx1[2]
        k[3][3] = dotx2[0]
        k[3][4] = dotx2[1]
        k[3][5] = dotx2[2]
        
        for i in 0..<3{
            x1[i] = x0[i] + (k[0][i]+2*k[1][i]+2*k[2][i]+k[3][i])*_simulationStep/6;
        }
        for i in 3..<6{
            x2[i-3] = x0[i] + (k[0][i]+2*k[1][i]+2*k[2][i]+k[3][i])*_simulationStep/6;
        }
        
    }
    private func dif(){
        calculateMatrix()
        dotx1[0] = x2[0]
        dotx1[1] = x2[1]
        dotx1[2] = x2[2]
        matrixMultiply(NMInvMatrix, B: CMatrix, result: &temp33, M: 3, N: 3, P: 3)
        matrixMultiply(temp33, B: x2, result: &dotx2, M: 3, N: 3, P: 1)
        matrixMultiply(NMInvMatrix, B: GMatrix, result: &temp31, M: 3, N: 3, P: 1)
        dotx2[0] += temp31[0]
        dotx2[1] += temp31[1]
        dotx2[2] += temp31[2]
        matrixMultiply(MInvMatrix, B: FMatrix, result: &temp31, M: 3, N: 3, P: 1)
        dotx2[0] += temp31[0]
        dotx2[1] += temp31[1]
        dotx2[2] += temp31[2]

    }
    
//    private func EulerMethod(){
//        dif()
//        for i in 0..<3{
//            x1[i] += dotx1[i] * _simulationStep
//            x2[i] += dotx2[i] * _simulationStep
//        }
//    }
    
    
    private func calculateMatrix(){
        MMatrix[0] = m0+m1+m2
        MMatrix[1] = (m1*l1 + m2*L1) * cos(x1[1])
        MMatrix[2] = m2*l2*cos(x1[2])
        MMatrix[3] = MMatrix[1]
        MMatrix[4] = J1+m1*square(l1)+m2*square(L1)
        MMatrix[5] = m2*L1*l2*cos(x1[1]-x1[2])
        MMatrix[6] = MMatrix[2]
        MMatrix[7] = MMatrix[5]
        MMatrix[8] = J2+m2*square(l2)
        invert3OrderMatrix(MMatrix, positiveTarget: &MInvMatrix, negativeTarget: &NMInvMatrix)
        
        //        CMatrix[0] = c0
        CMatrix[1] = -(m1*l1+m2*L1)*sin(x1[1])*x2[1]
        CMatrix[2] = -m2*l2*sin(x1[2])*x2[2]
        //        CMatrix[3] = 0
        //        CMatrix[4] = c1+c2
        CMatrix[5] = m2*L1*l2*sin(x1[1]-x1[2])*x2[2]-c2
        //        CMatrix[6] = 0
        CMatrix[7] = -m2*L1*l2*sin(x1[1]-x1[2])*x2[1]-c2
        //        CMatrix[8] = c2
        
        GMatrix[1] = -(m1*l1+m2*L1)*g*sin(x1[1])
        GMatrix[2] = -m2*g*l2*sin(x1[2])
        FMatrix[0] = _disturbance + drivingForce
    }
    
 
    
    init(SimulationStep:Double){
        _simulationStep = SimulationStep
    }
    func setDisturbance(Disturbance:Double?){
        _disturbance = Disturbance!
    }
    func setControllerParameters(KpCar1:Float, KdCar1:Float,KpAngle1:Float, KdAngle1:Float,KpAngle2:Float, KdAngle2:Float){
        _kpCar = Double( KpCar1 )
        _kdCar = Double( KdCar1 )
        _kpAngle1 = Double( KpAngle1 )
        _kdAngle1 = Double( KdAngle1 )
        _kpAngle2 = Double( KpAngle2 )
        _kdAngle2 = Double( KdAngle2 )
    }
    func updateController()->(Double){
        if ((abs(_angle1) > M_PI_4) || (abs(_angle2) > M_PI_4 )){
            drivingForce = -(_carPosition*10*_kpCar * 10
                + 0.814*_carSpeed*_kdCar/_simulationStep/100 )
        }else{
            drivingForce = -((_carPosition*10*_kpCar - 479*_angle1*_kpAngle1 + 648*_angle2*_kpAngle2) * 10
                + (0.814*_carSpeed*_kdCar - 24.7*_angle1Speed*_kdAngle1 + 95*_angle2Speed*_kdAngle2)/_simulationStep/100 )
        }
        drivingForce = insertIn(drivingForce,min: -50.0,max: 50.0)
        return drivingForce
    }
    func reset(){
        _carPosition = 0
        _carSpeed = 0
        _angle1 = 0
        _angle1Speed = 0
        _angle2 = 0
        _angle2Speed = 0
        
        dotx1 = [0.0, 0, 0]
        x1=[0.0, 0, 0]
        dotx2 = [0.0, 0, 0]
        x2=[0.0, 0, 0]
        
    }
    
    func simulation()->(CGFloat,CGFloat ,CGFloat){
//        EulerMethod()
        fourOrderRungeKutta()
        _carPosition = x1[0]
        _angle1 = insertInPi(x1[1])
        _angle2 = insertInPi(x1[2])
        if _angle1-_angle2>1.8*M_PI {
            _angle1-=2*M_PI
        }else if _angle2-_angle1>1.8*M_PI {
            _angle1+=2*M_PI
        }
        _carSpeed = x2[0]
        _angle1Speed = x2[1]
        _angle2Speed = x2[2]
        
        return(CGFloat(_carPosition*100),CGFloat(_angle1),CGFloat(_angle2))
    }

}
