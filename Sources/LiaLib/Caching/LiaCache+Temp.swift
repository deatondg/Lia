extension LiaCache {
    func setCache<P: CacheableProcedure>(_: P.Type, context: P.Context, value: CacheTable.EntryContainer<P>) {
        self.cacheTable[P.self, context] = value
    }
    func insertCacher(_ cacher: Cacher) {
        self.activeCachers.insert(cacher)
    }
    func commitCacher(_ cacher: Cacher) {
        self.savedFiles.formUnion(cacher.files)
    }
}
