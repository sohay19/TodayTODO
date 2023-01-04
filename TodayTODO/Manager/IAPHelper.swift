//
//  IAPHelper.swift
//  TodayTODO
//
//  Created by 소하 on 2023/01/02.
//

import Foundation
import StoreKit


public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

class IAPHelper: NSObject {
    // 전체 상품
    private let productIdentifiers: Set<String>
    // 구매한 상품
    private var purchasedProductIDList: Set<String> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    
    public init(productIds: Set<String>) {
        productIdentifiers = productIds
        self.purchasedProductIDList = productIds.filter { UserDefaults.shared.bool(forKey: $0) == true }
        super.init()
        // App Store와 지불정보를 동기화하기 위한 Observer 추가
        SKPaymentQueue.default().add(self)
    }
    
    // App Store Connect 인앱결제 상품 로드 요청
    func loadsRequest(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
}

//MARK: - SKProductsRequestDelegate
extension IAPHelper: SKProductsRequestDelegate{
    // 상품 리스트 로드 완료
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
    }
    // 상품 리스트 로드 실패
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    //핸들러 초기화
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }

}

//MARK: - 구매 이력
extension IAPHelper {
    // 구매이력 영수증 가져오기
    func getReceiptData() -> String? {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                return receiptString
            }
            catch {
                print("Couldn't read receipt data with error: " + error.localizedDescription)
                return nil
            }
        }
        return nil
    }
    // 구입 이력 복원
    func restorePurchases() {
        print("==== restorePurchases ====")
        for productID in productIdentifiers {
            print("productID = \(productID)")
            UserDefaults.shared.set(false, forKey: productID)
        }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

//MARK: - 구매
extension IAPHelper {
    // 상품 구입
    func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    // 이미 구매한 상품인가
    func isProductPurchased(_ productID: String) -> Bool {
        return self.purchasedProductIDList.contains(productID)
    }
}

//MARK: - SKPaymentTransactionObserver
extension IAPHelper: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let state = transaction.transactionState
            switch state {
            case .purchased:
                complete(transaction: transaction)
            case .failed:
                fail(transaction: transaction)
            case .restored:
                restore(transaction: transaction)
            case .deferred, .purchasing:
                SystemManager.shared.closeLoading()
            default:
                SystemManager.shared.closeLoading()
            }
        }
    }
    // 구입 성공
    private func complete(transaction: SKPaymentTransaction) {
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        SystemManager.shared.closeLoading()
    }
    // 복원 성공
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        // 구매한 인앱 상품 키에 대한 UserDefaults Bool 값 변경
        purchasedProductIDList.insert(productIdentifier)
        UserDefaults.shared.setValue(true, forKey: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        SystemManager.shared.closeLoading()
    }
    // 구매 실패
    private func fail(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        deliverPurchaseNotificationFor(identifier: nil)
        SKPaymentQueue.default().finishTransaction(transaction)
        SystemManager.shared.closeLoading()
    }
    // 구매 완료 후 조치
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else {
            // 실패 노티 전송
            NotificationCenter.default.post(
                name: .IAPServicePurchaseNotification,
                object: (false, "")
            )
            return
        }
        // 구매한 인앱 상품 키에 대한 UserDefaults Bool 값 변경
        purchasedProductIDList.insert(identifier)
        UserDefaults.shared.setValue(true, forKey: identifier)
        // 성공 노티 전송
        NotificationCenter.default.post(
            name: .IAPServicePurchaseNotification,
            object: (true, identifier)
        )
        SystemManager.shared.closeLoading()
    }
}
