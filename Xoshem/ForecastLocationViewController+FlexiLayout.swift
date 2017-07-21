//
//  ForecastLocationViewController+FlexiLayout.swift
//  Xoshem
//
//  Created by javierfuchs on 7/20/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import UIKit
import FlexiCollectionViewLayout

extension ForecastLocationViewController: FlexiCollectionViewLayoutDelegate {
    
    func configureLayout() {
        let layout = FlexiCollectionViewLayout()
        collectionView?.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: FlexiCollectionViewLayout, sizeForFlexiItemAt indexPath: IndexPath) -> ItemSizeAttributes {
        let size = boardCellSize()
        return ItemSizeAttributes(itemSize: size, layoutSize: .large, widthFactor: 1, heightFactor: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    
}

