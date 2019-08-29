import Foundation
import CommonCrypto
import CocoaLumberjack

public class EventLogging {

    /// Provides data required to upload logs
    public var dataSource: EventLoggingDataSource? {
        didSet {
            uploadManager.dataSource = dataSource
        }
    }

    /// Provides callbacks to monitor and control log uploads
    public var delegate: EventLoggingDelegate? {
        didSet {
            uploadManager.delegate = delegate
        }
    }

    private let dispatchQueue = DispatchQueue(label: "event-logging")
    private var timer: DispatchSourceTimer

    internal var uploadQueue = EventLoggingUploadQueue()
    internal var uploadManager = EventLoggingUploadManager()

    public init() {
        self.timer = DispatchSource.makeTimerSource(flags: [], queue: dispatchQueue)
    }

    /// Start uploading available log files, if needed
    func start() {
        self.timer.schedule(deadline: .now(), repeating: .seconds(10))
        self.timer.setEventHandler(handler: self.encryptAndUploadLogsIfNeeded)
        self.timer.resume()
    }

    func pause() {
        self.timer.suspend()
    }

    public func enqueueLogForUpload(log: LogFile) throws {
        try uploadQueue.add(log)
    }

    internal func encryptLog(_ log: LogFile, withKey key: [UInt8]) throws -> LogFile {
        let encryptedURL = try LogEncryptor(withPublicKey: key).encryptLog(log)
        return LogFile(url: encryptedURL, uuid: log.uuid)
    }

    internal func encryptAndUploadLogsIfNeeded() {
        
        guard
            let log = uploadQueue.first,
            let encryptionKey = dataSource?.loggingEncryptionKey
        else {
            return
        }

        let data = Data(base64Encoded: encryptionKey)
        assert(data != nil, "The encryption key is not a valid base64 encoded string")

        dispatchQueue.async {
            do {
                let encryptedLog = try self.encryptLog(log, withKey: [UInt8](data!))
                self.uploadManager.upload(encryptedLog) { result in
                    switch result {
                        case .success:
                            try? self.uploadQueue.remove(log)
                        case .failure(let err):
                            CrashLogging.logError(err)
                    }
                }
            }
            catch let err {
                CrashLogging.logError(err)
            }
        }
    }
}
