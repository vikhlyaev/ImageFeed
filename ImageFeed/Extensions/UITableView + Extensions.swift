import UIKit

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension UITableViewCell: Reusable {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}

extension UITableView {
    func dequeueReusableCell<Cell: UITableViewCell & Reusable>(cellType: Cell.Type) -> Cell {
        dequeueReusableCell(withIdentifier: cellType.reuseIdentifier) as! Cell
    }

    func registerReusableCell<Cell: UITableViewCell & Reusable>(cellType: Cell.Type) {
        register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
}

