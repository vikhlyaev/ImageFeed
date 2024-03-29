import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .customBlack
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.separatorStyle = .none
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setConstraints()
        setDelegates()
        addImagesListServiceObserver()
        fetchPhotos()
    }
    
    private func setupView() {
        view.addSubview(tableView)
    }
    
    private func setupNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .customBlack
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        
        navigationController?.navigationBar.backgroundColor = .customBlack
    }
    
    private func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func addImagesListServiceObserver() {
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImagesListService.DidChangeNotification,
                         object: nil,
                         queue: .main,
                         using: { [weak self] _ in
                self?.updateTableViewAnimated()
            })
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    private func fetchPhotos() {
        imagesListService.fetchPhotosNextPage { [weak self] error in
            if error != nil { self?.showErrorAlert() }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Попробовать еще раз?",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel)
        let okAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.fetchPhotos()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.identifier, for: indexPath) as? ImagesListCell
        else { return UITableViewCell() }
        
        let photo = photos[indexPath.row]
        
        if let thumbUrl = URL(string: photo.thumbImageURL) {
            cell.cellImageView.kf.indicatorType = .activity
            cell.cellImageView.kf.setImage(with: thumbUrl, placeholder: UIImage(named: "Placeholder")) { [weak self] _ in
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                cell.cellImageView.kf.indicatorType = .none
            }
            cell.dateLabel.text = photo.createdAt != nil ? dateFormatter.string(from: photo.createdAt!) : ""
            cell.setIsLiked(photo.isLiked)
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUB.show()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { result in
            switch result {
            case .success():
                self.photos = self.imagesListService.photos
                cell.setIsLiked(!photo.isLiked)
                UIBlockingProgressHUB.dismiss()
            case .failure(let error):
                UIBlockingProgressHUB.dismiss()
                fatalError(error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = SingleImageViewController()
        viewController.imageUrl = photos[indexPath.row].largeImageURL
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            fetchPhotos()
        }
    }
}

// MARK: - Setting Constraints

extension ImagesListViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

