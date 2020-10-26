//
//  Extensions+Float.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 10/19/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation

extension Float {
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
