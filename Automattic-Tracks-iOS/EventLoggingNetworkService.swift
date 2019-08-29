import Foundation

typealias NetworkResultCallback = (Result<Data?, Error>) -> Void

open class EventLoggingNetworkService {

    func uploadFile(request: URLRequest, fileURL: URL, completion: @escaping NetworkResultCallback) {
        URLSession.shared
            .uploadTask(with: request, fromFile: fileURL, completionHandler: { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse {
                if !(200 ... 299).contains(response.statusCode) {
                    let errorMessage = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                    completion(.failure(UploadError.httpError(errorMessage)))
                    return
                }
            }

            completion(.success(data))
        }).resume()
    }
}
