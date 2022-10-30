//
//  CategoryData.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/08.
//

import Foundation
import UIKit
import RealmSwift


class CategoryData : Object {
    @Persisted
    var title = ""
    @Persisted
    var colorList:List<Float>
    private var color:[Float] {
        get {
            return colorList.map{$0}
        }
        set {
            colorList.removeAll()
            colorList.append(objectsIn: newValue)
        }
    }
    
    convenience init(_ title:String, _ color:[Float]) {
        self.init()
        self.title = title
        self.color = color
    }
    
    func loadImage() -> UIImage {
        guard let image = UIImage(systemName: "rectangle.fill") else {
            return UIImage()
        }
        return image.withTintColor(Utils.getColor(colorList), renderingMode: .alwaysOriginal)
    }
    
    func loadColor() -> UIColor {
        return Utils.getColor(colorList)
    }
    
    func getColorList() -> [Float] {
        return color
    }
}
