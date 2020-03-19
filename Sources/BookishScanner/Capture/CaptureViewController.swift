// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import Actions
import ActionsKit

class CaptureViewController: UIViewController, BarcodeScannerDelegate {
    
    @IBOutlet weak var rootStack: UIStackView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var candidatesTable: UITableView!
    @IBOutlet weak var barcodeView: UILabel!
    @IBOutlet weak var lookupSpinner: UIActivityIndicatorView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var barcodeButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchAndStatusStack: UIStackView!
    
    var scanner: BarcodeScanner? = nil
    var lookup: LookupSession? = nil
    var candidates: [LookupCandidate] = []
    var imageLayer: CALayer?
    var lookupManager: LookupManager? = nil
    var observer: Any?
    let itemStore = Application.shared.itemStore

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer, name: HistoryManager.historyUpdatedNotification, object: itemStore)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lookupSpinner.isHidden = true
        imageView.isHidden = true
        barcodeButton.isEnabled = false
        lookupManager = Application.shared.lookupManager
        candidatesTable.dataSource = self
        candidatesTable.delegate = self
        updateCandidateTable(hidden: true, animated: false, label: "scanner.startup".localized)
        observer = NotificationCenter.default.addObserver(forName: HistoryManager.historyUpdatedNotification, object: itemStore, queue: OperationQueue.main) {_ in
            self.searchField.text = nil
            self.updateCandidateTable(hidden: true, animated: true, label: "scanner.startup".localized)
        }
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let scanner = BarcodeScanner(delegate: self) {
            imageView.isHidden = false
            barcodeButton.isEnabled = true
            self.scanner = scanner
            scanner.run()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchField.resignFirstResponder()
        scanner?.shutdown()
        scanner = nil
        lookup = nil
        imageLayer = nil
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        let spacing = CGFloat(rootStack.arrangedSubviews.count - 1) * rootStack.spacing
        imageHeightConstraint.constant = rootStack.frame.height - (searchAndStatusStack.frame.height + spacing)
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageLayer?.frame = imageView.bounds
    }
    
    func detected(barcode value: String) {
        if searchField.text != value {
            let valid = value.isISBN13
            if valid {
                lookup(text: value)
            }
            
            DispatchQueue.main.async {
                let key = valid ? "candidate.lookup.valid" : "candidate.lookup.invalid"
                self.searchField.text = value
                self.barcodeView.text = key.localized(with: ["search": value])
            }
        }
    }
    
    func attach(layer: CALayer) {
        imageView.layer.addSublayer(layer)
        layer.anchorPoint = .zero
        layer.position = .zero
        layer.frame = CGRect(origin: .zero, size: imageView.frame.size)
        imageLayer = layer
    }
    
    func lookup(text: String) {
        lookup?.cancel()
        if let manager = lookupManager {
            lookup = manager.lookup(query: text) { (session, state) in
                self.lookupUpdate(session: session, state: state)
            }
        }
    }
    
    func lookupUpdate(session: LookupSession, state: LookupSession.State) {
        switch state {
            case .starting:
                lookupSpinner.startAnimating()
                lookupSpinner.isHidden = false
                candidates.removeAll()
                updateCandidateTable(hidden: true, animated: true, label: "candidate.lookup.start".localized(with: ["search": session.search]), reload: true)
            
            case .done:
                updateCandidateTable(hidden: false, animated: true, label: "candidate.found".localized(count: candidates.count))
                lookupSpinner.stopAnimating()
                lookupSpinner.isHidden = true
            
            case .foundCandidate(let candidate):
                let row = IndexPath(row: candidates.count, section: 0)
                candidatesTable.beginUpdates()
                updateCandidateTable(hidden: false, animated: true, label: "candidate.found".localized(count: candidates.count))
                candidatesTable.insertRows(at: [row], with: .bottom)
                candidates.append(candidate)
                candidatesTable.endUpdates()
                if candidatesTable.indexPathForSelectedRow == nil {
                    candidatesTable.selectRow(at: row, animated: true, scrollPosition: .bottom)
                }

            case .cancelling:
                updateCandidateTable(hidden: true, animated: true)
            
            default:
                break
        }
    }
    
    func updateCandidateTable(hidden: Bool = false, animated: Bool = true, label: String? = nil, reload: Bool = false) {
        let tableView = candidatesTable!
        let labelView = barcodeView!
        let scannerView = imageView!
        
        labelView.text = label

        let labelHidden = label?.isEmpty ?? true
        let hiddenChanged = (tableView.isHidden != hidden) || (labelView.isHidden != labelHidden)
        let needChange = hiddenChanged || reload
        if needChange {
            let hideScanner = (scanner == nil) || !hidden
            let change = {
                if hiddenChanged {
                    labelView.isHidden = labelHidden
                    tableView.isHidden = hidden
                    scannerView.isHidden = hideScanner
                }
                if reload {
                    tableView.reloadData()
                }
            }
            if animated {
                UIView.animate(withDuration: 0.5, animations: change)
            } else {
                change()
            }
        }
    }
    
    @IBAction func doSearch(_ sender: Any) {
        searchField.resignFirstResponder()
        if let search = searchField.text {
            switch search {
                case "test":
                    detected(barcode: "9781408832240")
                    lookup(text: "9781408832240")
                default:
                    lookup(text: search)
            }
        }
    }
    
    @IBAction func toggleScanner(_ sender: Any) {
        let view = imageView!
        UIView.animate(withDuration: 0.5) {
            view.isHidden = !view.isHidden
        }
    }
    
    @IBAction func textChanged(_ sender: Any) {
        lookup?.cancel()
        updateCandidateTable(hidden: (lookup == nil) || (lookup?.search != searchField.text), animated: true)
    }
    
    @IBAction func imageTapped(_ sender: Any) {
        searchField.resignFirstResponder()
    }
}


extension CaptureViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return candidates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "candidate", for: indexPath) as! CandidateRow
        let candidate = candidates[indexPath.row]
        cell.detailTextLabel?.text = candidate.title
        cell.setup(with: candidate, storyboard: UIStoryboard(name: "Candidate", bundle: nil))
        
        return cell
    }
    
}

extension CaptureViewController: ActionContextProvider {
    func provide(context: ActionContext) {
        context[.query] = lookup?.search
    }
}
