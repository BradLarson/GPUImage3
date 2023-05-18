//
//  DistortedEffect.swift
//  GPUImage
//
//  Created by Mehedi Hasan on 18/5/23.
//  Copyright © 2023 Red Queen Coder, LLC. All rights reserved.
//

import Foundation

public class DistortedEffect: BasicOperation {
    public var time: Float = 0 { didSet { uniformSettings["time"] = time } }
    
    public init() {
        super.init(fragmentFunctionName:"distortedEffectFragment", numberOfInputs: 1)
        ({time = 1})()
    }
}

