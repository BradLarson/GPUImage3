//
//  CustomBrightnessAdjustment.swift
//  SimpleImageFilter
//
//  Created by yang on 2020/4/2.
//  Copyright © 2020 Sunset Lake Software LLC. All rights reserved.
//

import GPUImage
import Foundation

class CustomBrightnessAdjustment: BasicOperation {
    public var brightness:Float = 0.0 { didSet { uniformSettings["brightness"] = brightness } }

    public init() {
        let libraryPath = Bundle.main.path(forResource: "default", ofType: "metallib")!
        super.init(fragmentFunctionName:"brightnessFragment", fragmentLibraryPath: libraryPath, numberOfInputs:1)

        ({brightness = 0.0})()
    }
}
