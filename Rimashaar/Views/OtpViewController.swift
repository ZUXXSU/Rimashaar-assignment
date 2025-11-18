import UIKit

class OtpViewController: UIViewController {

    // MARK: - Properties
    private let apiService = APIService()

    private var digits: [String] = Array(repeating: "", count: 5) {
        didSet {
            updateOtpFields()
            if digits.allSatisfy({ !$0.isEmpty }) {
                Task { await verifyOtp() }
            }
        }
    }
    private var focusedField: Int? // 0 to 4 for each digit
    
    let firstName: String
    let lastName: String
    let emailOrPhone: String
    let phoneCode: String
    let responseData: RegistrationResponse.UserData
    let registrationData: RegistrationRequest

    private var isLoading = false {
        didSet {
            updateLoadingState()
        }
    }
    private var toastMessage: String?
    private var isShowingToast = false {
        didSet {
            if isShowingToast {
                showToast(message: toastMessage ?? "")
            }
        }
    }
    
    private var resendRemainingTime: Int = 30
    private var timer: Timer?

    // MARK: - UI Elements
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: Constants.Images.logo)
        return imageView
    }()

    private let enterOtpLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.text = "Please enter OTP"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let enterCodeInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.text = "Please enter the 5-digit code that was sent to your email address or phone number"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var otpTextFields: [UITextField] = []
    private let otpStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let resendCodeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.Strings.resendCode, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(resendCodeTapped), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Initialization
    init(firstName: String, lastName: String, emailOrPhone: String, phoneCode: String, responseData: RegistrationResponse.UserData, registrationData: RegistrationRequest) {
        self.firstName = firstName
        self.lastName = lastName
        self.emailOrPhone = emailOrPhone
        self.phoneCode = phoneCode
        self.responseData = responseData
        self.registrationData = registrationData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupConstraints()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startTimer()
        otpTextFields.first?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    // MARK: - Setup
    private func setupUI() {
        view.addSubview(closeButton)
        view.addSubview(logoImageView)
        view.addSubview(enterOtpLabel)
        view.addSubview(enterCodeInfoLabel)
        view.addSubview(otpStackView)
        view.addSubview(resendCodeLabel)
        view.addSubview(resendButton)
        view.addSubview(activityIndicator)

        for i in 0..<5 {
            let textField = UITextField()
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.borderStyle = .roundedRect
            textField.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            textField.delegate = self
            textField.tag = i
            textField.translatesAutoresizingMaskIntoConstraints = false
            otpTextFields.append(textField)
            otpStackView.addArrangedSubview(textField)
        }
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            logoImageView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),

            enterOtpLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            enterOtpLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            enterOtpLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            enterCodeInfoLabel.topAnchor.constraint(equalTo: enterOtpLabel.bottomAnchor, constant: 5),
            enterCodeInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            enterCodeInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            otpStackView.topAnchor.constraint(equalTo: enterCodeInfoLabel.bottomAnchor, constant: 30),
            otpStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            otpStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            otpStackView.heightAnchor.constraint(equalToConstant: 50),
            
            resendCodeLabel.topAnchor.constraint(equalTo: otpStackView.bottomAnchor, constant: 30),
            resendCodeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            resendButton.centerYAnchor.constraint(equalTo: resendCodeLabel.centerYAnchor),
            resendButton.leadingAnchor.constraint(equalTo: resendCodeLabel.trailingAnchor, constant: 5),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }

    private func updateLoadingState() {
        if isLoading {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func resendCodeTapped() {
        Task { await resendCode() }
    }

    // MARK: - Logic
    private func startTimer() {
        timer?.invalidate()
        resendRemainingTime = 30
        updateResendLabel()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.resendRemainingTime > 0 {
                self.resendRemainingTime -= 1
                self.updateResendLabel()
            } else {
                self.timer?.invalidate()
                self.updateResendLabel()
            }
        }
    }
    
    private func updateResendLabel() {
        if resendRemainingTime > 0 {
            resendCodeLabel.text = Constants.Strings.resendCodeIn + " " + String(format: "00:%02d sec", resendRemainingTime)
            resendButton.isHidden = true
        } else {
            resendCodeLabel.text = Constants.Strings.didNotReceiveCode
            resendButton.isHidden = false
        }
    }
    
    private func resendCode() async {
        isLoading = true
        do {
            let response = try await apiService.registerUser(registrationData: registrationData)
            toastMessage = response.message ?? "OTP resent successfully."
            startTimer()
        } catch {
            toastMessage = error.localizedDescription
        }
        isLoading = false
        isShowingToast = true
    }
    
    private func verifyOtp() async {
        let otp = digits.joined()
        guard otp.count == 5 else { return }
        
        isLoading = true
        do {
            guard let userId = responseData.id else {
                toastMessage = "User ID not available for OTP verification."
                isShowingToast = true
                isLoading = false
                return
            }
            let success = try await apiService.verifyOtp(otp: otp, userId: userId)
            if success {
                navigationController?.pushViewController(WelcomeViewController(), animated: true)
            } else {
                // This else block might not be reached if APIError is thrown
                toastMessage = "Invalid OTP"
                isShowingToast = true
            }
        } catch {
            toastMessage = error.localizedDescription
            isShowingToast = true
        }
        isLoading = false
    }
}

// MARK: - UITextFieldDelegate
extension OtpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only allow single digit input
        if string.count == 1 && string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
            digits[textField.tag] = string
            if textField.tag < otpTextFields.count - 1 {
                otpTextFields[textField.tag + 1].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        } else if string.isEmpty { // Handle backspace
            digits[textField.tag] = ""
            if textField.tag > 0 {
                otpTextFields[textField.tag - 1].becomeFirstResponder()
            }
        }
        return false
    }
    
    func updateOtpFields() {
        for (index, digit) in digits.enumerated() {
            otpTextFields[index].text = digit
        }
    }
}

// MARK: - Keyboard Handling
extension OtpViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
