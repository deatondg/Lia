import Foundation

extension LiaVersion {
    enum LiaVersionError: Error {
        case mismatchedVersions
    }
    init(ofLibDirectory libDirectory: Path, swiftc: Path) throws {
        let temporaryDirectory = try Path.temporaryDirectory()
        
        let liaSupportVersionExec = temporaryDirectory.appending(component: "LiaSupportVersion")
        let liaDescriptionVersionExec = temporaryDirectory.appending(component: "LiaDescriptionVersion")
        let templateDescriptionVersionExec = temporaryDirectory.appending(component: "TemplateDescriptionVersion")
        
        try LiaBuild.build(
            swiftc: swiftc,
            libDirectory: libDirectory,
            libs: ["LiaSupport"],
            source: Bundle.module.resourcePath!.appending(components: "Resources", "LiaVersion", "LiaSupportVersion.swift"),
            destination: liaSupportVersionExec)
        
        try LiaBuild.build(
            swiftc: swiftc,
            libDirectory: libDirectory,
            libs: ["LiaSupport", "LiaDescription"],
            source: Bundle.module.resourcePath!.appending(components: "Resources", "LiaVersion", "LiaDescriptionVersion.swift"),
            destination: liaDescriptionVersionExec)
        
        try LiaBuild.build(
            swiftc: swiftc,
            libDirectory: libDirectory,
            libs: ["LiaSupport", "TemplateDescription"],
            source: Bundle.module.resourcePath!.appending(components: "Resources", "LiaVersion", "TemplateDescriptionVersion.swift"),
            destination: templateDescriptionVersionExec)
        
        let decoder = JSONDecoder()
        
        let liaSupportVersion = try decoder.decode(LiaVersion.self, from: liaSupportVersionExec.runSync().extractOutput().data(using: .utf8) ?? Data())
        let liaDescriptionVersion = try decoder.decode(LiaVersion.self, from: liaDescriptionVersionExec.runSync().extractOutput().data(using: .utf8) ?? Data())
        let templateDescriptionVersion = try decoder.decode(LiaVersion.self, from: templateDescriptionVersionExec.runSync().extractOutput().data(using: .utf8) ?? Data())
        
        guard liaDescriptionVersion == liaSupportVersion, templateDescriptionVersion == liaSupportVersion else {
            throw LiaVersionError.mismatchedVersions
        }
        
        self = liaSupportVersion
    }
}
