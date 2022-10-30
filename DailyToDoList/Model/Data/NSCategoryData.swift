//
//  NSCategoryData.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/10/30.
//

import Foundation

struct NSCategoryDataList: Codable {
    var categoryList:[NSCategoryData]
}

struct NSCategoryData: Codable {
    //카테고리이름
    var title:String = ""
    //colorList
    var colorList:[Float] = []
    
    
    // Init
    init(category:CategoryData)
    {
        self.title = category.title
        self.colorList = category.getColorList()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CategoryCodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(colorList, forKey: .colorList)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CategoryCodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        colorList = try container.decode([Float].self, forKey: .colorList)
    }
}
