import Foundation

public func unsafeWaitFor(_ f: @escaping () async -> ()) {
    let sema = DispatchSemaphore(value: 0)
    async {
        await f()
        sema.signal()
    }
    sema.wait()
}
