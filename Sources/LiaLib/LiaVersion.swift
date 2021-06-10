import Foundation

extension LiaVersion {
    enum LiaVersionError: Error {
        case mismatchedVersions
    }
    init(ofLibDirectory libDirectory: Path, swiftc: Path) async throws {
        let temporaryDirectory = try Path.temporaryDirectory()
        
        let liaSupportVersionExec = temporaryDirectory.appending(component: "LiaSupportVersion")
        let liaDescriptionVersionExec = temporaryDirectory.appending(component: "LiaDescriptionVersion")
        let templateDescriptionVersionExec = temporaryDirectory.appending(component: "TemplateDescriptionVersion")
        
        try await LiaBuild.build(
            swiftc: swiftc,
            libDirectory: libDirectory,
            libs: ["LiaSupport"],
            source: Bundle.module.liaResourcePath!.appending(components: "Resources", "LiaVersion", "LiaSupportVersion.swift"),
            destination: liaSupportVersionExec)
        
        try await LiaBuild.build(
            swiftc: swiftc,
            libDirectory: libDirectory,
            libs: ["LiaSupport", "LiaDescription"],
            source: Bundle.module.liaResourcePath!.appending(components: "Resources", "LiaVersion", "LiaDescriptionVersion.swift"),
            destination: liaDescriptionVersionExec)
        
        try await LiaBuild.build(
            swiftc: swiftc,
            libDirectory: libDirectory,
            libs: ["LiaSupport", "TemplateDescription"],
            source: Bundle.module.liaResourcePath!.appending(components: "Resources", "LiaVersion", "TemplateDescriptionVersion.swift"),
            destination: templateDescriptionVersionExec)
        
        let decoder = JSONDecoder()
        
        let liaSupportVersion = try await decoder.decode(LiaVersion.self, from: liaSupportVersionExec.run().extractOutput().data(using: .utf8) ?? Data())
        let liaDescriptionVersion = try await decoder.decode(LiaVersion.self, from: liaDescriptionVersionExec.run().extractOutput().data(using: .utf8) ?? Data())
        let templateDescriptionVersion = try await decoder.decode(LiaVersion.self, from: templateDescriptionVersionExec.run().extractOutput().data(using: .utf8) ?? Data())
        
        guard liaDescriptionVersion == liaSupportVersion, templateDescriptionVersion == liaSupportVersion else {
            throw LiaVersionError.mismatchedVersions
        }
        
        self = liaSupportVersion
    }
}
