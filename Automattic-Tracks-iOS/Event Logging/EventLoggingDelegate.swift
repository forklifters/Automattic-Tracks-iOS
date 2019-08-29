public protocol EventLoggingDelegate {
    /// The event logging system will call this delegate property prior to attempting to upload, giving the application a chance to determine
    /// whether or not the upload should proceed. If this is not overridden, the default is `true`.
    var shouldUploadLogFiles: Bool { get }

    /// The event logging system will call this delegate method each time an log file starts uploading.
    func didStartUploadingLog(_ log: LogFile)

    /// The event logging system will call this delegate method if a log file upload is cancelled by the delegate
    func uploadCancelledByDelegate(_ log: LogFile)

    /// The event logging system will call this delegate method if a log file fails to upload
    func uploadFailed(withError: Error, forLog: LogFile)

    /// The event logging system will call this delegate method each time an log file finishes uploading
    func didFinishUploadingLog(_ log: LogFile)
}

/// Default implementations for EventLoggingDelegate
public extension EventLoggingDelegate {
    var shouldUploadLogFiles: Bool {
        return true
    }

    func didStartUploadingLog(_ log: LogFile) {
        // Do nothing
    }

    func uploadCancelledByDelegate(_ log: LogFile) {
        // Do nothing
    }

    func uploadFailed(withError error: Error, forLog log: LogFile) {
        // Do nothing
    }

    func didFinishUploadingLog(_ log: LogFile) {
        // Do nothing
    }
}
