import Foundation

extension LiaCache {
    func newFile(withExtension `extension`: String) -> String {
        var fileName: String
        repeat {
            fileName = UUID().uuidString + `extension`
        } while usedFiles.contains(fileName)
        usedFiles.insert(fileName)
        // TODO: Confirm file does not exist yet
        return fileName
    }
    func deleteFile(_ fileName: String) {
        if let _ = usedFiles.remove(fileName) {
            let path = cacheDirectory.appending(component: fileName)
            if path.exists() {
                // TODO: Is this a good idea?
                try! cacheDirectory.appending(component: fileName).deleteFromFilesystem()
            }
        }
    }
}
