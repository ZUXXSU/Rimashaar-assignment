import UIKit

class RegistrationViewController: UIViewController {

    // MARK: - Properties
    private let apiService = APIService()

    private var firstName: String = ""
    private var lastName: String = ""
    private var emailOrPhone: String = ""
    private var phoneCode: String = "91"

    private var firstNameError: String?
    private var lastNameError: String?
    private var emailPhoneError: String?

    private let countryCodes = ["91", "1", "44", "81", "33"]

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

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()

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
        // Assuming Constants.Images.logo is a valid image name in your assets
        imageView.image = UIImage(named: Constants.Images.logo)
        return imageView
    }()

    private let signUpTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.text = Constants.Strings.signUp
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pleaseEnterInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.text = Constants.Strings.pleaseEnterInfo
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var firstNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.Strings.firstName
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.tag = 0 // Tag for firstName
        return textField
    }()

    private lazy var lastNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.Strings.lastName
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.tag = 1 // Tag for lastName
        return textField
    }()
    
    private lazy var emailOrPhoneField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.Strings.emailOrPhone
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.delegate = self
        textField.tag = 2 // Tag for emailOrPhone
        return textField
    }()
    
    private lazy var countryCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+\(phoneCode)", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 70).isActive = true
        button.addTarget(self, action: #selector(showCountryCodePicker), for: .touchUpInside)
        return button
    }()

    private lazy var getOtpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.Strings.getOtp.uppercased(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.backgroundColor = UIColor(named: "SystemBrown") ?? .brown // Assuming SystemBrown is defined or use a default
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(getOtpButtonTapped), for: .touchUpInside)
        return button
    }()

    private let orRegisterWithLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.text = Constants.Strings.orRegisterWith
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let socialLoginButtonsView = SocialLoginButtonsView() // Reusing the UIKit version of this view

    private let haveAnAccountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = Constants.Strings.haveAnAccount
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.Strings.signIn, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var nameStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [firstNameField, lastNameField])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var emailPhoneStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [countryCodeButton, emailOrPhoneField])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var dividerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [createDivider(), orRegisterWithLabel, createDivider()])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var signInStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [haveAnAccountLabel, signInButton])
        stack.axis = .horizontal
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()
        setupUI()
        setupConstraints()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupUI() {
        contentView.addSubview(closeButton)
        contentView.addSubview(logoImageView)
        contentView.addSubview(signUpTitleLabel)
        contentView.addSubview(pleaseEnterInfoLabel)
        
        contentView.addSubview(nameStack)
        contentView.addSubview(emailPhoneStack)
        contentView.addSubview(getOtpButton)
        contentView.addSubview(dividerStack)
        contentView.addSubview(socialLoginButtonsView)
        contentView.addSubview(signInStack)
        
        socialLoginButtonsView.translatesAutoresizingMaskIntoConstraints = false // Ensure this is set
        
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func createDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .lightGray
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            logoImageView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 100), // Adjust height as needed

            signUpTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            signUpTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            signUpTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            pleaseEnterInfoLabel.topAnchor.constraint(equalTo: signUpTitleLabel.bottomAnchor, constant: 5),
            pleaseEnterInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            pleaseEnterInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            nameStack.topAnchor.constraint(equalTo: pleaseEnterInfoLabel.bottomAnchor, constant: 20),
            nameStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            emailPhoneStack.topAnchor.constraint(equalTo: nameStack.bottomAnchor, constant: 20),
            emailPhoneStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailPhoneStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            getOtpButton.topAnchor.constraint(equalTo: emailPhoneStack.bottomAnchor, constant: 30),
            getOtpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            getOtpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            dividerStack.topAnchor.constraint(equalTo: getOtpButton.bottomAnchor, constant: 30),
            dividerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dividerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            socialLoginButtonsView.topAnchor.constraint(equalTo: dividerStack.bottomAnchor, constant: 20),
            socialLoginButtonsView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            signInStack.topAnchor.constraint(equalTo: socialLoginButtonsView.bottomAnchor, constant: 30),
            signInStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signInStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20) // Ensure content view can scroll
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
            getOtpButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
            getOtpButton.isEnabled = true
        }
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func showCountryCodePicker() {
        let alert = UIAlertController(title: "Select Country Code", message: nil, preferredStyle: .actionSheet)
        for code in countryCodes {
            alert.addAction(UIAlertAction(title: "+\(code)", style: .default, handler: { _ in
                self.phoneCode = code
                self.countryCodeButton.setTitle("+\(code)", for: .normal)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc private func getOtpButtonTapped() {
        Task {
            await registerUser()
        }
    }

    @objc private func signInButtonTapped() {
        // Handle sign in navigation
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Logic
    private func validateFields() -> Bool {
        firstNameError = firstName.isEmpty ? "First name cannot be empty." : (!firstName.isValidName() ? "First name can only contain letters." : nil)
        lastNameError = lastName.isEmpty ? "Last name cannot be empty." : (!lastName.isValidName() ? "Last name can only contain letters." : nil)
        emailPhoneError = (emailOrPhone.isValidEmail || emailOrPhone.isValidPhoneNumber) ? nil : "Please enter a valid 10-digit phone number or email address."
        
        // Update UI for errors
        firstNameField.layer.borderColor = firstNameError == nil ? UIColor.lightGray.cgColor : UIColor.red.cgColor
        lastNameField.layer.borderColor = lastNameError == nil ? UIColor.lightGray.cgColor : UIColor.red.cgColor
        emailOrPhoneField.layer.borderColor = emailPhoneError == nil ? UIColor.lightGray.cgColor : UIColor.red.cgColor

        return firstNameError == nil && lastNameError == nil && emailPhoneError == nil
    }
    
    private func registerUser() async {
        if validateFields() {
            isLoading = true
            
            let registrationData = RegistrationRequest(
                appVersion: "1.0",
                deviceModel: "iPhone",
                deviceToken: "",
                deviceType: "I",
                dob: "",
                email: emailOrPhone.isValidEmail ? emailOrPhone : "",
                firstName: firstName,
                gender: "",
                lastName: lastName,
                newsletterSubscribed: 0,
                osVersion: "17.0",
                password: "",
                phone: emailOrPhone.isValidPhoneNumber ? emailOrPhone : "",
                phoneCode: phoneCode
            )
            
            do {
                let response = try await apiService.registerUser(registrationData: registrationData)
                if response.success && response.status == 200 {
                    if let userData = response.data {
                        let otpVC = OtpViewController(
                            firstName: firstName,
                            lastName: lastName,
                            emailOrPhone: emailOrPhone,
                            phoneCode: phoneCode,
                            responseData: userData,
                            registrationData: registrationData
                        )
                        navigationController?.pushViewController(otpVC, animated: true)
                    } else {
                        toastMessage = "Registration successful, but missing user data."
                        isShowingToast = true
                    }
                } else {
                    toastMessage = response.message ?? "Registration failed with an unexpected status."
                    isShowingToast = true
                }
            } catch {
                toastMessage = error.localizedDescription
                isShowingToast = true
            }
            
            isLoading = false
        }
    }
}

// MARK: - UITextFieldDelegate
extension RegistrationViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField.tag {
        case 0: firstName = textField.text ?? ""
        case 1: lastName = textField.text ?? ""
        case 2: emailOrPhone = textField.text ?? ""
            if emailOrPhone.isNumeric {
                textField.keyboardType = .phonePad
            } else {
                textField.keyboardType = .emailAddress
            }
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Keyboard Handling
extension RegistrationViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
