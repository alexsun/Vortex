//
//  Vortex.swift
//  Vortex
//
//  Created by Sun Jin on 2018/10/19.
//  Copyright © 2018 t. All rights reserved.
//

import UIKit

precedencegroup VortexPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

precedencegroup SectionPrecedence {
    associativity: left
    higherThan: VortexPrecedence
}

infix operator +++ : VortexPrecedence

public func +++ (lhs: Vortex, rhs: Vortex.Section) -> Vortex {
    return lhs.append(section: rhs)
}

public func +++ (lhs: Vortex.Section, rhs: Vortex.Section) -> Vortex {
    return Vortex() +++ lhs +++ rhs
}


infix operator >>> : SectionPrecedence

public func >>> (lhs: Vortex.Section, rhs: Vortex.Item) -> Vortex.Section {
    return lhs.append(item: rhs)
}

public func >>> (lhs: Vortex.Item, rhs: Vortex.Item) -> Vortex.Section {
    return Vortex.Section().append(item: lhs).append(item: rhs)
}


public class Vortex {
    
    public private(set) var sectionList: [Section] = []
    
    public init() {}
    
    public convenience init(section: Section) {
        self.init()
        sectionList.append(section)
    }
    
    public func append(section: Section) -> Vortex {
        sectionList.append(section)
        return self
    }
    
    
    public class Section {
        
        public var insets : UIEdgeInsets?
        public var minLineSpacing : CGFloat?
        public var minInteritemSpacing : CGFloat?
        
        // header footer
        public var header : Supplement?
        public var footer : Supplement?
        
        // item list
        var items : [Item]?
        
        var numberOfItems : (Int) -> Int = {section in 0}
        public var template : Item?
        
        public init() {
            
        }
        
        public init(_ initializer: (Section) -> Void) {
            initializer(self)
        }
        
        @discardableResult public func append(item: Item) -> Section {
            if items == nil { items = []}
            items?.append(item)
            return self
        }
        
        @discardableResult public func onItemCount(_ block: @escaping (Int)->Int) -> Section {
            numberOfItems = block
            return self
        }
        
        func reuseIdFor(indexPath : IndexPath) -> String {
            let reuseId : String
            if let items = items {
                reuseId = items[indexPath.item].reuseId
            } else if let item = template {
                reuseId = item.reuseId
            } else {
                reuseId = ""
            }
            return reuseId
        }
        
        
        public class Supplement {
            var reuseId : String
            var size : ((Int)->CGSize)?
            var setup : ((UICollectionReusableView)->Void)?
            
            public init(reuseId: String) {
                self.reuseId = reuseId
            }
            
            public init(reuseId: String, _ initializer: (Supplement)->Void) {
                self.reuseId = reuseId
                initializer(self)
            }
            
            @discardableResult public func size(_ block: @escaping (_ section: Int)->CGSize) -> Supplement {
                size = block
                return self
            }
            @discardableResult public func onSetup(_ block: @escaping (_ supplement: UICollectionReusableView)->Void) -> Supplement {
                setup = block
                return self
            }
        }
    }
    
    public class Item {
        var reuseId : String
        
        // 各种回调
        var selectDeselectedAction : ((IndexPath) -> Void)?
        var selectedAction : ((IndexPath, _ deselect: (_ animated: Bool) -> Void) -> Void)?
        var deselectedAction : ((IndexPath) -> Void)?
        var setupFunc : ((UICollectionViewCell, IndexPath) -> Void)?
        var size : ((IndexPath) -> CGSize)?
        
        public init(reuseId: String) {
            self.reuseId = reuseId
        }
        
        public init(reuseId: String, _ initializer: (Item)->Void) {
            self.reuseId = reuseId
            initializer(self)
        }
        
        @discardableResult public func onSelectDeselected(_ block: @escaping (IndexPath) -> Void) -> Item {
            selectDeselectedAction = block
            selectedAction = nil
            return self
        }
        
        @discardableResult public func onSelected(_ block: @escaping (IndexPath, _ deselect: (_ animated: Bool) -> Void)  -> Void) -> Item {
            selectedAction = block
            selectDeselectedAction = nil
            return self
        }
        
        @discardableResult public func onDeselected(_ block: @escaping (IndexPath) -> Void) -> Item {
            deselectedAction = block
            return self
        }
        
        @discardableResult public func onSetup(_ block: @escaping (UICollectionViewCell, IndexPath) -> Void) -> Item {
            setupFunc = block
            return self
        }
        
        @discardableResult public func size(_ block: @escaping (IndexPath)->CGSize) -> Item {
            size = block
            return self
        }
    }
}

