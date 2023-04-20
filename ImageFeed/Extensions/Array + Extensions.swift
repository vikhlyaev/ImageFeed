import Foundation

extension Array where Element == Photo {
    func withReplaced(itemAt index: Int, newValue: Photo) -> [Photo] {
        var newArray = self
        newArray.replaceSubrange(index...index, with: [newValue])
        return newArray
    }
}
