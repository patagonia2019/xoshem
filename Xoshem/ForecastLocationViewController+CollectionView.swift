//
//  ForecastLocationViewController+CollectionView.swift
//  Xoshem
//
//  Created by javierfuchs on 7/20/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation

extension ForecastLocationViewController : UICollectionViewDelegate {

    // Uncomment this method to specify if the specified item should be highlighted during tracking
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            let forecastCell = cell as! ForecastLocationCollectionViewCell
            forecastCell.selected()
            UIView.animate(withDuration: 0.5, animations: {
                forecastCell.unselected()
            })
            
            let lastRow = totalCells() - 1

            if indexPath.item == lastRow {
                performSegue(withIdentifier: Common.segue.search, sender: nil)
            }
            else if indexPath.item == 0 && Facade.instance.fetchLocalForecast() != nil {
                performSegue(withIdentifier: Common.segue.forecastDetail, sender: nil)
            }
        }
    }

}

extension ForecastLocationViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func totalCells() -> Int {
        var count = 0
        
        // current location
        if Facade.instance.fetchLocalForecast() != nil {
            count += 1
        }
        // Add new (+)
        count = count + 1
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalCells()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Common.cell.identifier.forecast, for: indexPath) as! ForecastLocationCollectionViewCell
        
        let lastRow = totalCells() - 1
        if indexPath.item == lastRow {
            cell.configureLastCell()
        }
        else if indexPath.item == 0 {
            if let currentForecast = Facade.instance.fetchLocalForecast() {
                cell.configureCell(currentForecast, isEditing: isEditing, didUpdate: { [weak self] (Void) in
                    self?.updateForecastView(false)
                })
            }
        }
        return cell
    }

}
