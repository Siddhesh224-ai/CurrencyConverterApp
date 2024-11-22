
import Foundation
import SwiftUI


struct ExchangeRatesResponse: Codable {
    let conversion_rates: [String: Double]
}
class ExchangeRateViewModel: ObservableObject {
    @Published var rates: [String: Double] = [:]
    @Published var convertedAmount: Double? = nil
    
    private let apiKey = "54dcd137982020b72c9a6e82"
    private let baseURL = "https://v6.exchangerate-api.com/v6"
    
    // Fetch exchange rates
    func fetchRates() async {
        let urlString = "\(baseURL)/\(apiKey)/latest/USD" // Fetch rates with USD as the base currency
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ExchangeRatesResponse.self, from: data)
            
            // Update rates on the main thread
            DispatchQueue.main.async {
                self.rates = response.conversion_rates
            }
        } catch {
            DispatchQueue.main.async {
                print("Error fetching exchange rates: \(error)")
            }
        }
    }
    
    // Convert the amount from one currency to another
    func convert(amount: Double, from: String, to: String) async {
        guard let fromRate = rates[from], let toRate = rates[to] else {
            print("Invalid currency code or rates not loaded.")
            return
        }
        
        // Convert to USD first, then to the target currency
        let amountInUSD = amount / fromRate
        let result = amountInUSD * toRate
        
        DispatchQueue.main.async {
            self.convertedAmount = result
        }
    }
}

