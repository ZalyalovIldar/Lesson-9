import UIKit

class ViewController: UIViewController {
    
    //MARK: - Properties
    
    private let imageCellIdentifier = "imageCell"
    let dataManager = DataManager.shared
    var isFetching = false
    
    //MARK: - IBOutlets

    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Life circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupDelegate()
    }
}

//MARK: - CollectionView stack

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func setupCollectionView() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = dataManager.fetchResultController.sections?[section]
        print("Количество моделей в БД: \(sectionInfo?.numberOfObjects ?? 0)")
        
        return sectionInfo?.numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let imageModel = dataManager.fetchResultController.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellIdentifier, for: indexPath) as! ImageCell
        cell.setup(for: imageModel.image!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width - 5, height: view.frame.width - 5)
    }
}

//MARK: - Infinity Scrolling Stack

extension ViewController {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height {
            if !isFetching {
                fetchData()
            }
        }
    }

    func fetchData() {

        print("Fetching new data")
        isFetching = true
        dataManager.addImageModels(count: 4)
        isFetching = false
        collectionView.reloadData()
    }
}

//MARK: - CollectionViewHandlerDelegate

extension ViewController: CollectionViewHandlerDelegate {
    
    func setupDelegate() {
        dataManager.collectoinViewHandlerDelegate = self
    }
    
    func insertItems(indexPathArray: [IndexPath]) {
        collectionView.insertItems(at: indexPathArray)
        collectionView.reloadData()
    }
}
