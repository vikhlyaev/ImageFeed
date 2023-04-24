import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .customBlack
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private var imagesListServiceObserver: NSObjectProtocol?

    private let output: ImagesListOutput
    
    // MARK: - Init
    
    init(output: ImagesListOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupTableView()
        setConstraints()
        setDelegates()
        subscribeToImageListService()
        output.viewIsReady()
    }
    
    // MARK: - Setup UI
    
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
    
    private func setupTableView() {
        tableView.registerReusableCell(cellType: ImagesListCell.self)
    }
    
    private func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func subscribeToImageListService() {
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImagesListService.DidChangeNotification,
                         object: nil,
                         queue: .main,
                         using: { [weak self] _ in
                self?.output.didLoadNextPhoto()
            })
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        output.photosCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(cellType: ImagesListCell.self)
        let photo = output.didRequestPhoto(by: indexPath.row)
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

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = SingleImageViewController()
        let photo = output.didRequestPhoto(by: indexPath.row)
        viewController.imageUrl = photo.largeImageURL
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = output.didRequestPhoto(by: indexPath.row)
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRowIndex {
            output.didLoadNextPhoto()
        }
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = output.didRequestPhoto(by: indexPath.row)
        UIBlockingProgressHUB.show()
        output.didChangeLikeButtonTapped(cell, photoId: photo.id, isLiked: photo.isLiked)
    }
}

// MARK: - ImagesListInput

extension ImagesListViewController: ImagesListInput {
    func updateTableViewAnimated(indexes: Range<Int>) {
        tableView.performBatchUpdates {
            let indexPaths = indexes.map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Попробовать еще раз?",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel)
        let okAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.output.fetchPhotos()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true)
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

