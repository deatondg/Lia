import Foundation

/// This is the dumbest hack I have ever had to do, but apparently this is the officially endorsed solution.
/// See https://stackoverflow.com/questions/67781425/
protocol LiaCacheProtocol: Decodable {}
extension LiaCache: LiaCacheProtocol {}
extension LiaCacheProtocol {
    init(from data: Data, using decoder: JSONDecoder = .init()) throws {
        self = try decoder.decode(Self.self, from: data)
    }
}
