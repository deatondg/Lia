import Foundation

extension LiaVersion {
    enum LiaVersionError: Error {
        case mismatchedVersions
    }
    init(ofLibDirectory libDirectory: Path, swiftc: Path) async throws {
        let temporaryDirectory = try Path.temporaryDirectory()
        
        async let _liaSupportVersion = { () async throws -> LiaVersion in
            let exec = temporaryDirectory.appending(component: "LiaSupportVersion")
            try await timeIt(name: "Compile") {
            try await LiaBuild.build(
                swiftc: swiftc,
                libDirectory: libDirectory,
                libs: ["LiaSupport"],
                source: Bundle.module.liaResourcePath!.appending(components: "Resources", "LiaVersion", "LiaSupportVersion.swift"),
                destination: exec)
            }
            let data = try await timeIt(name: "Run") { try await exec.run(tee: true).extractOutput().data() }
            let result = try timeIt(name: "Decode") { try JSONDecoder().decode(LiaVersion.self, from: data) }
            return result
        }()
        
        async let _liaDescriptionVersion = { () async throws -> LiaVersion in
            let exec = temporaryDirectory.appending(component: "LiaDescriptionVersion")
            try await LiaBuild.build(
                swiftc: swiftc,
                libDirectory: libDirectory,
                libs: ["LiaSupport", "LiaDescription"],
                source: Bundle.module.liaResourcePath!.appending(components: "Resources", "LiaVersion", "LiaDescriptionVersion.swift"),
                destination: exec)
            return try await JSONDecoder().decode(LiaVersion.self, from: exec.run().extractOutput().data())
        }()
        
        async let _templateDescriptionVersion = { () async throws -> LiaVersion in
            let exec = temporaryDirectory.appending(component: "TemplateDescriptionVersion")
            try await LiaBuild.build(
                swiftc: swiftc,
                libDirectory: libDirectory,
                libs: ["LiaSupport", "TemplateDescription"],
                source: Bundle.module.liaResourcePath!.appending(components: "Resources", "LiaVersion", "TemplateDescriptionVersion.swift"),
                destination: exec)
            return try await JSONDecoder().decode(LiaVersion.self, from: exec.run().extractOutput().data())
        }()
        
        let liaSupportVersion = try await _liaSupportVersion
        let liaDescriptionVersion = try await _liaDescriptionVersion
        let templateDescriptionVersion = try await _templateDescriptionVersion
        
        guard liaDescriptionVersion == liaSupportVersion, templateDescriptionVersion == liaSupportVersion else {
            throw LiaVersionError.mismatchedVersions
        }
        
        self = liaSupportVersion
    }
}
