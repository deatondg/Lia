import LiaDescription
import Foundation
print(String(data: try! JSONEncoder().encode(LiaDescriptionVersion), encoding: .utf8)!)
