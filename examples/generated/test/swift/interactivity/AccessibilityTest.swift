import UIKit
import Foundation

// MARK: - BackgroundImageView

private class BackgroundImageView: UIImageView {
  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)
  }
}

// MARK: - AccessibilityTest

public class AccessibilityTest: UIView {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(customTextAccessibilityLabel: String) {
    self.init(Parameters(customTextAccessibilityLabel: customTextAccessibilityLabel))
  }

  public convenience init() {
    self.init(Parameters())
  }

  public required init?(coder aDecoder: NSCoder) {
    self.parameters = Parameters()

    super.init(coder: aDecoder)

    setUpViews()
    setUpConstraints()

    update()
  }

  // MARK: Public

  public var customTextAccessibilityLabel: String {
    get { return parameters.customTextAccessibilityLabel }
    set {
      if parameters.customTextAccessibilityLabel != newValue {
        parameters.customTextAccessibilityLabel = newValue
      }
    }
  }

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private var row1View = UIView(frame: .zero)
  private var elementView = UIView(frame: .zero)
  private var innerView = UIView(frame: .zero)
  private var containerView = UIView(frame: .zero)
  private var imageView = BackgroundImageView(frame: .zero)
  private var accessibleTextView = UILabel()

  private var accessibleTextViewTextStyle = TextStyles.body1

  private func setUpViews() {
    imageView.isUserInteractionEnabled = false
    imageView.contentMode = .scaleAspectFill
    imageView.layer.masksToBounds = true
    accessibleTextView.isUserInteractionEnabled = false
    accessibleTextView.numberOfLines = 0

    addSubview(row1View)
    row1View.addSubview(elementView)
    row1View.addSubview(containerView)
    elementView.addSubview(innerView)
    containerView.addSubview(imageView)
    containerView.addSubview(accessibleTextView)

    elementView.backgroundColor = Colors.red600
    elementView.isAccessibilityElement = true
    elementView.accessibilityLabel = "Red box"
    elementView.accessibilityHint = "An accessibilty element"
    innerView.backgroundColor = Colors.red800
    containerView.isAccessibilityElement = false
    containerView.accessibilityElements = [accessibleTextView, imageView]
    imageView.image = #imageLiteral(resourceName: "icon_128x128")
    imageView.isAccessibilityElement = true
    imageView.accessibilityLabel = "My image"
    imageView.accessibilityHint = "A cool image"
    accessibleTextView.attributedText = accessibleTextViewTextStyle.apply(to: "Greetings")
    accessibleTextView.isAccessibilityElement = true
    accessibleTextView.accessibilityHint = "Some text"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    row1View.translatesAutoresizingMaskIntoConstraints = false
    elementView.translatesAutoresizingMaskIntoConstraints = false
    containerView.translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    accessibleTextView.translatesAutoresizingMaskIntoConstraints = false

    let row1ViewHeightAnchorParentConstraint = row1View.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor)
    let row1ViewLeadingAnchorConstraint = row1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let row1ViewTrailingAnchorConstraint = row1View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let row1ViewTopAnchorConstraint = row1View.topAnchor.constraint(equalTo: topAnchor)
    let row1ViewBottomAnchorConstraint = row1View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let elementViewHeightAnchorParentConstraint = elementView
      .heightAnchor
      .constraint(lessThanOrEqualTo: row1View.heightAnchor, constant: -20)
    let containerViewHeightAnchorParentConstraint = containerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: row1View.heightAnchor, constant: -20)
    let elementViewLeadingAnchorConstraint = elementView
      .leadingAnchor
      .constraint(equalTo: row1View.leadingAnchor, constant: 10)
    let elementViewTopAnchorConstraint = elementView.topAnchor.constraint(equalTo: row1View.topAnchor, constant: 10)
    let containerViewTrailingAnchorConstraint = containerView
      .trailingAnchor
      .constraint(equalTo: row1View.trailingAnchor, constant: -10)
    let containerViewLeadingAnchorConstraint = containerView
      .leadingAnchor
      .constraint(equalTo: elementView.trailingAnchor, constant: 10)
    let containerViewTopAnchorConstraint = containerView.topAnchor.constraint(equalTo: row1View.topAnchor, constant: 10)
    let containerViewBottomAnchorConstraint = containerView
      .bottomAnchor
      .constraint(equalTo: row1View.bottomAnchor, constant: -10)
    let elementViewHeightAnchorConstraint = elementView.heightAnchor.constraint(equalToConstant: 50)
    let elementViewWidthAnchorConstraint = elementView.widthAnchor.constraint(equalToConstant: 50)
    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: elementView.topAnchor, constant: 10)
    let innerViewBottomAnchorConstraint = innerView
      .bottomAnchor
      .constraint(equalTo: elementView.bottomAnchor, constant: -10)
    let innerViewLeadingAnchorConstraint = innerView
      .leadingAnchor
      .constraint(equalTo: elementView.leadingAnchor, constant: 10)
    let innerViewTrailingAnchorConstraint = innerView
      .trailingAnchor
      .constraint(equalTo: elementView.trailingAnchor, constant: -10)
    let imageViewHeightAnchorParentConstraint = imageView
      .heightAnchor
      .constraint(lessThanOrEqualTo: containerView.heightAnchor)
    let accessibleTextViewHeightAnchorParentConstraint = accessibleTextView
      .heightAnchor
      .constraint(lessThanOrEqualTo: containerView.heightAnchor)
    let imageViewLeadingAnchorConstraint = imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
    let imageViewCenterYAnchorConstraint = imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
    let accessibleTextViewLeadingAnchorConstraint = accessibleTextView
      .leadingAnchor
      .constraint(equalTo: imageView.trailingAnchor, constant: 4)
    let accessibleTextViewTopAnchorConstraint = accessibleTextView
      .topAnchor
      .constraint(equalTo: containerView.topAnchor)
    let accessibleTextViewCenterYAnchorConstraint = accessibleTextView
      .centerYAnchor
      .constraint(equalTo: containerView.centerYAnchor)
    let accessibleTextViewBottomAnchorConstraint = accessibleTextView
      .bottomAnchor
      .constraint(equalTo: containerView.bottomAnchor)
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 50)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 50)

    row1ViewHeightAnchorParentConstraint.priority = UILayoutPriority.defaultLow
    elementViewHeightAnchorParentConstraint.priority = UILayoutPriority.defaultLow
    containerViewHeightAnchorParentConstraint.priority = UILayoutPriority.defaultLow
    imageViewHeightAnchorParentConstraint.priority = UILayoutPriority.defaultLow
    accessibleTextViewHeightAnchorParentConstraint.priority = UILayoutPriority.defaultLow

    NSLayoutConstraint.activate([
      row1ViewHeightAnchorParentConstraint,
      row1ViewLeadingAnchorConstraint,
      row1ViewTrailingAnchorConstraint,
      row1ViewTopAnchorConstraint,
      row1ViewBottomAnchorConstraint,
      elementViewHeightAnchorParentConstraint,
      containerViewHeightAnchorParentConstraint,
      elementViewLeadingAnchorConstraint,
      elementViewTopAnchorConstraint,
      containerViewTrailingAnchorConstraint,
      containerViewLeadingAnchorConstraint,
      containerViewTopAnchorConstraint,
      containerViewBottomAnchorConstraint,
      elementViewHeightAnchorConstraint,
      elementViewWidthAnchorConstraint,
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewTrailingAnchorConstraint,
      imageViewHeightAnchorParentConstraint,
      accessibleTextViewHeightAnchorParentConstraint,
      imageViewLeadingAnchorConstraint,
      imageViewCenterYAnchorConstraint,
      accessibleTextViewLeadingAnchorConstraint,
      accessibleTextViewTopAnchorConstraint,
      accessibleTextViewCenterYAnchorConstraint,
      accessibleTextViewBottomAnchorConstraint,
      imageViewHeightAnchorConstraint,
      imageViewWidthAnchorConstraint
    ])
  }

  private func update() {
    accessibleTextView.accessibilityLabel = customTextAccessibilityLabel
  }
}

// MARK: - Parameters

extension AccessibilityTest {
  public struct Parameters: Equatable {
    public var customTextAccessibilityLabel: String

    public init(customTextAccessibilityLabel: String) {
      self.customTextAccessibilityLabel = customTextAccessibilityLabel
    }

    public init() {
      self.init(customTextAccessibilityLabel: "")
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.customTextAccessibilityLabel == rhs.customTextAccessibilityLabel
    }
  }
}

// MARK: - Model

extension AccessibilityTest {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "AccessibilityTest"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(customTextAccessibilityLabel: String) {
      self.init(Parameters(customTextAccessibilityLabel: customTextAccessibilityLabel))
    }

    public init() {
      self.init(customTextAccessibilityLabel: "")
    }
  }
}
