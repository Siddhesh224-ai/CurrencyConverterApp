import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ExchangeRateViewModel()
    @State private var fromCurrency: String = "USD"
    @State private var toCurrency: String = "EUR"
    @State private var amount: String = "0"
    
    private let backgroundColor = Color.gray.opacity(0.1)
    private let pickerBackgroundColor = Color.blue.opacity(0.1)
    private let textFieldBackgroundColor = Color.white
    private let resultBackgroundColor = Color.green.opacity(0.2)
   
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(.dollarSymbol)
                    .resizable()
                    .frame(width: 100, height:100)
                    .clipShape(Circle())
                
                Text("Currency Converter")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                  
            }
                    
            VStack(spacing: 20) {
                HStack(alignment: .center) {
                    Text("From Currency")
                        .font(.headline)
                    Spacer()
                    Picker("From", selection: $fromCurrency) {
                        ForEach(viewModel.rates.keys.sorted(), id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(pickerBackgroundColor)
                    .cornerRadius(10)
                    .onChange(of: fromCurrency) { _ in
                        performConversion()
                    }
                }
                
                Button(action: {
                    let temp = fromCurrency
                    fromCurrency = toCurrency
                    toCurrency = temp
                    performConversion()
                }) {
                    Text("Swap")
                        .font(.headline)
                }
                
                HStack(alignment: .center) {
                    Text("To Currency")
                        .font(.headline)
                    Spacer()
                    Picker("To", selection: $toCurrency) {
                        ForEach(viewModel.rates.keys.sorted(), id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(pickerBackgroundColor)
                    .cornerRadius(10)
                    .onChange(of: toCurrency) { _ in
                        performConversion()
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Amount")
                        .font(.headline)
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(textFieldBackgroundColor)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .onChange(of: amount) { _ in
                            performConversion()
                        }
                }
                
                if let result = viewModel.convertedAmount {
                    HStack(alignment: .center) {
                        Text("Converted Amount")
                            .font(.headline)
                        Text("\(result, specifier: "%.2f") \(toCurrency)")
                            .font(.body)
                            .padding()
                            .background(resultBackgroundColor)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()

            .cornerRadius(20)
            .shadow(radius: 10)
            
            Spacer()
        }
        .task {
            await viewModel.fetchRates()
        }
    }
    
    private func performConversion() {
        if let amountValue = Double(amount), !amount.isEmpty {
            Task {
                await viewModel.convert(amount: amountValue, from: fromCurrency, to: toCurrency)
            }
        }
    }
}

#Preview {
    ContentView()
}


