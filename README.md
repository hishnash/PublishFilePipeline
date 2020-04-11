# PublishFilePipeline

This package aims to provide a simple way to add file prossing pipelines to the Resources when using [Publish](https://github.com/johnsundell/publish).

common usage is to add a hash to the resources filenames. This package supports doing this, and ensures that the links throughout your blog that link to these hased files are correct.

## Usage

```swift
// This will generate your website using the built-in Foundation theme:
try MyWebSite().pipelinePublish(
    withTheme: .container,
    plugins: [
        .pipeline(for: try! RegEx(pattern: #".css$"#), with: [StringReplaceStage(), CacheBustStage()]),
        .pipeline(with: [CacheBustStage()]),
        .markdownPipeline
    ]
)
```

This includes 3 differnt plugins.

### Handing txt based `Resources` that link to other `Resources`

When adding the hash of a file to its filename it is important that all links to this file are updated, this includes links to this file that exist from within your ``Resources`` such as ``CSS`` that might sometimes like the background images.

```swift
.pipeline(for: try! RegEx(pattern: #".css$"#), with: [StringReplaceStage(), CacheBustStage()])
```

This will setup a filter to match any file ending in ``.css`, so that first the file has any refrences to other `Resources`` replaced with the final output filename then it is hashed. This means that if a background image is changed (and thus its hashed filename changes) any css that points at this image will also be changed and its hash will be updated so that browser cache issues to not impact your users.

### Handling any other files

```swift
.pipeline(with: [CacheBustStage()]),
```

This should be the last ``.pipeline`` plugin you define it will catch any files that are not matched by the above filters. In this case it will then hash them and copy the file with the hash in the filename.


### Handeling links to your files

```swift
.markdownPipeline
```

This will attempt to match any links you have to files in your Resousre folder and change them to point to the new filenames (that include the hash).


In your theme template you might also need to refrences files (such as css etc). You can ask for the output (hashed) filename:

```swift
site.resourcePath(for: "/static/red-moa.svg", with: context)
```

