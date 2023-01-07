//
//  ViewController.swift
//  Instagram-layout-iOS
//
//  Created by Mahi Al Jawad on 31/12/22.
//

import UIKit

// MARK: For simplicity folder structure/ design pattern not matained

enum Section {
    case photos
}

struct Photo: Hashable {
    let ID: Int
}

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var datasource = configureDatasource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollecitonView()
        updateSnapshot()
    }
    
    func configureDatasource() -> UICollectionViewDiffableDataSource<Section, Photo> {
        // Not required to register cell and configure separately
        // Make sure you don't write reusable ID in the .xib
        let cellRegistration = UICollectionView.CellRegistration<PhotoCell, Photo>(cellNib: UINib(nibName: "PhotoCell", bundle: nil)) { cell, indexPath, photo in
            cell.setup(photo.ID)
        }
        
        let datasource = UICollectionViewDiffableDataSource<Section, Photo>(collectionView: collectionView) { collectionView, indexPath, photo in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: photo)
        }
        
        return datasource
    }
    
    func updateSnapshot() {
        // Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
        snapshot.appendSections([.photos])
        snapshot.appendItems(getPhoto(50), toSection: .photos)
        
        datasource.apply(snapshot, animatingDifferences: true)
    }
    
    // Dummy Photo data generator
    func getPhoto(_ numberOfPhotos: Int) -> [Photo] {
        var photos = [Photo]()
        
        for i in 1...numberOfPhotos {
            photos.append(Photo(ID: i))
        }
        
        return photos
    }
    
    func setupCollecitonView() {
        collectionView.dataSource = datasource
        collectionView.collectionViewLayout = getCompositionalLayout()
        // Old style cell registration
//        collectionView.register(
//            UINib(nibName: "PhotoCell", bundle: nil),
//            forCellWithReuseIdentifier: "PhotoCell"
//        )
    }

    func getCompositionalLayout() -> UICollectionViewCompositionalLayout {
        // 1 Small item configuration
        let smallItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/2),
                heightDimension: .fractionalHeight(1)
            )
        )
        
        smallItem.contentInsets = .init(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        // Contains 2 horizontal small items
        let horizontalSmallItems = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1/2)
            ),
            subitems: [smallItem]
        )
        
        // Contains 4 small items
        let verticalSmallGroups = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(2/3),
                heightDimension: .fractionalHeight(1)
            ),
            repeatingSubitem: horizontalSmallItems,
            count: 2
        )
        
        // 1 large item with double height of small items
        let largeItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1)
            )
        )

        largeItem.contentInsets = .init(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        // Contains 4 small items and 1 large items
        let group1 = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1/2)
            ),
            subitems: [verticalSmallGroups, largeItem]
        )
        
        // Contains 1 large items first then 4 small items
        let group2 = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1/2)
            ),
            subitems: [largeItem, verticalSmallGroups]
        )
        
        // Combines both groups
        let mainGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(800)
            ),
            subitems: [group1, group2]
        )
        
        let section = NSCollectionLayoutSection(group: mainGroup)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: If you don't want to use diffable style datasource

//extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        50
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
//
//        let cellSerialNumber = indexPath.item + 1
//
//        cell.setup(cellSerialNumber)
//        return cell
//    }
//}
