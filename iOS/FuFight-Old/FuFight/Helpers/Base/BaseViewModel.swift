//
//  BaseViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/25/24.
//

import Foundation

class BaseViewModel: ViewModel {
    var dismissAction: (() -> Void)?
    @Published var isAlertPresented: Bool = false
    private(set) var alertTitle = ""
    private(set) var alertMessage = ""
    private(set) var error: MainError? = nil
    ///Set this to nil in order to remove this global loading indicator, empty string will show it but have empty message
    @Published private(set) var loadingMessage: String? = nil

    //MARK: - ViewModel Overrides

    func onAppear() { }

    func onDisappear() { }

    func updateError(_ newError: MainError?) {
        updateLoadingMessage(to: nil)
        if let newError {
            LOGE(newError.fullMessage, from: BaseViewModel.self)
            error = newError
            updateAlert(newError.title, message: newError.message)
        } else {
            error = nil
        }
        DispatchQueue.main.async {
            self.isAlertPresented = newError != nil
        }
    }

    func updateLoadingMessage(to message: String?) {
        DispatchQueue.main.async {
            self.loadingMessage = message
        }
    }

    func dismissView() {
        dismissAction?()
    }
}

private extension BaseViewModel {
    func updateAlert(_ title: String, message: String?) {
        alertTitle = title
        if let message {
            alertMessage = message
        }
    }
}
