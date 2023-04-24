import Foundation

protocol ImagesListInput: AnyObject {
    func updateTableViewAnimated(indexes: Range<Int>)
    func showErrorAlert()
}
