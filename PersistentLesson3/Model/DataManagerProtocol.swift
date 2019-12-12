//
//  DataManagerProtocol.swift
//  BlocksSwift
//
//  Created by Евгений on 08.11.2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//

import Foundation

//Data Manager protocol
protocol DataManagerProtocol {
    
    // MARK: - Saving methods
    func syncSave(_ post: PostStructure) -> [PostStructure]
    func asyncSave(_ post: PostStructure, completion: @escaping ([PostStructure]) -> Void)
    
    // MARK: - Getting methods
    func syncGet() -> [PostStructure]
    func asyncGet(completion: @escaping ([PostStructure]) -> Void)
    
    // MARK: - Deleting methods
    func syncDelete(_ post: PostStructure) -> [PostStructure]
    func asyncDelete(_ post: PostStructure, completion: @escaping ([PostStructure]) -> Void)
    
    // MARK: - Searching methods
    func syncSearch(_ searchQuery: String) -> [PostStructure]
    func asyncSearch(_ searchQuery: String, completion: @escaping ([PostStructure]) -> Void)
    
}
