//
//  DataFetcher.swift
//  FlickrPhotos
//
//  Created by Sun Jin on 2018/10/22.
//  Copyright © 2018 dao. All rights reserved.
//

import Foundation

public protocol DataFetcher {
    var itemCount : Int { get }
    var hasNext : Bool { get }
    var nextCursor : Any? { get }
    
    subscript(position: Int) -> Any? { get }
    
    func refresh(completion: ((Bool, Error?) -> Void)?)
    func fetchNext(completion: ((Bool, Error?) -> Void)?) -> Void
}
