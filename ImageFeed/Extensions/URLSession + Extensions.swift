import Foundation

extension URLSession {
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let object = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(object))
                    } catch {
                        completion(.failure(AppError.Network.parsingJsonError(error)))
                    }
                } else {
                    completion(.failure(AppError.Network.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                completion(.failure(AppError.Network.urlRequestError(error)))
            } else {
                completion(.failure(AppError.Network.urlSessionError))
            }
        })
        return task
    }
}
