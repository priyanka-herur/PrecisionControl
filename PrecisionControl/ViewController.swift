//
//  ViewController.swift
//  PrecisionControl
//
//  Created by Priyanka Herur on 10/15/18.
//  Copyright © 2018 Priyanka Herur. All rights reserved.
//

import UIKit
let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height
class ViewController: UIViewController {
    lazy var precisionControlView:PrecisionControlView = { [unowned self] in
        let unitStr = ""
        let rulersHeight = ScreenHeight
        print(rulersHeight)
        
        var pcView = PrecisionControlView.init(frame: CGRect.init(x: 10, y: 0, width: 80, height: 500),
        pcMinValue: 0, //Minimum value on the Precision Control Handle
        pcMaxValue: 1000, //Minimum value on the Precision Control Handle
        pcIncrement: 0.1, //Incremental step
        pcInterpolationNum: 10, //Number of values inbetween numbers
        viewcontroller:self)
        
        pcView.setDefaultValueAndAnimated(defaultValue: 50.0, animated: true)
        return pcView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(precisionControlView)
        // Do any additional setup after loading the view, typically from a nib.
    }


}

