//
//  FlickrPhotoFetcher.swift
//  FlickrPhotos
//
//  Created by Sun Jin on 2018/10/22.
//  Copyright © 2018 dao. All rights reserved.
//

import Foundation

class FlickrPhotoFetcher: DataFetcher {
    
    var photos = [[String:Any]]()
    var itemCount: Int { get { return photos.count }}
    
    var page = -1
    var pages = -1
    var perpage = 100
    
    var nextCursor: Any? {
        get {
            if page < 0 || page >= pages {
                return nil
            }
            return page + 1
        }
    }
    var hasNext: Bool { get { return page < 0 || page < pages } }
    
    var _tags : String
    
    public init(tags: String) {
        _tags = tags
    }
    
    subscript(position: Int) -> Any? {
        if position < photos.startIndex || position > photos.endIndex {
            return nil
        }
        return photos[position]
    }
    
    func refresh(completion: ((Bool, Error?) -> Void)?) {
        fetch(next: nil, completion: completion)
    }
    
    func fetchNext(completion: ((Bool, Error?) -> Void)?) {
        guard hasNext else {
            if let block = completion {
                block(false, NSError(domain: "FlickrPhotoFetcher", code: -1000, userInfo: [NSLocalizedDescriptionKey:"no more data"]))
            }
            return
        }
        fetch(next: nextCursor as! Int?, completion: completion)
    }
    
    private func fetch(next: Int?, completion: ((Bool, Error?) -> Void)?) {
        
        let search = FKFlickrPhotosSearch()
        search.tags = _tags
        search.sort = "interestingness-desc"
        search.per_page = String(perpage)
        if let n = next {
            search.page = String(n)
        }
        FlickrKit.shared().call(search) {(results, error) in
            print("results: \(String(describing: results)), error: \(String(describing: error))")
            
            if let photos = results?["photos"] as? [String:Any],
                let photo = photos["photo"] as? [[String:Any]] {
                if let _ = next {
                    // fetch next page
                    self.photos.append(contentsOf: photo)
                } else {
                    // refresh data
                    self.photos.removeAll()
                    self.photos.append(contentsOf: photo)
                }
                
                if let page = photos["page"] as? Int {
                    self.page = page
                }
                if let pages = photos["pages"] as? Int {
                    self.pages = pages
                }
            }
            
            DispatchQueue.main.async {
                if let block = completion {
                    block(error==nil, error)
                }
            }
        }
    }
}
