//
//  DataManager.swift
//  PersistanceLesson1
//
//  Created by Enoxus on 20/11/2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//

import Foundation

protocol DataManager {
    
    func syncDelete(_ post: PostDTO)
    func asyncDelete(_ post: PostDTO, completion: @escaping ([PostDTO]) -> Void)
    func syncGet(by indexPath: IndexPath) -> PostDTO
    func asyncGet(by indexPath: IndexPath, completion: @escaping (PostDTO) -> Void)
    func syncGetAll() -> [PostDTO]
    func asyncGetAll(completion: @escaping ([PostDTO]) -> Void)
    func asyncSearch(by query: String, completion: @escaping ([PostDTO]) -> Void)
    func syncSave(_ post: PostDTO)
    func asyncSave(_ post: PostDTO, completion: @escaping ([PostDTO]) -> Void)
    func asyncGetMore(number: Int, completion: @escaping ([PostDTO]) -> Void)
}
