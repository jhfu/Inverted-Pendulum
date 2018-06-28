//
//  OscilloscopeCurve.swift
//  invertedPendulum
//
//  Created by F on 15/11/28.
//  Copyright © 2015年 F. All rights reserved.
//

import UIKit

class OscilloscopeCurve: UIView {
    
    private let dataLengthMax = 360
    private let dataYScale:CGFloat = 65
    
    private var beginXx:CGFloat = 50.0,beginYy:CGFloat = 480.0
    private var data:Array<CGFloat> = [0.0 ,0.0]
    private var dataMax:CGFloat = 0.0001 ,dataMaxIndex = 1
    private var dataQueueFull = false
    
    private var color = Color()
    
    func setCurveColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat){
        color.red = red
        color.green = green
        color.blue = blue
        color.alphe = alpha
    }
    
    func setPosition(x:Double,y:Double){
        beginXx = CGFloat(x)
        beginYy = CGFloat(y)
    }
    
    
    func getData(newData:CGFloat){
        data.append(newData)
        if dataQueueFull{
            data.removeFirst()
            dataMaxIndex--
        }else if data.count == dataLengthMax{
            dataQueueFull = true
        }
        
        if abs(newData)>=dataMax{
            dataMax = abs(newData)
            if dataQueueFull{
                dataMaxIndex = dataLengthMax
            }else{
                dataMaxIndex = data.count
            }
        }
        if dataMaxIndex==0{
            reAutoScale()
        }
    }

    
    private func reAutoScale(){
        dataMax = 0.0001
        for i in 1 ..< dataLengthMax {
            if abs(data[i]) >= dataMax{
                dataMaxIndex = i
                dataMax = abs(data[i])
            }
        }
    }
    
    func drawAxis(context:CGContextRef){
        CGContextMoveToPoint(context, beginXx, beginYy)
        CGContextAddLineToPoint(context, beginXx + CGFloat( dataLengthMax), beginYy)
        
        CGContextMoveToPoint(context, beginXx, beginYy-dataYScale)
        CGContextAddLineToPoint(context, beginXx, beginYy+dataYScale)
        
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.4)
        CGContextSetLineWidth(context, 2)
        CGContextStrokePath(context)
    }
    func updateCurve(context:CGContextRef ){
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, beginXx, beginYy+dataYScale*data.first!/dataMax)
        if dataQueueFull{
            for i in 1 ..< dataLengthMax {
                CGPathAddLineToPoint(path, nil, beginXx+CGFloat(i), beginYy+dataYScale*data[i]/dataMax)
            }
        }else{
            for i in 1 ..< data.count {
                CGPathAddLineToPoint(path, nil, beginXx+CGFloat(i), beginYy+dataYScale*data[i]/dataMax)
            }
        }
        CGContextSetLineWidth(context, 1.5)
        CGContextSetRGBStrokeColor(context, color.red, color.green, color.blue, color.alphe)
        CGContextAddPath(context, path)
        CGContextStrokePath(context)
    }
    
}

struct Color {
    var red = CGFloat(0)
    var green = CGFloat(0)
    var blue = CGFloat(0)
    var alphe = CGFloat(0)
    init(){}
}