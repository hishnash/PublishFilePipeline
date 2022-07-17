//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Publish
import Files
import Plot
import RegEx


public extension Website {
    func add(
        resource data: Data,
        for resource: Path,
        at originPath: Path = "Resources",
        with context: PublishingContext<Self>
    ) throws {
        var resource = resource
        if resource.string.starts(with: "/") {
            resource = Path(String(resource.string.dropFirst()))
        }
        
        let tempFolder = try Folder.temporary.createSubfolder(named: UUID().uuidString)
        let file = try tempFolder.createFile(at: resource.string, contents: data)
        PublishPipeline.state.set(file: file, for: resource, at: originPath)
    }
    
    func resourcePath(
        for resource: Path,
        at originPath: Path = "Resources",
        with context: PublishingContext<Self>
    ) throws -> Path {
        var resource = resource
        if resource.string.starts(with: "/") {
            resource = Path(String(resource.string.dropFirst()))
        }
        
        var possibleOutputFile = PublishPipeline.state.outputFiles.first { outputFile in
            return outputFile.source.contains { file in
                return file.canonical == resource
            }
        }
                
        if let outputFile = possibleOutputFile {
            return Path("/" + outputFile.canonical.string)
        }
        
        try self.processPath(for: resource, at: originPath, with: context)
        
        possibleOutputFile = PublishPipeline.state.outputFiles.first { outputFile in
           return outputFile.source.contains { file in
               return file.canonical == resource
           }
        }
        
        guard let outputFile = possibleOutputFile else  {
            throw FilePipelineErrors.fileNotFound(for: resource)
        }
        return Path("/" + outputFile.canonical.string)
        
    }
    
    func resourcePaths(
        ofType type: String,
        at originPath: Path = "Resources",
        with context: PublishingContext<Self>
    ) throws -> Set<Path> {

        let paths: [Path] = try self.files(at: originPath, with: context).compactMap { (file, path) in
            guard file.extension == type else {
                return nil
            }
            return path
        }
        var resolvedPaths: Set<Path> = []
        for path in paths {
            resolvedPaths.insert(
                try self.resourcePath(for: path, with: context)
            )
        }
        return resolvedPaths
    }
    
    
    func file(
        for resource: Path,
        at originPath: Path = "Resources",
        with context: PublishingContext<Self>
    ) throws -> File {
        if let file = PublishPipeline.state.additionalFiles[originPath]?[resource] {
            return file
        }
        let folder = try context.folder(at: originPath)
        return try folder.file(at: resource.string)
    }
    
    func files(
        at originPath: Path = "Resources",
        with context: PublishingContext<Self>
    ) throws -> [(file: File, path: Path)] {
        let files = PublishPipeline.state.additionalFiles[originPath, default: [:]].map { (path, file) in
            return (file: file, path: path)
        }
        
        let folder = try context.folder(at: originPath)
        let realFiles = Array(folder.files.recursive).map { file in
            let path = Path(file.path(relativeTo: folder))
            return (file: file, path: path)
        }
        
        return files + realFiles
    }
    
    func processPath(
        for resource: Path,
        at originPath: Path = "Resources",
        with context: PublishingContext<Self>
    ) throws {
        
        guard !pendingPipeline.contains(resource) else {
            throw FilePipelineErrors.recursiveLookup(for: resource)
        }
        
        pendingPipeline.insert(resource)
        
        defer {
            pendingPipeline.remove(resource)
        }
                
        let _pipelineFilter = installedPipelines.first { (filter) -> Bool in
            filter.matches(resource)
        }
        
        guard let pipelineFilter = _pipelineFilter else {
            throw FilePipelineErrors.missingPipeline
        }
        
        var outputs: [PipelineFile]
        
        switch pipelineFilter {
        case .files(_, let pipeline):
            
            let allFiles = try self.files(at: originPath, with: context)
            let files: [(path: Path, file: PipelineFile)] = allFiles.compactMap { (file, path) in
                guard pipelineFilter.matches(path) else {
                    return nil
                }
                return (path, PipelineFileWrapper(file: file, path: path))
            }
            
            for (path, _) in files.filter({ $0.path != resource }) {
                guard !pendingPipeline.contains(path) else {
                    throw FilePipelineErrors.recursiveLookup(for: resource)
                }
                
                defer {
                    pendingPipeline.remove(path)
                }
                pendingPipeline.insert(path)
            }
            
            let ordered = files.sorted { a, b -> Bool in
                a.path < b.path
            }.map { (_, file) in
                return file
            }
            
            outputs = try pipeline.run(with: ordered, on: context)
        case .any(let pipeline):
            let file = try self.file(for: resource, at: originPath, with: context)
            outputs = try pipeline.run(
                with: [PipelineFileWrapper(file: file, path: resource)],
                on: context
            )
        }
        
        
        PublishPipeline.state.add(outputs: outputs)
        
        for output in outputs {
            for wrappedFile in output.output {
                try context.copyToOutput(
                    wrappedFile.file,
                    to: wrappedFile.canonical.deletingLastPathComponent()
               )
            }
        }
    }
}


public extension Website {
    /// Return the absolute URL for a given path.
    /// - parameter path: The path to return a URL for.
    func resourceUrl(for path: Path, with context: PublishingContext<Self>) -> URL {
        guard !path.string.isEmpty else { return url }
        return url.appendingPathComponent(try! self.resourcePath(for: path, with: context).string)
    }
}


var installedPipelines: [PublishPipelineFilter] = []
var pendingPipeline: Set<Path> = []


public extension Website {
    /// Publish this website using a default pipeline. To build a completely
    /// custom pipeline, use the `publish(using:)` method.
    /// - parameter theme: The HTML theme to generate the website using.
    /// - parameter indentation: How to indent the generated files.
    /// - parameter path: Any specific path to generate the website at.
    /// - parameter rssFeedSections: What sections to include in the site's RSS feed.
    /// - parameter rssFeedConfig: The configuration to use for the site's RSS feed.
    /// - parameter deploymentMethod: How to deploy the website.
    /// - parameter additionalSteps: Any additional steps to add to the publishing
    ///   pipeline. Will be executed right before the HTML generation process begins.
    /// - parameter plugins: Plugins to be installed at the start of the publishing process.
    /// - parameter file: The file that this method is called from (auto-inserted).
    /// - parameter line: The line that this method is called from (auto-inserted).
    @discardableResult
    func pipelinePublish(withTheme theme: Theme<Self>,
                 indentation: Indentation.Kind? = nil,
                 at path: Path? = nil,
                 rssFeedSections: Set<SectionID> = Set(SectionID.allCases),
                 rssFeedConfig: RSSFeedConfiguration? = .default,
                 deployedUsing deploymentMethod: DeploymentMethod<Self>? = nil,
                 additionalSteps: [PublishingStep<Self>] = [],
                 plugins: [Plugin<Self>] = [],
                 file: StaticString = #file) throws -> PublishedWebsite<Self> {
        try publish(
            at: path,
            using: [
                .group(plugins.map(PublishingStep.installPlugin)),
                .addMarkdownFiles(),
                .sortItems(by: \.date, order: .descending),
                .group(additionalSteps),
                .generateHTML(withTheme: theme, indentation: indentation),
                .unwrap(rssFeedConfig) { config in
                    .generateRSSFeed(
                        including: rssFeedSections,
                        config: config
                    )
                },
                .generateSiteMap(indentedBy: indentation),
                .unwrap(deploymentMethod, PublishingStep.deploy)
            ],
            file: file
        )
    }
}
