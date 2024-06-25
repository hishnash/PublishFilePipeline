//
//  PipelineState.swift
//  
//
//  Created by Matthaus Woolard on 23/06/2024.
//
import Dispatch
import Publish
import Files

internal class PipelineState {
    static var shared = PipelineState()
    
    private var queue = DispatchQueue(label: "Pipeline", attributes: [])
    private var concurrentQueue = DispatchQueue(label: "Pipeline.concurrent", attributes: [.concurrent])

    private var output: [FileKey: PipelineFile] = [:]
    private var pendingPipelines: [FileKey: DispatchSemaphore] = [:]

    struct AdditionalFileKey: Hashable {
        let path: Path
        let root: Path
    }
    
    private var additionalInputFiles: [AdditionalFileKey: File] = [:]
    
    private var pipelines: [Pipeline] = []
    
    func resolvedPath<Site: Website>(
        for query: FileQuery,
        @PipelineBuilder preprocessor: () -> SingleFilePipelineStage,
        on context: PublishingContext<Site>
    ) throws -> Path {
        try concurrentQueue.sync {
            try self._resolvedPath(for: query, preprocessor: preprocessor, on: context)
        }
    }
    
    private func _resolvedPath<Site: Website>(
        for query: FileQuery,
        @PipelineBuilder preprocessor: () -> SingleFilePipelineStage,
        on context: PublishingContext<Site>
    ) throws -> Path {
        let preprocessor = preprocessor()
        if let path = self.getCanonicalPathFromOutput(for: query, with: preprocessor) {
            return path
        }
        let key = FileKey(query, preprocessor: preprocessor)
        
        let pendingSemaphore: DispatchSemaphore? = queue.sync {
            if let semaphore = self.pendingPipelines[key] {
                return semaphore
            }
            self.pendingPipelines[key] = Dispatch.DispatchSemaphore(value: 0)
            return nil
        }
        
        if let pendingSemaphore {
            pendingSemaphore.wait()
            if let path = self.getCanonicalPathFromOutput(for: query, with: preprocessor) {
                return path
            }
            throw FilePipelineErrors.concurrentError
        }
        defer {
            self.queue.sync {
                let semaphore = self.pendingPipelines.removeValue(forKey: key)
                semaphore?.signal()
            }
        }
        
        let pipeline = self.pipelines.first { $0.matches(query: query) }
        guard let pipeline else { throw FilePipelineErrors.missingPipeline }
        let file = try pipeline.run(query: query, preprocessor: preprocessor, on: context, with: self)
        self.addResolved(file: file, with: key)
        return file.canonical
    }
    
    internal func addResolved(file: PipelineFile, with key: FileKey) {
        self.queue.sync {
            self.output[key] = file
        }
    }
    
    private func getCanonicalPathFromOutput(
        for query: FileQuery,
        with preprocessor: SingleFilePipelineStage
    ) -> Path? {
        self.queue.sync {
            return self.output[FileKey(query, preprocessor: preprocessor)]?.canonical
        }
    }
    
    
    internal func getRawFiles<Site: Website>(for query: FileQuery, with context: PublishingContext<Site>) throws -> [PipelineFile] {
        switch query {
        case .file(let path, let root):
            return [try self.getRawFile(for: path, root: root, with: context)]
        case .type(let fileExtension, let root):
            let projectRoot = try context.folder(at: "")
            let rootFolder = try context.folder(at: root)
            var files: [PipelineFile] = rootFolder.files.recursive.filter { file in
                file.extension == fileExtension
            }.map { file in
                let path = Path(file.path(relativeTo: projectRoot))
                return PipelineFileWrapper(file: file, path: path)
            }
            files +=  self.queue.sync {
                self.additionalInputFiles.compactMap { (key, value) -> PipelineFile?  in
                    guard key.root == root else { return nil }
                    guard key.path.extension == fileExtension else {
                        return nil
                    }
                    return PipelineFileWrapper(file: value, path: key.path)
                }
            }
            
            files.sort { a, b -> Bool in
                a.canonical < b.canonical
            }
            
            return files
        }
    }
    
    internal func getRawFile<Site: Website>(
        for path: Path,
        root: Path,
        with context: PublishingContext<Site>
    ) throws -> PipelineFile {
        let additionalInputFile = self.queue.sync {
            self.additionalInputFiles[AdditionalFileKey(path: path, root: root)]
        }
        if let additionalInputFile {
            return PipelineFileWrapper(file: additionalInputFile, path: path)
        }
        let file = try context.folder(at: root).file(at: path.string)
        return PipelineFileWrapper(file: file, path: path)
    }
    
    internal func getAllOutputs() -> [any PipelineFile] {
        self.queue.sync { () -> [any PipelineFile] in
            Array(self.output.values)
        }
    }
    
    internal func addPipeline(_ pipeline: Pipeline) {
        self.pipelines.append(pipeline)
    }
    
    internal func add(file: File, at path: Path, with root: Path) {
        self.queue.sync {
            self.additionalInputFiles[AdditionalFileKey(path: path, root: root)] = file
        }
    }
    
    public func load(manifest: StaticManifest) {
        self.queue.sync {
            self.output = manifest.asPipelineFiles
        }
    }
    
    public func getStaticOutputs() -> [FileKey: Path] {
        self.queue.sync {
            self.output.mapValues { file in
                file.canonical
            }
        }
    }
}


