//
//  ViewController.swift
//  FlickrPhotos
//
//  Created by Sun Jin on 2018/10/22.
//  Copyright © 2018 dao. All rights reserved.
//

import UIKit
import Vortex
import Haneke
import ImageViewer

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var adapter : Adapter?
    var fetcher = FlickrPhotoFetcher(tags: "scenery,valley,locomotive,railroad,sunset,beach,sky")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCollectionDataSource()
        
        fetcher.fetchNext { (success, error) in
            self.collectionView.reloadData()
        }
    }
    
    func setupCollectionDataSource() {
        let vortex = Vortex()
            +++
            Vortex.Section({ (s) in
                s.insets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
                s.minLineSpacing = 10
                s.minInteritemSpacing = 10
                s.template = Vortex.Item(reuseId: "cell")
                    .size({ [unowned self] (indexPath) -> CGSize in
                        let cw = self.collectionView.bounds.width
                        // let col = col = (cw - 30 + 10) / (w + 10)
                        let col = ((cw - 30 + 10) / (100 + 10)).rounded(.down)
                        let width = (cw - 30 + 10) / col - 10
                        return CGSize(width: width, height: 130 / 100 * width)
                    })
                    .onSetup({[unowned self] (cell, indexPath) in
                        if let imgView = cell.viewWithTag(1000) as? UIImageView,
                            let photo = self.fetcher[indexPath.item] as? [String:Any]
                        {
                            imgView.image = nil;
                            let photoURL = FlickrKit.shared().photoURL(for: .small240, fromPhotoDictionary: photo)
                            imgView.hnk_setImageFromURL(photoURL)
                        }
                    })
                    .onSelectDeselected({[unowned self] (indexPath) in
                        self.showImageFrom(indexPath: indexPath)
                    })
                s.onItemCount({[unowned self] (_) -> Int in
                    return self.fetcher.itemCount
                })
            })
        adapter = Adapter(collectionView: collectionView, model: vortex)
        collectionView.reloadData()
    }
    
    func showImageFrom(indexPath: IndexPath) {
        
        let gallery = GalleryViewController(startIndex: indexPath.item,
                                            itemsDataSource: self,
                                            itemsDelegate: nil,
                                            displacedViewsDataSource: self,
                                            configuration: [.deleteButtonMode(.none)])
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: indexPath.item, count: self.fetcher.itemCount)
        let footerView = CounterView(frame: frame, currentIndex: indexPath.item, count: self.fetcher.itemCount)
        gallery.headerView = headerView
        gallery.footerView = footerView
        
        gallery.landedPageAtIndexCompletion = {[unowned self] index in
            
            headerView.currentIndex = index
            headerView.count = self.fetcher.itemCount
            footerView.currentIndex = index
            footerView.count = self.fetcher.itemCount
            
            let indexPath = IndexPath(item: index, section: 0)
            let visiblePaths = self.collectionView.indexPathsForVisibleItems
            let min = visiblePaths.min()
            let max = visiblePaths.max()
            if (min != nil && indexPath < min!) || (max != nil && indexPath > max!) {
                self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            }
        }
        self.presentImageGallery(gallery)
    }
}

extension ViewController : GalleryItemsDataSource {
    
    func itemCount() -> Int {
        return fetcher.itemCount
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return .image(fetchImageBlock: {[unowned self] completion in
            if let photo = self.fetcher[index] as? [String:Any] {
                let photoURL = FlickrKit.shared().photoURL(for: .small240, fromPhotoDictionary: photo)
                _ = Shared.imageCache.fetch(URL: photoURL, formatName: HanekeGlobals.Cache.OriginalFormatName, failure: { (error) in
                    print("failed to fetch photo \(String(describing: error))")
                    completion(nil)
                }, success: { (image) in
                    completion(image)
                })
            } else {
                completion(nil)
            }
        })
    }
}

extension UIImageView: DisplaceableView {}

extension ViewController : GalleryDisplacedViewsDataSource {
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0))
        return cell?.viewWithTag(1000) as? UIImageView
    }
}

