//
//  ImageTransformer.swift
//  PersistentLesson3
//
//  Created by Ильдар Залялов on 04.12.2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//

import UIKit

class ImageTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let image = value as? UIImage else { return nil }
        
        let data = image.pngData()
        
        return data
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        
        guard let imageData = value as? Data else { return nil }
        
        return UIImage(data: imageData)
    }
}
