//
//  PDFView.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/23.
//

import SwiftUI
import AppKit
import PDFKit

// From https://stackoverflow.com/a/61480852/9376340
struct PDFRepresentedView: NSViewRepresentable {
    
    var pdfDocument: PDFDocument

    func makeNSView(context: NSViewRepresentableContext<PDFRepresentedView>) -> PDFRepresentedView.NSViewType {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        return pdfView
    }

    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<PDFRepresentedView>) {
        // Update the view.
    }
}
