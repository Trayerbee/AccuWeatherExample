//
//  Coordinator.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 15/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//


import UIKit
import RxSwift

public protocol CoordinatorResultType {}

protocol CoordinatorType: class {
    associatedtype Result = CoordinatorResultType
    associatedtype Presenter = UIViewController

    static var identifier: String { get }

    var presenter: Presenter { get }

    func results() -> Observable<Result>
}

extension CoordinatorType {

    /// Starts the target Coordinator as a "Child" i.e. that Coordinator chain is started on top of the given pre
    static func startAsChild(coordinatorGenerator: @escaping () -> (Self)) -> Observable<Result> {

        let coordinator = coordinatorGenerator()

        let childCoordinatorLifecycle: Observable<Result> = .create { observer in
            let disposable = coordinator
                .results()
                // If `results` throws an error that reaches here, we can't recover from this
                // so we need to unwind back to when this coordinator began.
                .subscribe(
                    onNext: {
                        (result: Result) in
                        observer.onNext(result)
                        observer.onCompleted()
                },
                    onError: {
                        (error: Error) in

                        // Handle the error here if relevant, otherwise pass it on to the parent coordinator.
                        // We will unwind our stack (see `onErrorRestoreInitialNavStack`) and hopefully the parent catches the error.
                        observer.onError(error)
                },
                    onCompleted: {
                        observer.onCompleted()
                })

            return Disposables.create([
                disposable, Disposables.create {
                    // Hang on to anything that would otherwise be deallocated:
                    _ = coordinator
                }
            ])
        }

        return childCoordinatorLifecycle.do(
            onError: {
                print("'\(self.identifier)' is bubbling up an error: \"\($0)\"")
            },
            onDispose: {
                (coordinator.presenter as? UIViewController)?.dismissOpenAlerts()
            }
        )
    }
}

extension CoordinatorType {

    /// `startAsModal` creates it's own UINavigationController and presents it modally, which the Coordinator itself uses to present onto.
    ///
    /// Roles:
    ///  - The `basePresenter` is the screen below what we’re going to slide up over
    ///  - We create a `modalNavigationController` which is the “platform” the modal screen will be added to. It’s the `modalNavigationController` which slides up over the `basePresenter`.
    ///  - The VC that’s displayed in the root of `modalNavigationController` isn’t even handled in `startAsModal`. That VC is added as the `rootViewController` of  `modalNavigationController` by the Presenting code of whatever coordinator is being presented, e.g. it would be done inside `setRootAsVideoDocDoctorReady`.
    ///
    /// Crucially, the given basePresenter is what is presented *over*.

    static func startAsModal(onBasePresenter basePresenter: UIViewController, _ coordinatorGenerator: @escaping (UINavigationController) -> (Self)) -> Observable<Result> {

        let modalNavigationController = UINavigationController()

        let modalCoordinatorLifecycle: Observable<Result> = .create { observer in

            let coordinator = coordinatorGenerator(modalNavigationController)

            let disposable = coordinator.results()
                .observeOn(MainScheduler.instance)
                .subscribe(
                    onNext: {
                        (result: Result) in

                        modalNavigationController.dismiss(animated: true) {
                            observer.onNext(result)
                            observer.onCompleted()
                        }
                    },
                    onError: {
                        (error: Error) in

                        // Handle the error here if possible, otherwise pass it on
                        modalNavigationController.dismiss(animated: true) {
                            observer.onError(error)
                        }
                    },
                    onCompleted: {
                        modalNavigationController.dismiss(animated: true) {
                            observer.onCompleted()
                        }
                    },
                    onDisposed: {
                        guard !modalNavigationController.isBeingDismissed else { return }
                        // It can happen that the Observable doesn't complete itself but is disposed
                        // externally - in this case make sure we close the modal that we're managing

                        modalNavigationController.dismiss(animated: true) {
                        }
                    }
                )

            DispatchQueue.main.async {
                // Prevents odd animation, seen here: https://github.com/ribot/vhi-mobile/issues/2494
                basePresenter.present(modalNavigationController, animated: true, completion: nil)
            }

            return Disposables.create([
                    disposable,
                    Disposables.create {
                        // Hang on to anything that would otherwise be deallocated:
                        _ = coordinator
                    }
                ])
            }

        // Return the lifecycle, adding lifecycle event handlers:
        return modalCoordinatorLifecycle
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
            .do(
                onError: {
                    print("'\(self.identifier)' is bubbling up an error: \"\($0)\"")
                },
                onDispose: {
                    modalNavigationController.dismissOpenAlerts()
                    purpleScreenOfDeathSavior.onNext(())
                }
            )
    }
}
