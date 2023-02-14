# InstaLayout-iOS

## Overview

Instagram like layout using Compositional Layout and Diffable Datasource

This implementation uses the following latest techniques/approaches in Swift released by Apple:

1. Diffable Datasource
2. Compositional Layout (Multisection)
3. Reording in CollectionView with diffable datasource
4. Photo downloading with async-await approach and caching

It also used the latest Async-await approach for downloading Photos from API
But you can simply ignore the data fetching part. As the intention of this project is just to use
Diffable Datasource and Compositonal layout in implementation of Instagram like layout and replace 
the old Flow layout and UICollectionViewDatasource.

## Demo Video


https://user-images.githubusercontent.com/30589979/218257325-23efe24f-b505-4b42-9af7-5357f89c3f92.mp4


## Summary

This code implements a collection view with a diffable data source and two sections. It loads photos from a remote server and displays them in the collection view. The collection view cells can be reordered using drag and drop.

* The code defines a custom section enum `Section` and a struct `Photo` that represents a photo object. 

* The `photoStore` dictionary keeps the photo data for each section. The `configureDatasource` method sets up the diffable data source for the collection view, including cell and header registration, reordering handlers, and supplementary view provider. 

* The `getCompositionalLayout` method defines the layout for the collection view, with two sections, horizontal and vertical grids.

* The `loadPhotos` method asynchronously loads photos for each section from the remote server using PhotoDownloader.shared, which in terms caches the photos downloaded. It updates the photoStore dictionary with the loaded photos and calls the `updateSnapshot` method to update the collection view with the new data.

* The `updateSnapshot` method creates a snapshot of the data and applies it to the diffable data source. The snapshot includes both sections and their corresponding photos.

* The `setupCollectionView` method sets up the collection view's data source, layout, and drag and drop delegates.

Overall, this code implements a multisection collection view with diffable data source using Compositional layout and drag-drop capabilities.

## How to setup and run this project?

* Keep a breath. :D It's damn simple.
* First clone this project or download the project
* If you build and run you supposed to see empty cells. Because I have removed the `clientID` from the `PhotoDownloader`. I have used a free API for downloading photos from https://unsplash.com. I removed my `clientID` because they may block my ID if too many request is sent using my `clientID`.
* Open an account in upnsplash.com and register an app in https://unsplash.com/oauth/applications
* You'll get a `clientID` after completing the process. Ta-da.
* Now in `PhotoDownloader.swift` file replace the following property with your `clientID`:

```
private let clientID = "Your clientID"

```
* Build and run
