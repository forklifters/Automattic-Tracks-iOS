import Foundation

extension FileManager {

    var documentsDirectory: URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return URL(fileURLWithPath: documentsDirectory, isDirectory: true)
    }

    func contentsOfDirectory(at url: URL) throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(atPath: url.path).map { url.appendingPathComponent($0) }
    }

    func contents(atUrl url: URL) -> Data? {
        return self.contents(atPath: url.path)
    }

    func fileExistsAtURL(_ url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }

    func directoryExistsAtURL(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        return exists && isDir.boolValue
    }

    func createTempFile(named name: String, containing contents: String?) -> URL {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
        self.createFile(atPath: fileURL.path, contents: contents?.data(using: .utf8), attributes: nil)
        return fileURL
    }
}
