import Foundation

enum AppError {
    
    enum Network: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
        case parsingJsonError(Error)
        case badRequest
    }
    
}

