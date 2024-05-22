//
//  CXImageViewerView.swift
//
//
//  Created by Cunqi Xiao on 4/27/24.
//

import UIKit

import Venus

public protocol CXImageViewerViewDelegate: AnyObject {
    func imageViewer(didZoom view: CXImageViewerView, isZooming: Bool)
}

public class CXImageViewerView: UIScrollView {
    
    // MARK: - Constants
    
    public static let minZoomLevel = 1.0
    public static let maxZoomLevel = 4.0
    
    private static let zoomAnimationDuration = 0.25
    
    // MARK: - Public properties
    
    public var image: UIImage? {
        get {
            imageView.image
        }
        set {
            guard let image = newValue else {
                return
            }
            setupImageView(with: image)
        }
    }
    
    public var isZoomed: Bool {
        zoomScale > minimumZoomScale
    }
    
    public weak var viewerDelegate: CXImageViewerViewDelegate?
    
    public var doubleTapToZoomIn: Bool = true
    
    // MARK: - Initializers
    
    public init() {
        super.init(frame: .zero)
        addSubview(imageView)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private properties
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
        return imageView
    }()
    
    private lazy var doubleTapGestureRecognizer: UIGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.numberOfTapsRequired = 2
        gestureRecognizer.addTarget(self, action: #selector(handleDoubleTapGesture(_:)))
        return gestureRecognizer
    }()
    
    /// Ideally, most image can not fill on screen perfectly, this origin is reprensting
    /// the origin of the image rect when loaded on screen
    private var imageOnScreenInitialOrigin: CGPoint {
        CGPoint(
            x: (viewerSize.width - imageOnScreenInitialSize.width) / 2.0,
            y: (viewerSize.height - imageOnScreenInitialSize.height) / 2.0)
    }
    
    /// Image origin size when loaded on screen, no zoomed, this will be used to
    /// calculate tap location and other information for zooming in/out
    private var imageOnScreenInitialSize: CGSize {
        let ratio = imageSize.whRatio
        
        if (viewerSize.width / ratio) <= viewerSize.height {
            return CGSize(width: viewerSize.width, height: viewerSize.width / ratio)
        } else {
            return CGSize(width: viewerSize.height * ratio, height: viewerSize.height)
        }
    }
    
    /// Stores the image initial position and size info
    private var imageOnScreenInitialRect: CGRect {
        CGRect(origin: imageOnScreenInitialOrigin, size: imageOnScreenInitialSize)
    }
    
    private var viewerSize: CGSize {
        bounds.size
    }
    
    private var imageSize: CGSize {
        imageView.image?.size ?? .square(1.0) // Avoid divide 0 crash
    }
    
    // MARK: - Public methods
    
    /// Reset the image viewer to the initial state
    public func resetZoom(animated: Bool) {
        let actions = { [unowned self] in
            zoomScale = minimumZoomScale
            imageView.frame = CGRect(origin: .zero, size: viewerSize)
            contentSize = viewerSize
            contentOffset = .zero
        }
        
        let completion: (Bool) -> Void = { [weak self] _ in
            guard let self else {
                return
            }
            viewerDelegate?.imageViewer(didZoom: self, isZooming: false)
        }
        
        if animated {
            animate(actions, completion: completion)
        } else {
            actions()
            completion(true)
        }
    }
    
    public func clear() {
        imageView.image = nil
    }
    
    
    // MARK: - Private methods
    
    private func setupImageView(with image: UIImage) {
        setupMandantoryConfig()
        imageView.image = image
        maximumZoomScale = makeMaximumZoomScale()
    }
    
    private func setupMandantoryConfig() {
        minimumZoomScale = Self.minZoomLevel
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        contentInsetAdjustmentBehavior = .automatic
        delegate = self
        
        if imageView.superview == nil {
            addSubview(imageView)
        }
    }
    
    private func makeMaximumZoomScale() -> CGFloat {
        let multiplier: CGFloat
        if imageOnScreenInitialSize.width < viewerSize.width {
            multiplier = viewerSize.width / imageOnScreenInitialSize.width
        } else {
            multiplier = viewerSize.height / imageOnScreenInitialSize.height
        }
        return max(multiplier, Self.maxZoomLevel)
    }
    
    @objc
    private func handleDoubleTapGesture(_ recognizer: UIGestureRecognizer) {
        if contentSize > viewerSize {
            resetZoom(animated: true)
        } else if doubleTapToZoomIn {
            zoomInOnDoubleTapped(location: recognizer.location(in: imageView))
        }
    }
    
    private func zoomInOnDoubleTapped(location: CGPoint) {
        // Check if the user really tapped on the image instead of empty space around the image
        guard imageOnScreenInitialRect.contains(location) else {
            return
        }
        
        // Find the right zoomed size and multipler when double tapped
        
        let zoomedSize: CGSize
        let multiplier: CGFloat
        
        if imageOnScreenInitialSize.width < viewerSize.width {
            multiplier = viewerSize.width / imageOnScreenInitialSize.width
            zoomedSize = CGSize(width: viewerSize.width, height: viewerSize.height * multiplier)
        } else {
            multiplier = viewerSize.height / imageOnScreenInitialSize.height
            zoomedSize = CGSize(width: viewerSize.width * multiplier, height: viewerSize.height)
        }
        let zoomedRect = CGRect(origin: .zero, size: zoomedSize)
        let zoomedVisibleRect = closestVisibleRect(for: location, zoomedRect: zoomedRect)
        
        animate { [unowned self] in
            zoomScale = multiplier
            imageView.frame = zoomedRect
            contentSize = zoomedSize
            scrollRectToVisible(zoomedVisibleRect, animated: false)
        } completion: { [weak self] _ in
            guard let self else {
                return
            }
            viewerDelegate?.imageViewer(didZoom: self, isZooming: true)
        }
    }
    
    private func closestVisibleRect(for location: CGPoint, zoomedRect: CGRect) -> CGRect {
        let locationOnInitialImage = CGPoint(
            x: location.x - imageOnScreenInitialOrigin.x,
            y: location.y - imageOnScreenInitialOrigin.y)
        
        let axisXRatio = locationOnInitialImage.x / imageOnScreenInitialSize.width
        let axisYRatio = locationOnInitialImage.y / imageOnScreenInitialSize.height
        
        let zoomedCenter = CGPoint(
            x: axisXRatio * zoomedRect.width,
            y: axisYRatio * zoomedRect.height)
        
        let zoomedTargetOrigin = CGPoint(
            x: zoomedCenter.x - viewerSize.width / 2.0,
            y: zoomedCenter.y - viewerSize.height / 2.0)
        
        let zoomedTargetRect = CGRect(origin: zoomedTargetOrigin, size: viewerSize)
        
        return zoomedRect.intersection(zoomedTargetRect)
    }
    
    private func animate(_ actions: @escaping () -> Void, completion: @escaping (Bool) -> Void = { _ in }) {
        UIView.animate(withDuration: Self.zoomAnimationDuration, animations: actions, completion: completion)
    }
}

// MARK: UIScrollViewDelegate

extension CXImageViewerView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        animate { [unowned self] in
            if imageOnScreenInitialSize.height * scale < viewerSize.height {
                imageView.frame = CGRect(
                    origin: .zero,
                    size: CGSize(width: scrollView.contentSize.width, height: scrollView.bounds.height))
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
            } else if imageOnScreenInitialSize.width * scale < viewerSize.width {
                imageView.frame = CGRect(
                    origin: .zero,
                    size: CGSize(width: scrollView.bounds.width, height: scrollView.contentSize.height))
                scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
            } else {
                imageView.frame = CGRect(origin: .zero, size: imageOnScreenInitialSize * scale)
            }
            
            scrollView.contentSize = imageView.frame.size
        } completion: { [weak self] _ in
            guard let self else {
                return
            }
            viewerDelegate?.imageViewer(didZoom: self, isZooming: scale > minimumZoomScale)
        }
    }
}
