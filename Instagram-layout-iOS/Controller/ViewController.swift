//
//  ViewController.swift
//  Instagram-layout-iOS
//
//  Created by Mahi Al Jawad on 31/12/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Keeps the photo data for both of the sections
    var photoStore: [Section: [Photo]] = [:]
    
    // MARK: Diffable Datasource configuration
    lazy var datasource = configureDatasource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Asynchronously loads photos to the `photoStore`
        // After loading is completed this function also updates
        // collection view using `updateSnapshot()` function
        Task.init {
            await loadPhotos()
        }
        
        setupCollecitonView()
    }
    
    func setupCollecitonView() {
        collectionView.dataSource = datasource
        collectionView.collectionViewLayout = getCompositionalLayout()
        
        // This 2 lines are required to enable drag and drop delegates
        // In order to Reorder collectionview cells
        collectionView.dropDelegate = self
        collectionView.dragDelegate = self
    }
    
    func updateSnapshot() {
        // Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
        snapshot.appendSections([.horizontalGrid, .verticalGrid])
        snapshot.appendItems(photoStore[.horizontalGrid] ?? [], toSection: .horizontalGrid)
        snapshot.appendItems(photoStore[.verticalGrid] ?? [], toSection: .verticalGrid)
        
        datasource.apply(snapshot, animatingDifferences: true)
    }
    
    func loadPhotos() async {
        let resultForHorizontalSection = await PhotoDownloader.shared.fetchPhotos(for: .horizontalGrid)
        
        switch resultForHorizontalSection {
        case .success(let photos):
            self.photoStore[.horizontalGrid] = photos
            print("Photos loaded to horizontal section: \(photos.count)")
            DispatchQueue.main.async {
                self.updateSnapshot()
            }
        case .failure(let error):
            print("Error: \(error.description)")
        }
        
        let resultForVerticalSection = await PhotoDownloader.shared.fetchPhotos(for: .verticalGrid)
        
        switch resultForVerticalSection {
        case .success(let photos):
            print("Photos loaded to vertical section: \(photos.count)")
            self.photoStore[.verticalGrid] = photos
            DispatchQueue.main.async {
                self.updateSnapshot()
            }
        case .failure(let error):
            print("Error: \(error.description)")
        }
    }
    
    func configureDatasource() -> UICollectionViewDiffableDataSource<Section, Photo> {
        // Not required to register cell and configure separately
        // Make sure you don't write reusable ID in the .xib
        let cellRegistration = UICollectionView.CellRegistration<PhotoCell, Photo>(cellNib: UINib(nibName: "PhotoCell", bundle: nil)) { cell, indexPath, photo in
            cell.configure(with: photo.urlString, photoID: photo.ID)
        }
        
        let datasource = UICollectionViewDiffableDataSource<Section, Photo>(collectionView: collectionView) { collectionView, indexPath, photo in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: photo)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<HeaderView>(
            supplementaryNib: UINib(nibName: "HeaderView", bundle: nil),
            elementKind: "HeaderView"
        ) { headerView, elementKind, indexPath in
            let headerTitle = Section.allCases[indexPath.section].sectionTitle
            headerView.configure(with: headerTitle)
        }
        
        datasource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            let header = collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            return header
        }
        
        // MARK: We need this methods for Reordering to work
        datasource.reorderingHandlers.canReorderItem = { photo in
            // This enables every photo to be able to reordered
            // We can also individually return false to make
            // any individual photo not to be reordered
            return true
        }
        
        datasource.reorderingHandlers.didReorder = { [weak self] transaction in
            // We will get a call here after reordering is done
            // We just update our data according to the updated order.
            // This is optional work, the actual use of this block is to
            // update database according to the latest data order (if required
            // to maintain order in the database)
            
            self?.photoStore[.verticalGrid] = transaction.finalSnapshot.itemIdentifiers(inSection: .verticalGrid)
            self?.photoStore[.horizontalGrid] = transaction.finalSnapshot.itemIdentifiers(inSection: .horizontalGrid)
        }
        
        return datasource
    }

    func getCompositionalLayout() -> UICollectionViewLayout { // For single sectin use UICollectionViewCompositionalLayout as return type
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            
            let section = Section.allCases[sectionIndex]
            
            switch section {
            case .horizontalGrid:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1/3),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                
                item.contentInsets = .init(top: 1, leading: 1, bottom: 1, trailing: 1)
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(150)
                    ),
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.orthogonalScrollingBehavior = .continuous
                
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(80)
                    ),
                    elementKind: "HeaderView",
                    alignment: .topLeading
                )
                
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
                
            case .verticalGrid:
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
                
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(80)
                    ),
                    elementKind: "HeaderView",
                    alignment: .topLeading
                )
                
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
            }
        }
        
        return layout
    }
}

// MARK: This methods are required the Reorder feature to work
// Because reorderig includes drag and drop approach
extension ViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        []
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        // Do nothing
    }
}
