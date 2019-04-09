//
//  GradientSlider.swift
//  GradientSlider
//
//  Created by Hardik Shah
//  Copyright © 2019 Hardik Shah. All rights reserved.
//

import UIKit

@IBDesignable public class HKGradientSlider: UIControl {
    
    public static var defaultThickness:CGFloat = 2.0
    public static var defaultThumbSizeWidth:CGFloat = 18.0
    public static var defaultThumbSizeHeight:CGFloat = 27.0

    
    @IBInspectable public var value: CGFloat {
        get{ return _value }
        set{ setValue(newValue, animated:true) }
    }
    
    public func setValue(_ value:CGFloat, animated:Bool = true) {
        _value = max(min(value,self.maximumValue),self.minimumValue)
        updateThumbPosition(animated: animated)
    }
    
    @IBInspectable public var minimumValue: CGFloat = 0.0 // default 0.0. the current value may change if outside new min value
    @IBInspectable public var maximumValue: CGFloat = 1.0 // default 1.0. the current value may change if outside new max value
    public var continuous: Bool = true // if set, value change events are generated any time the value changes due to dragging. default = YES
    public var isLocked:Bool = false
    public var actionBlock:(HKGradientSlider,CGFloat, Bool)->() = {slider,newValue,finished in }
    
    @IBInspectable public var thickness:CGFloat = defaultThickness {
        didSet{
            _trackLayer.cornerRadius = thickness / 2.0
            self.layer.setNeedsLayout()
        }
    }

    @IBInspectable public var thumbIcon:UIImage? = nil {
        didSet{
            _thumbIconLayer.contents = thumbIcon?.cgImage
        }
    }
    
    

    //MARK: - Private Properties
    private var _value:CGFloat = 0.0 // default 0.0. this value will be pinned to min/max
  
    
    private var _thumbLayer:CALayer = {
        let thumb = CALayer()
        thumb.bounds = CGRect(x: 0, y: 0, width: HKGradientSlider.defaultThumbSizeWidth, height: HKGradientSlider.defaultThumbSizeHeight)
        thumb.backgroundColor = UIColor.clear.cgColor
        return thumb
    }()
    
    private var _backgroundLayer:CALayer = {
        let backgroundLayer = CALayer()
        backgroundLayer.backgroundColor = UIColor(red: 203/255.0, green: 203/255.0, blue: 203/255.0, alpha: 1.0).cgColor
        return backgroundLayer
    }()
    

    private var _trackLayer:CAGradientLayer = {
        let track = CAGradientLayer()
        track.startPoint = CGPoint(x: 0.0, y: 0.5)
        track.endPoint = CGPoint(x: 1.0, y: 0.5)
        track.colors = [UIColor(red: 3/255.0, green: 169/255.0, blue: 244/255.0, alpha:                    1.0).cgColor,
                        UIColor(red: 101/255.0, green: 207/255.0, blue: 255/255.0, alpha: 1.0).cgColor,
                        UIColor(red: 255/255.0, green: 145/255.0, blue: 134/255.0, alpha: 1.0).cgColor,
                        UIColor(red: 255/255.0, green: 68/255.0, blue: 49/255.0, alpha: 1.0).cgColor]
        track.locations = [0,0.20,0.45,1.0]
        
        return track
    }()
    
    
    private var _thumbIconLayer:CALayer = {
        let iconLayer = CALayer()
        iconLayer.bounds = CGRect(x: 0, y: 0,
                                  width: HKGradientSlider.defaultThumbSizeWidth,
                                  height: HKGradientSlider.defaultThumbSizeHeight)
        iconLayer.backgroundColor = UIColor.clear.cgColor
        return iconLayer
    }()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        value = aDecoder.decodeObject(forKey: "value") as? CGFloat ?? 0.0
        minimumValue = aDecoder.decodeObject(forKey: "minimumValue") as? CGFloat ?? 0.0
        maximumValue = aDecoder.decodeObject(forKey: "maximumValue") as? CGFloat ?? 1.0
        thickness = aDecoder.decodeObject(forKey: "thickness") as? CGFloat ?? 2.0
        thumbIcon = aDecoder.decodeObject(forKey: "thumbIcon") as? UIImage
        commonSetup()
    }
    
    
    override public func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(value, forKey: "value")
        aCoder.encode(minimumValue, forKey: "minimumValue")
        aCoder.encode(maximumValue, forKey: "maximumValue")
        aCoder.encode(thickness, forKey: "thickness")
        aCoder.encode(thumbIcon, forKey: "thumbIcon")
    }
    
    private func commonSetup() {
        self.layer.delegate = self
        self.layer.addSublayer(_backgroundLayer)
        self.layer.addSublayer(_trackLayer)
        self.layer.addSublayer(_thumbLayer)

        _thumbLayer.addSublayer(_thumbIconLayer)
    }
    
    //MARK: - Layout
    override public var intrinsicContentSize:CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: HKGradientSlider.defaultThumbSizeHeight)
    }
    

    
    override public func layoutSublayers(of layer: CALayer) {
        
        if layer != self.layer {return}
        
        let w = self.bounds.width
        let h = self.bounds.height
        let left:CGFloat = 2.0
        
        _backgroundLayer.cornerRadius = thickness/2
        _backgroundLayer.bounds = CGRect(x: 0, y: 0, width: w, height: thickness)
        _backgroundLayer.position = CGPoint(x: w/2.0 + left,y: h/2)
        let halfSize = HKGradientSlider.defaultThumbSizeHeight/2.0 - 10
        _thumbIconLayer.position = CGPoint(x: halfSize, y: halfSize)
        _thumbIconLayer.bounds = CGRect(x: 0, y: 0, width: HKGradientSlider.defaultThumbSizeWidth, height: HKGradientSlider.defaultThumbSizeHeight)

        
        updateThumbPosition(animated: false)
    }
    

    //MARK: - Touch Tracking
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        let pt = touch.location(in: self)
        
        let center = _thumbLayer.position
        let diameter = max(HKGradientSlider.defaultThumbSizeWidth,44.0)
        let r = CGRect(x: center.x - diameter/2.0, y: center.y - diameter/2.0, width: diameter, height: diameter)
        print(r.contains(pt))
        if r.contains(pt){
            sendActions(for: UIControl.Event.touchDown)
            return true
        }
        return false
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        let pt = touch.location(in: self)
        let newValue = valueForLocation(point: pt)
        if isLocked {
            return false
        }
        setValue(newValue, animated: false)
        if(continuous){
            sendActions(for: UIControl.Event.valueChanged)
            actionBlock(self,newValue,false)
        }
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        if let pt = touch?.location(in: self){
            let newValue = valueForLocation(point: pt)
            setValue(newValue, animated: false)
        }
        actionBlock(self,_value,true)
        sendActions(for: [UIControl.Event.valueChanged, UIControl.Event.touchUpInside])
        
    }
    
    //MARK: - Private Functions
    
    private func updateThumbPosition(animated: Bool){
        let diff = maximumValue - minimumValue
        let perc = CGFloat((value - minimumValue) / diff)
        
        let halfHeight = self.bounds.height / 2.0
        let trackWidth = _backgroundLayer.bounds.width - HKGradientSlider.defaultThumbSizeWidth / 4
        let left = _backgroundLayer.position.x - trackWidth/2.0
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        _thumbLayer.bounds = CGRect(x: -9, y: 0, width: HKGradientSlider.defaultThumbSizeWidth, height: HKGradientSlider.defaultThumbSizeHeight)
        _thumbLayer.position = CGPoint(x: left + (trackWidth * perc), y: halfHeight + thickness/2.5)

        _trackLayer.bounds = CGRect(x: 0, y: 0, width: left + (trackWidth * perc) , height: thickness)
        _trackLayer.position = CGPoint(x: _trackLayer.bounds.width / 2,y: halfHeight)
        CATransaction.commit()

    }
    
    private func valueForLocation(point:CGPoint)->CGFloat {
        
        
        let left = self.bounds.origin.x + 9
        let w = self.bounds.width
      
        let diff = CGFloat(self.maximumValue - self.minimumValue)
        let perc = max(min((point.x - left) / w ,1.0), 0.0)
        return (perc * diff) + CGFloat(self.minimumValue)
    }
    

}


