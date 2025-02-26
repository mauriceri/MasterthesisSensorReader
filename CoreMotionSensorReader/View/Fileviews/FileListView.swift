import SwiftUI
import UniformTypeIdentifiers

struct FileListView: View {
    @State private var files: [String] = []
    @State private var selectedFiles: Set<String> = []
    @State private var isSharing = false
    
    var body: some View {
        NavigationView {
            List(files, id: \..self, selection: $selectedFiles) { file in
                HStack {
                    Text(file)
                    Spacer()
                    Button(action: {
                        shareSelectedFiles()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .navigationTitle("Gespeicherte Dateien")
            .onAppear(perform: loadFiles)
            .toolbar {
                EditButton()
            }
            .sheet(isPresented: $isSharing, content: {
                let fileURLs = selectedFiles.compactMap { getFileURL(named: $0) }
                if !fileURLs.isEmpty {
                    ShareSheet(activityItems: fileURLs)
                } else {
                    Text("Keine Datei gefunden")
                }
            })
        }
    }
    
    func loadFiles() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        do {
            let allFiles = try fileManager.contentsOfDirectory(atPath: documentsURL.path)
            files = allFiles.filter { $0.hasSuffix(".csv") }
        } catch {
            print("Fehler beim Laden der Dateien: \(error)")
        }
    }
    
    func getFileURL(named fileName: String) -> URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentsURL.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    func shareSelectedFiles() {
        isSharing = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct FileListView_Previews: PreviewProvider {
    static var previews: some View {
        FileListView()
    }
}
