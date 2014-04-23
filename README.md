##MERThumbnailManager

A library for generating thumbnails from urls, both local and remote. Built on top of [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa), compatible with iOS, 7.0+.

Use the `thumbnailForURL:size:page:time:` method and its variants to generate thumbnails for a given url.

###Documentation

The headers are documented. Read them.

###Tests

Soon.

##Supported Formats

The library supports the following UTIs:

* kUTTypeImage (public.image)
* kUTTypeMovie (public.movie)
* kUTTypePDF__*__ (com.adobe.pdf)
* kUTTypeRTF__*__ (public.rtf)
* kUTTypeRTFD__*__ (com.apple.rtfd)
* kUTTypePlainText__*__ (public.plain-text)
* kUTTypeHTML__*__ (public.html)

Additionally it supports Microsoft Office documents:

* Word__*__ (.doc, .docx)
* Powerpoint__*__ (.ppt, .pptx)
* Excel__*__ (.xls, .xlsx)

UTIs marked with a * indicate only local thumbnail generation is supported for that UTI.

##Demo

The demo will load up anything it finds in a directory named "Files" within the main bundle. It creates and displays the thumbnails within a `UICollectionView`.