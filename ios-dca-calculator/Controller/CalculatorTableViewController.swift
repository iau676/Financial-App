//
//  CalculatorTableView.swift
//  ios-dca-calculator
//
//  Created by ibrahim uysal on 9.07.2022.
//

import UIKit
import Combine

class CalculatorTableViewController: UITableViewController {
    
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var investmentAmountLabel: UILabel!
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var yieldLabel: UILabel!
    @IBOutlet weak var annualReturnLabel: UILabel!
    @IBOutlet weak var initialInvestmentAmountTextField: UITextField!
    @IBOutlet weak var monthlyDollarCostAveragingTextField: UITextField!
    @IBOutlet weak var initialDateOfInvestmentTextField: UITextField!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var currencyLabels: [UILabel]!
    @IBOutlet weak var investmentAmountCurrencyLabel: UILabel!
    @IBOutlet weak var dateSlider: UISlider!
    
    var asset: Asset?
    
    @Published private var initialDateOfInvestmentIndex: Int?
    @Published private var initialInvestmentAmount: Int?
    @Published private var monthlyDollarCostAveragingAmount: Int?
    
    private var subscribers = Set<AnyCancellable>()
    private let dcaService = DCAService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTextFields()
        setupDateSlider()
        observeForm()
    }
    
    private func setupViews(){
        symbolLabel.text = asset?.searchResult.symbol
        nameLabel.text = asset?.searchResult.name
        investmentAmountCurrencyLabel.text = asset?.searchResult.currency
        currencyLabels.forEach { (label) in
            label.text = asset?.searchResult.currency.addBrackets()
        }
    }
    
    private func setupTextFields(){
        initialInvestmentAmountTextField.addDoneButton()
        monthlyDollarCostAveragingTextField.addDoneButton()
        initialDateOfInvestmentTextField.delegate = self
    }
    
    private func setupDateSlider(){
        if let count = asset?.timeSeriesMonthlyAdjusted.getMonthInfos().count {
            let dateSliderCount = count.floatValue - 1
            dateSlider.maximumValue = dateSliderCount
        }
    }
    
    private func observeForm(){
        $initialDateOfInvestmentIndex.sink { [weak self] (index) in
            guard let index = index else {return}
            self?.dateSlider.value = index.floatValue
            
            if let dateString = self?.asset?.timeSeriesMonthlyAdjusted.getMonthInfos()[index].date.MMYYFormat {
                self?.initialDateOfInvestmentTextField.text = dateString
            }
        }.store(in: &subscribers)
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: initialInvestmentAmountTextField).compactMap({
            ($0.object as? UITextField)?.text
        }).sink { [weak self] (text) in
            self?.initialInvestmentAmount = Int(text) ?? 0
        }.store(in: &subscribers)
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: monthlyDollarCostAveragingTextField).compactMap({
            ($0.object as? UITextField)?.text
        }).sink { [weak self] (text) in
            self?.monthlyDollarCostAveragingAmount = Int(text) ?? 0
        }.store(in: &subscribers)
        
        Publishers.CombineLatest3($initialDateOfInvestmentIndex, $initialInvestmentAmount, $monthlyDollarCostAveragingAmount).sink { [weak self] (initialDateOfInvestmentIndex, initialInvestmentAmount, monthlyDollarCostAveragingAmount) in
            
            guard let initialInvestmentAmount = initialInvestmentAmount,
                  let monthlyDollarCostAveragingAmount = monthlyDollarCostAveragingAmount,
                  let initialDateOfInvestmentIndex = initialDateOfInvestmentIndex,
                  let asset = self?.asset else { return }
            
            let result = self?.dcaService.calculate(asset: asset, initialInvestmentAmount: initialInvestmentAmount.doubleValue,
                                                    monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount.doubleValue,
                                                    initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
            
            let isProfitable = (result?.isProfitable == true)
            let gainSymbol = isProfitable ? "+" : ""
            
            self?.currentValueLabel.backgroundColor = isProfitable ? .themeGreenShade : .themeRedShade
            self?.currentValueLabel.text = result?.currentValue.currencyFormat
            self?.investmentAmountLabel.text = result?.investmentAmount.currencyFormat
            self?.gainLabel.text = result?.gain.toCurrencyFormat(hasDollarSymbol: false, hasDecimalPlaces: false).prefix(withText: gainSymbol)
            self?.yieldLabel.text = result?.yield.stringValue
            self?.annualReturnLabel.text = result?.annualReturn.stringValue
            
        }.store(in: &subscribers)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDateSelection", let dateSelectionTableViewController = segue.destination as? DateSelectionTableViewController,
            let timeSeriesMonthlyAdjusted = sender as? TimeSeriesMonthlyAdjusted {
            dateSelectionTableViewController.timeSeriesMonthlyAdjusted = timeSeriesMonthlyAdjusted
            dateSelectionTableViewController.selectedIndex = initialDateOfInvestmentIndex
            dateSelectionTableViewController.didSelectDate = { [weak self] index in
                self?.handleDateSelection(at: index)
            }
        }
    }
    
    private func handleDateSelection(at index: Int) {
        guard navigationController?.visibleViewController is DateSelectionTableViewController else { return }
        navigationController?.popViewController(animated: true)
        if let monthInfos = asset?.timeSeriesMonthlyAdjusted.getMonthInfos() {
            initialDateOfInvestmentIndex = index
            let monthInfo = monthInfos[index]
            let dateString = monthInfo.date.MMYYFormat
            initialDateOfInvestmentTextField.text = dateString
        }
    }
    
    @IBAction func dateSliderDidChange(_ sender: UISlider) {
        initialDateOfInvestmentIndex = Int(sender.value)
    }
    
}

extension CalculatorTableViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == initialDateOfInvestmentTextField {
            performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAdjusted)
            return false
        }
        return true
    }
    
}
