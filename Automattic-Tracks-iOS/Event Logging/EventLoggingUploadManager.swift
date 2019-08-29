import Foundation
import CocoaLumberjack
import Sodium

public typealias LogUploadCallback = (Result<Void, Error>) -> Void

class EventLoggingUploadManager {

    internal var networkService = EventLoggingNetworkService()

    internal var dataSource: EventLoggingDataSource?
    internal var delegate: EventLoggingDelegate?

    func upload(_ log: LogFile, then callback: @escaping LogUploadCallback) {

        guard self.delegate?.shouldUploadLogFiles ?? true else {
            self.delegate?.uploadCancelledByDelegate(log)
            return
        }

        guard let url = self.dataSource?.logUploadURL else {
            assertionFailure("You must set the data source prior to attempting an upload")
            return
        }

        guard let fileContents = FileManager.default.contents(atUrl: log.url) else {
            self.delegate?.uploadFailed(withError: UploadError.fileMissing, forLog: log)
            return
        }

        var request = URLRequest(url: url)
        request.addValue(log.uuid, forHTTPHeaderField: "log-uuid")
        request.httpMethod = "POST"
        request.httpBody = fileContents

        self.delegate?.didStartUploadingLog(log)

        networkService.uploadFile(request: request, fileURL: log.url) { result in
            switch(result) {
                case .success:
                    self.delegate?.didFinishUploadingLog(log)
                    callback(.success(()))
                case .failure(let error):
                    self.delegate?.uploadFailed(withError: error, forLog: log)
                    callback(.failure(error))
            }
        }
    }
}
