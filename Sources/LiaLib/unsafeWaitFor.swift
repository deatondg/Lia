import Foundation

final class UnsafeWaitForManager<T>: UnsafeSendable {
    var result: T! = nil
    init() {}
}

@discardableResult
public func unsafeWaitFor<T>(_ f: @escaping () async -> T) -> T {
    let sema = DispatchSemaphore(value: 0)
    
    let manager = UnsafeWaitForManager<T>()
    
    Task.detached {
        manager.result = await f()
        sema.signal()
    }
    while sema.wait(timeout: .now() + .seconds(30)) != .success {
        print("unsafeWaitFor is hanging...")
    }
    
    return manager.result
}
