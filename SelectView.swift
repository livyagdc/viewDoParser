//
//  selected.swift
//  FilePicker
//
//  Created by lgc on 27/12/24.
//

import SwiftUI
import AppKit

struct SelectView: View {
    @State var selectedFileURL: URL?
    private var fileCreator = FileCreatorViewModel()

    var body: some View {
        VStack {
            if let selectedFileURL = selectedFileURL {
                Text("Arquivo selecionado: \(selectedFileURL.lastPathComponent)")
                Button(action: {
                    Task {
                        let content = await fileCreator.contentPicker(selectedFileURL: selectedFileURL)
                        await fileCreator.CSVCreator(content: content)
                    }
                }) {
                    Text("Parsear arquivo")
                }
            } else {
                Text("Arraste ou selecione um arquivo")
            }
            
            Button("Selecionar Arquivo") {
                let panel = NSOpenPanel()
                panel.canChooseFiles = true
                panel.canChooseDirectories = false
                panel.allowsMultipleSelection = false
                
                if panel.runModal() == .OK, let url = panel.url {
                    self.selectedFileURL = url
                }
            }
        }
        .frame(width: 300, height: 200)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(12)
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
                print("Provider \(provider)")
                if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                    print("Data \(data)")
                    DispatchQueue.main.async {
                        self.selectedFileURL = url
                    }
                }
            }
            return true
        }
    }
}

#Preview {
    SelectView()
}
