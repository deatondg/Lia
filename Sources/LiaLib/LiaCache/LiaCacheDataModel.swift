public class LiaCacheDataModel: Codable {
    let swiftVersion: SwiftVersion
    
    let liaVersion: LiaVersion
    
    let usedFiles: Set<String>
   
    let liaDescriptionCache: [LiaCache.LiaDescriptionContext: String]
    let templateDescriptionCache: [LiaCache.TemplateDescriptionContext: String]
    let templateHeaderAndBodyCache: [LiaCache.TemplateHeaderAndBodyContext: LiaCache.TemplateHeaderAndBodyLocation]
    
    init(
        swiftVersion: SwiftVersion,
        liaVersion: LiaVersion,
        usedFiles: Set<String>,
        liaDescriptionCache: [LiaCache.LiaDescriptionContext: String],
        templateDescriptionCache: [LiaCache.TemplateDescriptionContext: String],
        templateHeaderAndBodyCache: [LiaCache.TemplateHeaderAndBodyContext: LiaCache.TemplateHeaderAndBodyLocation]
    ) {
        self.swiftVersion = swiftVersion
        self.liaVersion = liaVersion
        self.usedFiles = usedFiles
        self.liaDescriptionCache = liaDescriptionCache
        self.templateDescriptionCache = templateDescriptionCache
        self.templateHeaderAndBodyCache = templateHeaderAndBodyCache
    }
}
