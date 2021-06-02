import TemplateDescription
import Foundation
print(String(data: try! JSONEncoder().encode(TemplateDescriptionVersion), encoding: .utf8)!)
