//
//  mathSupport.swift
//  invertedPendulum
//
//  Created by F on 15/11/26.
//  Copyright © 2015年 F. All rights reserved.
//

import Accelerate

func square(x:Double)->(Double){
    return x * x
}
func invert3OrderMatrix(source:UnsafePointer<Double>,positiveTarget:UnsafeMutablePointer<Double>,negativeTarget:UnsafeMutablePointer<Double> ){
    let a=source[0],b=source[1],c=source[2],d=source[3],e=source[4],f=source[5],g=source[6],h=source[7],i=source[8]
    let det:Double = a*e*i - a*f*h - b*d*i + b*f*g + c*d*h - c*e*g
    positiveTarget[0] = (e*i - f*h) / det
    positiveTarget[1] = (c*h - b*i) / det
    positiveTarget[2] = (b*f - c*e) / det
    positiveTarget[3] = (f*g - d*i) / det
    positiveTarget[4] = (a*i - c*g) / det
    positiveTarget[5] = (c*d - a*f) / det
    positiveTarget[6] = (d*h - e*g) / det
    positiveTarget[7] = (b*g - a*h) / det
    positiveTarget[8] = (a*e - b*d) / det
    for i in 0..<9{
        negativeTarget[i] = -positiveTarget[i]
    }
}

func matrixMultiply(A: UnsafePointer<Double>,B: UnsafePointer<Double>,result: UnsafeMutablePointer<Double>,M: vDSP_Length,N: vDSP_Length,P: vDSP_Length){
    vDSP_mmulD(A, 1, B, 1, result, 1, M, P, N)
}

func matrixAdd(A: UnsafePointer<Double>, B: UnsafePointer<Double>, result: UnsafeMutablePointer<Double>,N: vDSP_Length){
    vDSP_vaddD(A, 1, B, 1, result, 1,N )
}
//func insertInPi(var x:Double)->(Double){
//    while x > M_PI{
//        x -= 2 * M_PI
//    }
//    while x < -M_PI{
//        x += 2 * M_PI
//    }
//    return x
//}
func insertInPi(var x:Double)->(Double){
    while x > 2*M_PI{
        x -= 4 * M_PI
    }
    while x < -2*M_PI{
        x += 4 * M_PI
    }
    return x
}

func insertIn(x:Double,min:Double,max:Double)->(Double){
    if x<min{
        return min
    }
    else if x>max{
        return max
    }
    return x
}


