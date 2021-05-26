struct LiaDescription {
    let actions: [LiaAction]
    //public let dependencies: [Package.Dependency]
    let bundles: [TemplateBundle]
    
    init(fromDescription description: LocatedLiaDescription) throws {
        self.actions = description.actions.map(\.value)
        self.bundles = try description.bundles.map(TemplateBundle.init(fromDescription:))
        
        // TODO: Verify invariants
    }
}
