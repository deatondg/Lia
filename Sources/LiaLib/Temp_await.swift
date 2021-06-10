import Foundation

public func waitFor(_ f: @escaping () async -> ()) {
    let sema = DispatchSemaphore(value: 0)
    Task.runDetached {
        await f()
        sema.signal()
    }
    sema.wait()
}
