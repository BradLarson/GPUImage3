import Foundation

#if os(iOS)
import UIKit
#endif

public struct Position {
    public let x:Float
    public let y:Float
    public let z:Float?
    
    public init (_ x:Float, _ y:Float, _ z:Float? = nil) {
        self.x = x
        self.y = y
        self.z = z
    }

    public static let center = Position(0.5, 0.5)
    public static let zero = Position(0.0, 0.0)
}


public struct Position2D {
    public let x:Float
    public let y:Float
    
    public init (_ x:Float, _ y:Float) {
        self.x = x
        self.y = y
    }
    
    public static let center = Position(0.5, 0.5)
    public static let zero = Position(0.0, 0.0)
}
