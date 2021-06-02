import LiaSupport
import Foundation
print(String(data: try! JSONEncoder().encode(LiaSupportVersion), encoding: .utf8)!)
