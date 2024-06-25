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


public extension Website {
    
    /**
     Add file programatically using raw Data.
     */
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
        
        PipelineState.shared.add(file: file, at: resource, with: originPath)
    }
    
    
    /**
     Add file programatically using a file on disk.
     */
    func add(
        file: File,
        for resource: Path,
        at originPath: Path = "Resources",
        with context: PublishingContext<Self>
    ) throws {
        let tempFolder = try Folder.temporary.createSubfolder(named: UUID().uuidString)
        let fileToUse = try file.copy(to: tempFolder)
        
        PipelineState.shared.add(file: fileToUse, at: resource, with: originPath)
    }
    
    /**
     Extract the processed File.
     */
    func processedFile(
        for resource: Path,
        at originPath: Path = "Resources",
        with context: PublishingContext<Self>
    ) throws -> File {
        var resource = resource
        if resource.string.starts(with: "/") {
            resource = Path(String(resource.string.dropFirst()))
        }
        
        return try PipelineState.shared.getRawFile(for: resource, root: originPath, with: context).output.file
    }
    
    /**
     Get path for a file after it has passed through the pipeline.
     This ignores any file mutations.
     */
    func resourcePath(
        for resource: Path,
        at originPath: Path = "Resources",
        with context: PublishingContext<Self>
    ) throws -> Path {
        var resource = resource
        if resource.string.starts(with: "/") {
            resource = Path(String(resource.string.dropFirst()))
        }        
        
        return try PipelineState.shared.resolvedPath(
            for: .file(path: resource, root: originPath),
            preprocessor: { EmptySingleFilePipelineStage() },
            on: context
        )
    }
    
    /**
     Get path for a file after it has passed through the pipeline.
     This ignores any file mutations.
     */
    func resourcePath(
        for resource: Path,
        at originPath: Path = "Resources",
        with context: PublishingContext<Self>,
        @PipelineBuilder preprocessor: () -> SingleFilePipelineStage
    ) throws -> Path {
        var resource = resource
        if resource.string.starts(with: "/") {
            resource = Path(String(resource.string.dropFirst()))
        }
        
        return try PipelineState.shared.resolvedPath(
            for: .file(path: resource, root: originPath),
            preprocessor: preprocessor,
            on: context
        )
    }
    
    
    /**
     Get set of Paths for files after they have passed through the mutation for files that match a given type.
     */
    func resourcePath(
        ofType type: String,
        at originPath: Path = "Resources",
        with context: PublishingContext<Self>,
        @PipelineBuilder preprocessor: () -> SingleFilePipelineStage
    ) throws -> Path {
        return try PipelineState.shared.resolvedPath(
            for: .type(extension: type, root: originPath),
            preprocessor: preprocessor,
            on: context
        )
    }
    
    /**
     Get set of Paths for files after they have passed through the mutation for files that match a given type.
     */
    func resourcePath(
        ofType type: String,
        at originPath: Path = "Resources",
        with context: PublishingContext<Self>
    ) throws -> Path {
        return try PipelineState.shared.resolvedPath(
            for: .type(extension: type, root: originPath),
            preprocessor: { EmptySingleFilePipelineStage() },
            on: context
        )
    }

    /// Return the absolute URL for a given path.
    /// - parameter path: The path to return a URL for.
    func resourceUrl(for path: Path, with context: PublishingContext<Self>) -> URL {
        guard !path.string.isEmpty else { return url }
        return url.appendingPathComponent(try! self.resourcePath(for: path, with: context).string)
    }

    
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
                 file: StaticString = #file
    ) throws -> PublishedWebsite<Self> {
        try publish(
            at: path,
            using: [
                .resetPipeline(),
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
                .copyPipelineFiles(),
                .unwrap(deploymentMethod, PublishingStep.deploy)
            ],
            file: file
        )
    }
}
