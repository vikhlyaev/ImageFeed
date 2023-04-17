import Foundation

extension URLSession {
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let object = try decoder.decode(T.self, from: data)
                        completion(.success(object))
                    } catch {
                        completion(.failure(NetworkError.parsingJsonError(error)))
                    }
                } else {
                    completion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                completion(.failure(NetworkError.urlRequestError(error)))
            } else {
                completion(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
}
