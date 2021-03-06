//
//  SFSymbolCreater.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/9/21.
//

import UIKit

struct SFSymbolCreator {
    static public func setSFSymbolColor(symbolName: String, color: UIColor, size: Int) -> UIImage? {
        
        guard let normalFont = UIFont(name: "Helvetica Neue", size: CGFloat(size)) else { return nil }
        let configuration = UIImage.SymbolConfiguration(font: normalFont)
        
        let symbol = UIImage(systemName: symbolName, withConfiguration: configuration)
        let symbolColored = symbol?.withTintColor(color, renderingMode: .alwaysOriginal)
        
        return symbolColored
    }
}
