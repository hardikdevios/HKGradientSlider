//
//  ViewController.swift
//  HKGradientSlider
//
//  Created by Hardik-Mac on 3/30/19.
//  Copyright © 2019 Thetatechnolabs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var slider: HKGradientSlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        slider.thickness = 15
        HKGradientSlider.defaultThumbSizeHeight = 36
        HKGradientSlider.defaultThumbSizeWidth = 24

        // Do any additional setup after loading the view.
    }


}

