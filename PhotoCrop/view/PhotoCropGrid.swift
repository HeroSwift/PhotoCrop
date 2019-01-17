//
//  PhotoCropGrid.swift
//  Example
//
//  Created by zhujl on 2019/1/16.
//  Copyright © 2019年 finstao. All rights reserved.
//

import UIKit

class PhotoCropGrid: UIView {
    
    var lineColor = UIColor.white.withAlphaComponent(0.5)
    var lineWidth = 1 / UIScreen.main.scale
    
    lazy var horizontalLines: [UIView] = {
        return [createLine(color: lineColor), createLine(color: lineColor)]
    }()
    
    lazy var verticalLines: [UIView] = {
        return [createLine(color: lineColor), createLine(color: lineColor)]
    }()
    
    override var frame: CGRect {
        didSet {
            guard frame.width != oldValue.width || frame.height != oldValue.height else {
                return
            }
            update()
        }
    }

    // 无视各种交互
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
}

extension PhotoCropGrid {
    
    private func createLine(color: UIColor) -> UIView {
        let line = UIView()
        line.backgroundColor = color
        addSubview(line)
        return line
    }
    
    private func update() {
        
        let width = bounds.width
        let height = bounds.height
        
        let rowSpacing = height / CGFloat(horizontalLines.count + 1)
        let columnSpacing = width / CGFloat(verticalLines.count + 1)
        
        for (i, line) in horizontalLines.enumerated() {
            let offset = rowSpacing * CGFloat(i + 1) + lineWidth * CGFloat(i)
            line.frame = CGRect(x: 0, y: offset, width: width, height: lineWidth)
        }
        
        for (i, line) in verticalLines.enumerated() {
            let offset = columnSpacing * CGFloat(i + 1) + lineWidth * CGFloat(i)
            line.frame = CGRect(x: offset, y: 0, width: lineWidth, height: height)
        }
        
    }
    
}
