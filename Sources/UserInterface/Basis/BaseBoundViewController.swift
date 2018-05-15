//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Srdan Rasic (@srdanrasic)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import RxSwift

public class BaseBoundViewController<VM>: UIViewController, NavigationBarStyler {

    // MARK: View Model Methods

    public var viewModel: VM {
        guard let viewModel = _viewModel else {
            fatalError("View Model must not be accessed before view loads.")
        }
        guard let expectedVM = viewModel as? VM else {
            fatalError("Error: given ViewModel was not of expected type \(VM.self)")
        }
        return expectedVM

    }

    private var _viewModel: AnyObject!
    internal var viewModelFactory: ((BaseBoundViewController) -> VM)!

    // MARK: Navigation Bar Styling

    /// Defines which navigation bar style should be used for this VC
    public var navigationBarStyle = NavigationBarStyle.opaquePurpleGradient

    /// Returns the style that should be used for this VC
    final public func preferredNavigationBarStyle() -> NavigationBarStyle {
        return self.navigationBarStyle
    }

    /// The amount of padding required around the overlays
    public var cardOverlayPadding = UIEdgeInsets(top: 53, left: 0, bottom: 4, right: 0)

    // MARK: Constructors

    public init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil, viewModelFactory: @escaping (BaseBoundViewController) -> VM) {
        self.viewModelFactory = viewModelFactory
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public static func create(storyboard: UIStoryboard, viewModelFactory: @escaping (BaseBoundViewController) -> VM) -> BaseBoundViewController {
        guard let viewController = storyboard.instantiateInitialViewController() as? BaseBoundViewController else {
            fatalError("Error: ViewController cannot be cast as BaseBoundViewController. Check you set your ViewController as the initial VC for the Storyboard. Aborting. ")
        }
        viewController.viewModelFactory = viewModelFactory
        return viewController
    }

    internal func bindTo(viewModel: VM) {}

    // MARK: View Controller Lifecycle Methods

    private var isBeingDisplayed: Bool = false

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.clearPlaceholderLabelText()

        let viewModel = viewModelFactory(self)
        _viewModel = viewModel as AnyObject

        viewModelFactory = nil

        if let vm = viewModel as? CardLoadsDataModelType {
            addLoadingOverlay(viewModel: vm)
        }

        bindTo(viewModel: viewModel)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = prefersStatusBarHidden
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isBeingDisplayed = true
        viewDidAppearSink.onNext(())
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isBeingDisplayed = false

        dch_checkDeallocation() // in Development build this double-checks that the VC is deallocated promptly, as expected.
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Hide the keyboard if its still visible
        if viewShouldEndEditingWhenTapped {
            view.endEditing(true)
        }
    }

    // MARK: Status Bar

    /// Defines if this VC should hide the status bar. Because `prefersStatusBarHidden`
    /// is read-only, this is a workaround.
    public var shouldHideStatusBar: Bool = false

    override public var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }

    // MARK: Tap Recognition

    /// Determines whether or not tapping anywhere on the view should disable editing
    internal var viewShouldEndEditingWhenTapped: Bool = false {
        didSet {
            if viewShouldEndEditingWhenTapped {
                view.addGestureRecognizer(tapRecognizer)
            }
            else {
                view.removeGestureRecognizer(tapRecognizer)
            }
        }
    }

    /// Listens for taps on the view
    private(set) lazy var tapRecognizer: UITapGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:)))
        return tapRecognizer
    }()

    /// Hide the keyboard if a subview is being edited
    @objc private func tapped(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    // MARK: Keyboard listening and focuses

    private var focusTextFieldsWithKeyboardListenerBag = DisposeBag()

    /// Listens for keyboard events and automatically focsuses on the provided list of text fields
    public func focusTextFieldsOnSelection(scrollView: UIScrollView, elements: [UIView]) {

        // Flush any prior subscription by resetting the bag:
        focusTextFieldsWithKeyboardListenerBag = DisposeBag()

        keyboardListener().drive(onNext: { [weak self]
            (event) in

            // If we're not in the foreground, then we don't are about keyboard events
            if let isBeingDisplayed = self?.isBeingDisplayed, isBeingDisplayed == false {
                return
            }

            switch event {
            case let .presenting(duration: _, animationCurve: _, keyboardFrame: keyboardFrame):

                // Find the first responder (there is only one)
                for element in elements where element.isFirstResponder {

                    // Bring that element into focus
                    self?.bringTextFieldIntoFocus(scrollView: scrollView, element: element, keyboardFrame: keyboardFrame)
                }
            case .dismissing:

                self?.dismissFocus(scrollView: scrollView)

            default:
                break
            }
        })
        .disposed(by: focusTextFieldsWithKeyboardListenerBag)
    }

    // MARK: ViewDidAppearSink for analytics
    let viewDidAppearSink = PublishSubject<Void>()

    public var didAppearOnScreen: Observable<Void> {
        return self.viewDidAppearSink
    }
}

public func downcast<T, U, D>(closure: @escaping (T) -> D) -> ((U) -> D) {
    return { a in
        guard let downcasted = a as? T else {
            fatalError("Error: Could not downcast from \(T.self) to \(D.self).")
        }
        return closure(downcasted)
    }
}
