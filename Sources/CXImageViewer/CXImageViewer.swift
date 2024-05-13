//
//  CXImageViewer.swift
//
//
//  Created by Cunqi Xiao on 4/27/24.
//

import SwiftUI
import Combine

public struct CXImageViewer: UIViewRepresentable {
    public typealias UIViewType = CXImageViewerView
    
    // MARK: - Private properties
    
    /// Combine using with index, this will be used to handle reset zoom
    /// after the index switched
    @Binding private var currentIndex: Int?
    @Binding private var isZooming: Bool
    
    private var index: Int
    private var doubleTapToZoomIn = true
    private let image: UIImage?
    
    // MARK: - Initializer
    
    public init(image: UIImage?, at index: Int = 0) {
        self.image = image
        self.index = index
        self._currentIndex = .constant(0)
        self._isZooming = .constant(false)
    }
    
    // MARK: - Overrides
    
    public func makeUIView(context: Context) -> CXImageViewerView {
        let viewer = CXImageViewerView()
        viewer.viewerDelegate = context.coordinator
        return viewer
    }
    
    public func updateUIView(_ uiView: CXImageViewerView, context: Context) {
        uiView.image = image
        uiView.doubleTapToZoomIn = doubleTapToZoomIn
        zoomOutIfNeeded(viewer: uiView)
    }
    
    public static func dismantleUIView(_ uiView: CXImageViewerView, coordinator: ()) {
        uiView.resetZoom(animated: false)
        uiView.image = nil
    }
    
    // MARK: - Private methods
    
    private func zoomOutIfNeeded(viewer: CXImageViewerView) {
        if index != currentIndex, viewer.isZoomed {
            viewer.resetZoom(animated: false)
        } else if index == currentIndex, viewer.isZoomed, !isZooming {
            viewer.resetZoom(animated: true)
        }
    }
}

extension CXImageViewer {
    public class Coordinator: NSObject, CXImageViewerViewDelegate {
        
        // MARK: - Internal properties
        
        var parent: CXImageViewer
        
        // MARK: - Initializer
        
        init(parent: CXImageViewer) {
            self.parent = parent
        }
        
        // MARK: - CXImageViewerViewDelegate
        
        public func imageViewer(didZoom view: CXImageViewerView, isZooming: Bool) {
            parent.isZooming = isZooming
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension CXImageViewer {
    public func index(_ index: Int) -> Self {
        var imageViewer = self
        imageViewer.index = index
        return imageViewer
    }
    
    public func currentIndex(_ currentIndex: Binding<Int?>) -> Self {
        var imageViewer = self
        imageViewer._currentIndex = currentIndex
        return imageViewer
    }
    
    public func isZooming(_ isZooming: Binding<Bool>) -> Self {
        var imageViewer = self
        imageViewer._isZooming = isZooming
        return imageViewer
    }
    
    public func doubleTapToZoomIn(_ enabled: Bool) -> Self {
        var imageViewer = self
        imageViewer.doubleTapToZoomIn = enabled
        return imageViewer
    }
}
