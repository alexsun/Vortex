//
//  Adapter.swift
//  Vortex
//
//  Created by Sun Jin on 2018/11/23.
//  Copyright © 2018 t. All rights reserved.
//

import UIKit
//import A

public class Adapter : NSObject {
    
    private var vortex : Vortex
    
    public init(collectionView: UICollectionView, model: Vortex) {
        vortex = model
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension Adapter : UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let section = vortex.sectionList[indexPath.section]
        let sizeBlock = section.items?[indexPath.item].size ?? section.template?.size
        return sizeBlock?(indexPath) ?? layout.itemSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return vortex.sectionList[section].header?.size?(section) ?? CGSize.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return vortex.sectionList[section].footer?.size?(section) ?? CGSize.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        return vortex.sectionList[section].insets ?? layout.sectionInset
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        return vortex.sectionList[section].minLineSpacing ?? layout.minimumLineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        return vortex.sectionList[section].minInteritemSpacing ?? layout.minimumInteritemSpacing
    }
}

extension Adapter : UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader, let header = vortex.sectionList[indexPath.section].header {
            
            let view = collectionView.dequeueReusableCell(withReuseIdentifier: header.reuseId, for: indexPath)
            header.setup?(view)
            return view
            
        } else if kind == UICollectionView.elementKindSectionFooter, let footer = vortex.sectionList[indexPath.section].footer {
            
            let view = collectionView.dequeueReusableCell(withReuseIdentifier: footer.reuseId, for: indexPath)
            footer.setup?(view)
            return view
        }
        
        return UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = vortex.sectionList[indexPath.section]
        let didSelectBlock = section.items?[indexPath.item].selectedAction ?? section.template?.selectedAction
        let selectDeselectedBlock = section.items?[indexPath.item].selectDeselectedAction ?? section.template?.selectDeselectedAction
        
        if let block = didSelectBlock {
            block(indexPath) { animated in
                collectionView.deselectItem(at: indexPath, animated: animated)
            }
        } else if let block = selectDeselectedBlock {
            collectionView.deselectItem(at: indexPath, animated: true)
            block(indexPath)
        }
    }
    
}

extension Adapter : UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return vortex.sectionList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let items = vortex.sectionList[section].items {
            return items.count
        }
        return vortex.sectionList[section].numberOfItems(section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = vortex.sectionList[indexPath.section]
        let reuseId = section.reuseIdFor(indexPath: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath)
        
        let setupBlock = section.items?[indexPath.item].setupFunc ?? section.template?.setupFunc
        setupBlock?(cell, indexPath)
        
        return cell
    }
}

