//
//  Context.swift
//  PublishFilePipeline
//
//  Created by Matthaus Woolard on 13/01/2025.
//
import Files

public protocol PipelineContext {
    func folder(at path: PipelinePath) throws -> Folder
    func cacheFile(named: String) throws -> File
    func resourcePath(
        for path: PipelinePath
    ) throws -> PipelinePath
    func copyToOutput(
        _ file: File,
        to path: PipelinePath,
        with string: String
    ) throws
    func createOutputFile(at path: PipelinePath) throws -> File
}
