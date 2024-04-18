//
//  ViewController.swift
//  CacheImagesAssignment
//
//  Created by Srinivas Gadda on 16/04/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    private let minNumberOfColumns: Int = 3
    
    private let viewModel: MediaCoveragesViewModel = MediaCoveragesViewModel(apiClient: MediaCoveragesAPI())
    private let monitor: NetworkMonitor = NetworkMonitor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForMediaCoverages()
    }
    
    func checkForMediaCoverages() {
        if monitor.status == .connected {
            Task {
                do {
                    try await viewModel.fetchMediaCoverages()
                    await MainActor.run {
                        collectionView.reloadData()
                    }
                    
                    //Download all images in backgground thread
                    Task(priority: .background) {
                        await viewModel.fetchAllThumbnails()
                    }
                    
                } catch {
                    await MainActor.run {
                        //If service got failed, given an option to retry
                        let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                            self?.checkForMediaCoverages()
                        }
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                            
                        }
                        presentErrorAlert(title: "Error", message: "Something went wrong while retrieving media coverages. Please try again!", buttons: [retryAction, cancelAction])
                    }
                }
            }
        } else {
            let okAction = UIAlertAction(title: "Ok", style: .cancel) { _ in }
            presentErrorAlert(title: "No Network Connectivity!", message: "Please check with your network connection", buttons: [okAction])
        }
    }
    
    private func presentErrorAlert(title: String, message: String, buttons: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        buttons.forEach { action in
            alertController.addAction(action)
        }
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
    //Return number of items in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: "ThumbnailCell",
              for: indexPath) as! ThumbnailCell
        cell.configureCell(with: viewModel, at: indexPath)
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    // Return the size for an item
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (collectionView.frame.size.width-20.0)/CGFloat(minNumberOfColumns)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
