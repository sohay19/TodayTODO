//
//  CategoryData.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/08.
//

import Foundation
import UIKit
import RealmSwift

class CategoryOrderData : Object {
    @Persisted(primaryKey: true)
    var primaryKey:Int
    @Persisted
    var orderList:List<String>
    private var order:[String] {
        get {
            return orderList.map{$0}
        }
        set {
            orderList.removeAll()
            orderList.append(objectsIn: newValue)
        }
    }
    
    convenience init(order:[String], _ primaryKey:Int = 0) {
        self.init()
        self.primaryKey = primaryKey
        self.order = order
    }
    
    func getCategoryOrder() -> [String] {
        return order
    }
}

class CategoryData : Object {
    @Persisted(primaryKey: true)
    var primaryKey:Int
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
        self.primaryKey = DataManager.shared.getAllCategory().count
        self.title = title
        self.color = color
    }
    
    convenience init(_ primaryKey:Int, _ title:String, _ color:[Float]) {
        self.init()
        self.primaryKey = primaryKey
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
    
    func clone() -> CategoryData {
//        return CategoryData(self.title, self.getColorList())
        return CategoryData(self.primaryKey, self.title, self.getColorList())
    }
}
