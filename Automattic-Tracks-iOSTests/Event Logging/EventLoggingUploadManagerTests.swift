import XCTest
@testable import AutomatticTracks

class EventLoggingUploadManagerTests: XCTestCase {
    var uploadManager = EventLoggingUploadManager()
    var networkService = MockEventLoggingNetworkService()
    var delegate: MockEventLoggingDelegate!

    override func setUp() {
        delegate = MockEventLoggingDelegate()
        networkService = MockEventLoggingNetworkService()

        uploadManager.networkService = networkService
        uploadManager.dataSource = MockEventLoggingDataSource()
        uploadManager.delegate = delegate
    }

    func testThatDelegateIsNotifiedOfNetworkStartAndCompletionForSuccess() {

        let exp = XCTestExpectation()
        uploadManager.upload(MockLogFile.withRandomString, then:  { _ in exp.fulfill() })
        self.wait(for: [exp], timeout: 1.0)

        XCTAssertTrue(delegate.didStartUploadingTriggered)
        XCTAssertTrue(delegate.didFinishUploadingTriggered)
        XCTAssertFalse(delegate.uploadCancelledByDelegateTriggered)
    }


    func testThatDelegateIsNotifiedOfNetworkStartForFailure() {

        let exp = XCTestExpectation()
        networkService.shouldSucceed = false
        uploadManager.upload(MockLogFile.withRandomString, then:  { _ in exp.fulfill() })
        self.wait(for: [exp], timeout: 1.0)

        XCTAssertTrue(delegate.didStartUploadingTriggered)
        XCTAssertFalse(delegate.didFinishUploadingTriggered)
        XCTAssertFalse(delegate.uploadCancelledByDelegateTriggered)
    }

    func testThatNetworkStartDoesNotFireWhenDelegateCancelsUpload() {
        let exp = XCTestExpectation()

        delegate.setShouldUploadLogFiles(false)
        delegate.uploadCancelledByDelegateCallback = { _ in exp.fulfill() }
        uploadManager.upload(MockLogFile.withRandomString, then:  { _ in XCTFail("Callback should not be called") })
        self.wait(for: [exp], timeout: 1.0)

        XCTAssertFalse(delegate.didStartUploadingTriggered)
        XCTAssertFalse(delegate.didFinishUploadingTriggered)
        XCTAssertTrue(delegate.uploadCancelledByDelegateTriggered)
    }
}
