const kImageBase64Galeria =
    "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";

const kImageBase64Clipboar =
    "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";