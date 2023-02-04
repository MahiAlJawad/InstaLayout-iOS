//
//  ViewController.swift
//  Instagram-layout-iOS
//
//  Created by Mahi Al Jawad on 31/12/22.
//

import UIKit

// MARK: Structs for Data Parsing

struct APIResponse: Codable {
    let id: String
    let urls: PhotoURL
}

struct PhotoURL: Codable {
    let regular: String
}

// MARK: For simplicity folder structure/ design pattern not matained

enum Section: CaseIterable {
    case horizontalGrid
    case verticalGrid
    
    var sectionTitle: String {
        switch self {
        case .horizontalGrid: return "Horizontal Section"
        case .verticalGrid:   return "Vertical Section"
        }
    }
}

struct Photo: Hashable {
    let ID: String
    let urlString: String
}

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let clientID = ""
    var urlString: String {
        "https://api.unsplash.com/photos?client_id=\(clientID)&page=1&per_page="
    }
    
    // This information is supposed to be in viewModel
    // And should be fetched from any API or database
    var horizontalPhotoStore: [Photo] = []
    
    var verticalPhotoStore: [Photo] = []
    
    lazy var datasource = configureDatasource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get dummy photo data
//        horizontalPhotoStore = getPhoto(10)
//        verticalPhotoStore = getPhoto(25)
        
        setupCollecitonView()
        updateSnapshot()
        
        fetchPhotos(10)
    }
    
    func fetchPhotos(_ numberOfPhotos: Int) {
        guard let url = URL(string: urlString+"\(numberOfPhotos)") else {
            print("Failed making url")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data = data  else {
                print("Found error in URL data task")
                return
            }
            
            do {
                let result = try JSONDecoder().decode([APIResponse].self, from: data)
                print("Successfully parsed data")
                
                let photos = result.reduce(into: [Photo]()) { result, apiResponse in
                    let photo = Photo(ID: apiResponse.id, urlString: apiResponse.urls.regular)
                    result.append(photo)
                }
            } catch {
                print("Error: \(error)")
            }
        }
        
        task.resume()
    }
    
    func configureDatasource() -> UICollectionViewDiffableDataSource<Section, Photo> {
        // Not required to register cell and configure separately
        // Make sure you don't write reusable ID in the .xib
        let cellRegistration = UICollectionView.CellRegistration<PhotoCell, Photo>(cellNib: UINib(nibName: "PhotoCell", bundle: nil)) { cell, indexPath, photo in
            cell.configure()
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
        
        return datasource
    }
    
    func updateSnapshot() {
        // Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
        snapshot.appendSections([.horizontalGrid, .verticalGrid])
        snapshot.appendItems(horizontalPhotoStore, toSection: .horizontalGrid)
        snapshot.appendItems(verticalPhotoStore, toSection: .verticalGrid)
        
        datasource.apply(snapshot, animatingDifferences: true)
    }
    
    func setupCollecitonView() {
        collectionView.dataSource = datasource
        collectionView.collectionViewLayout = getCompositionalLayout()
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
