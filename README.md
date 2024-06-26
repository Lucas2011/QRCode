import UIKit

class CustomTextFieldWithPicker: UITextField, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pickerView: UIPickerView!
    private var _pickerData: [String] = []
    
    @objc public var pickerData: [String] {
        get {
            return _pickerData
        }
        set {
            
            _pickerData = newValue
            DispatchQueue.main.async {
                self.pickerView.reloadAllComponents()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPickerView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPickerView()
    }
    
    private func setupPickerView() {
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.inputView = pickerView
        
        // Create a toolbar for actions above the UIPickerView
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pickerDoneButtonTapped))
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        self.inputAccessoryView = toolbar
    }
    
    override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = super.becomeFirstResponder()
        self.scrollToMatchingText()
        return didBecomeFirstResponder
    }
    
    // MARK: - UIPickerViewDelegate & UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = _pickerData[row]
    }
    
    // MARK: - Toolbar Actions
    
    @objc private func pickerDoneButtonTapped() {
        self.resignFirstResponder()
    }
    
    @objc public func updateToMatchingNumber(devideNumber:String) {
        
        if let matchedString = pickerData.first(where: { $0.contains(devideNumber) }) {
            print("Selected \(matchedString)")

            DispatchQueue.main.async {
                self.text = matchedString
            }
        } else {
            print("No matching data found for \(devideNumber)")
        }
    }
    
    private func scrollToMatchingText() {
        guard let searchText = self.text else { return }
        
        if let index = pickerData.firstIndex(where: { $0.contains(searchText) }) {
            pickerView.selectRow(index, inComponent: 0, animated: true)
            pickerView(pickerView, didSelectRow: index, inComponent: 0)
        }
    }
}

