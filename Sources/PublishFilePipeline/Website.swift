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
    func resourcePath(for resource: Path, with context: PublishingContext<Self>) throws -> Path {
        var resource = resource
        if resource.string.starts(with: "/") {
            resource = Path(String(resource.string.dropFirst()))
        }
        
        var possibleOutputFile = PublishPipeline.outputFiles.first { outputFile in
            return outputFile.source.contains { file in
                return file.canonical == resource
            }
        }
        
        if let outputFile = possibleOutputFile {
            return Path("/" + outputFile.canonical.string)
        }
        
        try self.prossesPath(for: resource, with: context)
        
        possibleOutputFile = PublishPipeline.outputFiles.first { outputFile in
           return outputFile.source.contains { file in
               return file.canonical == resource
           }
        }
        
        guard let outputFile = possibleOutputFile else  {
            throw FilePipelineErrors.fileNotFound(for: resource)
        }
        return Path("/" + outputFile.canonical.string)
        
    }
    
    func prossesPath(
        for resource: Path,
        at originPath: Path = "Resources",
        with context: PublishingContext<Self>
    ) throws {
        
        guard !pendingPipeline.contains(resource) else {
            throw FilePipelineErrors.recusiveLookup(for: resource)
        }
        
        pendingPipeline.insert(resource)
        
        defer {
            pendingPipeline.remove(resource)
        }
        
        let folder = try context.folder(at: originPath)
        
        let _pipelineFilter = installedPipelines.first { (filter) -> Bool in
            filter.matches(resource)
        }
        
        guard let pipelineFilter = _pipelineFilter else {
            throw FilePipelineErrors.missingPipeline
        }
        
        var outputs: [PipelineFile]
        
        switch pipelineFilter {
        case .files(_, let pipeline):
            
            let files: [PipelineFile] = Array(folder.files.recursive).compactMap { file in
                guard pipelineFilter.matches(Path(file.path)) else {
                    return nil
                }
                return PipelineFileWrapper(file: file, rootFolder: folder)
            }
            
            for file in files.filter({ $0.canonical != resource }) {
                guard !pendingPipeline.contains(file.canonical) else {
                    throw FilePipelineErrors.recusiveLookup(for: resource)
                }
                
                defer {
                    pendingPipeline.remove(file.canonical)
                }
                pendingPipeline.insert(file.canonical)
            }
            
            let orderd = files.sorted { file1, file2 -> Bool in
                file1.canonical < file1.canonical
            }
            
            outputs = try pipeline.run(with: orderd, on: context)
        case .any(let pipeline):
            let file = try folder.file(at: resource.string)
            
            outputs = try pipeline.run(with: [PipelineFileWrapper(file: file, rootFolder: folder)], on: context)
        }
        
        
        PublishPipeline.outputFiles.append(contentsOf: outputs)
        
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
