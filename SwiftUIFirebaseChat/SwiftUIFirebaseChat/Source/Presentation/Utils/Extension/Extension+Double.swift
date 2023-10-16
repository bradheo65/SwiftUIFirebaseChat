//
//  Extension+Double.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/10/16.
//

import Foundation

extension Double {
    var formatter: Double {
        return ceil(self)
    }    
    
    var numberFormatter: String {
        //*소수점 버리기
        
        return String(format: "%.1f", self)
    }
}
