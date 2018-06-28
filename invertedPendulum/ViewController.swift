//
//  ViewController.swift
//  invertedPendulum
//
//  Created by F on 15/11/24.
//  Copyright © 2015年 F. All rights reserved.
//

import UIKit
import CoreMotion

var linkage1Data = linkage(Length: 164.66667, LinkWeight: 28, PendulumWeight: 60/1.5)
var linkage2Data = linkage(Length: 194/1.5, LinkWeight: 33/1.5, PendulumWeight: 44/1.5)
//var linkage2Data = linkage(Length: 194/3, LinkWeight: 33/3, PendulumWeight: 44/3)
//var linkage2Data = linkage(Length: 194/6, LinkWeight: 33/6, PendulumWeight: 44/6)

let simulationStep = 0.005

class ViewController: UIViewController {
   
    let controlPeriod = 0.01
    let refreshFPS = 48.0
    let deviceMotionUpdateInterval = 0.05
    
    let carBoundary = CGFloat(135)
    let bottomWidth = CGFloat(779/2.3),bottomHeight = CGFloat(91/2.3)
    let carWidth = CGFloat(110/2.5)
    let zeroX = CGFloat(190), zeroY = CGFloat(400)
    let oscilloscopeBeginX = 25.0 , oscilloscopeBeginY = 520.0

    @IBOutlet weak var labelAngle1: UILabel!
    @IBOutlet weak var labelAngle2: UILabel!
    @IBOutlet weak var labelMotor: UILabel!
    @IBOutlet weak var labelCar: UILabel!
    

    @IBOutlet weak var kpCar: UISlider!
    @IBOutlet weak var kdCar: UISlider!
    @IBOutlet weak var kpAngle1: UISlider!
    @IBOutlet weak var kdAngle1: UISlider!
    @IBOutlet weak var kpAngle2: UISlider!
    @IBOutlet weak var kdAngle2: UISlider!
    @IBAction func ControllerParametersChanged(sender: AnyObject) {
        invPendulum.setControllerParameters(kpCar.value, KdCar1: kdCar.value, KpAngle1: kpAngle1.value, KdAngle1: kdAngle1.value, KpAngle2: kpAngle2.value, KdAngle2: kdAngle2.value)
//        angle1 = CGFloat( kp1.value * 6.28)
//        angle2 = CGFloat( kd1.value * 6.28)
    }
    
    
    @IBOutlet weak var linkage1LengthSlider: UISlider!
    @IBOutlet weak var linkage2LengthSlider: UISlider!
    @IBOutlet weak var linkage1widthSlider: UISlider!
    @IBOutlet weak var linkage2widthSlider: UISlider!
    @IBOutlet weak var linkage1RadiusSlider: UISlider!
    @IBOutlet weak var linkage2RadiusSlider: UISlider!
    @IBOutlet var myViewTest: myView!
//    @IBOutlet weak var labelTest: UILabel!
    @IBOutlet weak var runOrPauseButton: UIButton!
    
    @IBAction func resetButtonClicked(sender: AnyObject) {
        systemReset()
        run = false
    }
    @IBAction func runOrPauseButtonClicked(sender: AnyObject){
        if run{
            systemPause()
        }else{
            systemRun()
        }
        run = !run
    }
    
    @IBAction func modelParametsSliderTouchUp(sender: AnyObject) {
        if run{
            systemRun()
        }
        invPendulum.updateModelParameters()
    }
    @IBAction func modelParametsSliderTouchDown(sender: AnyObject) {
        systemPause()
    }
    @IBAction func linkage1DataChanged(sender: AnyObject) {
        linkage1Data.zoomLength(linkage1LengthSlider.value)
        linkage1Data.zoomWidth(linkage1widthSlider.value)
        linkage1Data.zoomRadius(linkage1RadiusSlider.value)
        linkage1Refresh()
        joint1Refresh()
        linkage1Rotate(angle1)
        
        linkage2Refresh()
        joint2Refresh()
        linkage2Rotate(angle2)
    }
    
    @IBAction func linkage2DataChanged(sender: AnyObject) {
        linkage2Data.zoomLength(linkage2LengthSlider.value)
        linkage2Data.zoomWidth(linkage2widthSlider.value)
        linkage2Data.zoomRadius(linkage2RadiusSlider.value)
        linkage2Refresh()
        joint2Refresh()
        linkage2Rotate(angle2)
    }
    
    var cmm = CMMotionManager()
    let bottom = UIImageView()
    let car = UIImageView()
    let linkage1 = UIImageView()
    let linkage2 = UIImageView()
    let joint1 = UIImageView()
    let joint2 = UIImageView()
    var invPendulum = twoOrderInvertedPendulum(SimulationStep: simulationStep)
    
    var carPosition = CGFloat (0)
    var angle1 = CGFloat (0)
    var angle2 = CGFloat (0)
    var motorOutput = CGFloat (0)
//    var angle1Speed = CGFloat (0.0)
    var accelerationX = CGFloat (0.0)
    var timerSimulation = NSTimer()
    var timerRefresh = NSTimer()
    var timerController = NSTimer()
    var run:Bool = true
    
    func carRefresh(){
        car.transform = CGAffineTransformIdentity
        car.frame = CGRectMake(zeroX - carWidth/2, zeroY - carWidth/2, carWidth, carWidth)
    }
    func linkage1Refresh(){
        linkage1.transform = CGAffineTransformIdentity
        linkage1.frame = CGRectMake(zeroX + carPosition - linkage1Data.getWidth()/2 , zeroY - linkage1Data.getLength(),linkage1Data.getWidth(),linkage1Data.getLength() )
    }
    func joint1Refresh(){
        joint1.transform = CGAffineTransformIdentity
        joint1.frame = CGRectMake(zeroX + carPosition - linkage1Data.getRadius()/2, zeroY-linkage1Data.getLength()-linkage1Data.getRadius()/2 , linkage1Data.getRadius(), linkage1Data.getRadius())
    }
    func linkage2Refresh(){
        linkage2.transform = CGAffineTransformIdentity
        linkage2.frame = CGRectMake(joint1.frame.midX - linkage2Data.getWidth()/2, joint1.frame.midY-linkage2Data.getLength(),linkage2Data.getWidth(),linkage2Data.getLength())
    }
    func joint2Refresh(){
        joint2.transform = CGAffineTransformIdentity
        joint2.frame = CGRectMake(joint1.frame.midX-linkage2Data.getRadius()/2, joint1.frame.midY-linkage2Data.getLength()-linkage2Data.getRadius()/2 , linkage2Data.getRadius(), linkage2Data.getRadius())
    }
    
    func drawInit(){
        linkage1LengthSlider.transform = CGAffineTransformMakeRotation(CGFloat (-M_PI_2))
        linkage2LengthSlider.transform = CGAffineTransformMakeRotation(CGFloat (-M_PI_2))
        linkage1widthSlider.transform = CGAffineTransformMakeRotation(CGFloat (-M_PI_2))
        linkage2widthSlider.transform = CGAffineTransformMakeRotation(CGFloat (-M_PI_2))
        linkage1RadiusSlider.transform = CGAffineTransformMakeRotation(CGFloat (-M_PI_2))
        linkage2RadiusSlider.transform = CGAffineTransformMakeRotation(CGFloat (-M_PI_2))
        
        
        myViewTest.oscilloscopeCurveAngle2.setCurveColor(1, green: 0, blue: 0, alpha: 1)
        myViewTest.oscilloscopeCurveAngle1.setCurveColor(0, green: 1, blue: 0, alpha: 0.9)
        myViewTest.oscilloscopeCurveMotor.setCurveColor(0, green: 0, blue: 1, alpha: 0.9)
//        myViewTest.oscilloscopeCurveCarPosition.setCurveColor(1, green: 0, blue: 1, alpha: 0.9)
        myViewTest.oscilloscopeCurveAngle1.setPosition(oscilloscopeBeginX, y: oscilloscopeBeginY)
        myViewTest.oscilloscopeCurveAngle2.setPosition(oscilloscopeBeginX, y: oscilloscopeBeginY)
        myViewTest.oscilloscopeCurveMotor.setPosition(oscilloscopeBeginX, y: oscilloscopeBeginY)
//        myViewTest.oscilloscopeCurveCarPosition.setPosition(oscilloscopeBeginX, y: oscilloscopeBeginY)

        
        bottom.image = UIImage(named: "bottom")
        bottom.frame = CGRectMake(zeroX-bottomWidth/2 , zeroY-bottomHeight/2 - 14 + carWidth/2, bottomWidth, bottomHeight)
        
        car.image = UIImage(named: "car")
        carRefresh()
        
        linkage1.image = UIImage(named: "linkage1")
        linkage1Refresh()
        
        joint1.image = UIImage(named: "joint1")
        joint1Refresh()
        
        linkage2.image = UIImage(named: "linkage2")
        linkage2Refresh()
        
        joint2.image = UIImage(named: "joint2")
        joint2Refresh()
        
        self.view.addSubview(linkage1)
        self.view.addSubview(linkage2)
        self.view.addSubview(bottom)
        self.view.addSubview(car)
        self.view.addSubview(joint1)
        self.view.addSubview(joint2)        
    }
    
    func simulation(){
        (carPosition,angle1,angle2) = invPendulum.simulation()
    }
    func updateController(){
        motorOutput = CGFloat( invPendulum.updateController() )
    }
    
    func addTimer(){
        if !timerSimulation.valid{
            timerSimulation = NSTimer.scheduledTimerWithTimeInterval(simulationStep, target: self, selector: "simulation", userInfo: nil, repeats: true)
        }
        if !timerRefresh.valid{
            timerRefresh = NSTimer.scheduledTimerWithTimeInterval(1.0 / refreshFPS, target: self, selector: "refresh", userInfo: nil, repeats: true)
        }
        if !timerController.valid{
            timerController = NSTimer.scheduledTimerWithTimeInterval(controlPeriod , target: self, selector: "updateController", userInfo: nil, repeats: true)
        }
    }
    func removeTimer(){
        timerSimulation.invalidate()
        timerRefresh.invalidate()
        timerController.invalidate()
    }
    
    func carMove(position:CGFloat){
        car.transform = CGAffineTransformIdentity
        car.transform = CGAffineTransformMakeTranslation(position, 0)
        linkage1Refresh()
        joint1Refresh()
        linkage2Refresh()
        joint2Refresh()
    }
    
    func linkage1Rotate(angle:CGFloat){
        linkage1.transform = CGAffineTransformIdentity
        linkage1.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(linkage1Data.getLength()*sin(angle)/2 , linkage1Data.getLength()*(1-cos(angle))/2), angle)
        
        joint1.transform = CGAffineTransformIdentity
        joint1.transform = CGAffineTransformMakeTranslation(linkage1Data.getLength()*sin(angle), linkage1Data.getLength()*(1-cos(angle)))
        
        linkage2Refresh()
        joint2Refresh()
        
    }
    func linkage2Rotate(angle:CGFloat){
        linkage2.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(linkage2Data.getLength()*sin(angle)/2 , linkage2Data.getLength()*(1-cos(angle))/2), angle)
        
        joint2.transform = CGAffineTransformMakeTranslation(linkage2Data.getLength()*sin(angle), linkage2Data.getLength()*(1-cos(angle)))
    }

    func refresh(){
        labelAngle2.text  = String(format: "%+.5f", Double(angle2)*180/M_PI)
        labelAngle1.text  = String(format: "%+.5f", Double(angle1)*180/M_PI)
        labelMotor.text  = String(format: "%+.5f", motorOutput)
        labelCar.text  = String(format: "%+.4f", carPosition)
        carMove(carPosition)
        linkage1Rotate(angle1)
        linkage2Rotate(angle2)
        myViewTest.oscilloscopeCurveAngle1.getData(angle1)
        myViewTest.oscilloscopeCurveAngle2.getData(angle2)
        myViewTest.oscilloscopeCurveMotor.getData(motorOutput)
//        myViewTest.oscilloscopeCurveCarPosition.getData(carPosition)
        myViewTest.setNeedsDisplay()
        if(abs(carPosition) > carBoundary ){
            invPendulum.reset()
        }
        
    }
    
    func systemReset(){
        systemPause()
        invPendulum.reset()
        carPosition = 0
        angle1 = 0
        angle2 = 0
        refresh()
    }
    
    func systemRun(){
        addTimer()
        runOrPauseButton.setTitle("Pause", forState: UIControlState.Normal)
        if cmm.deviceMotionAvailable{
            cmm.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XTrueNorthZVertical, toQueue: NSOperationQueue.mainQueue(), withHandler: { (data:CMDeviceMotion?, err:NSError?) -> Void in
                if (data != nil){
                    self.invPendulum.setDisturbance((data?.userAcceleration.x)! * 50.0 + (data?.gravity.x)! * 50.0)
                }
            })
        }
    }
    
    func systemPause(){
        removeTimer()
        runOrPauseButton.setTitle("Run", forState: UIControlState.Normal)
        if cmm.deviceMotionActive{
            cmm.stopDeviceMotionUpdates()
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        drawInit()
        invPendulum.setControllerParameters(kpCar.value, KdCar1: kdCar.value, KpAngle1: kpAngle1.value, KdAngle1: kdAngle1.value, KpAngle2: kpAngle2.value, KdAngle2: kdAngle2.value)
    }
    override func viewWillAppear(animated: Bool) {
        cmm.deviceMotionUpdateInterval = deviceMotionUpdateInterval
        systemRun()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        systemPause()
    }
    deinit{
        systemPause()
    }
}






