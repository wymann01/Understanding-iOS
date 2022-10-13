import UIKit

class ViewController: UIViewController {
    
    let scrollView = UIScrollView(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    let contentLabel = UILabel(frame: .zero)
    let bottomLabel = UILabel(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupSubviews()
    }
}

extension ViewController {
    func setupSubviews() {
        // 1. 设置 scrollView 的约束
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
            ])
        
        // 2.添加子控件，设置内部约束
        titleLabel.text = "===========titleLabel==========="
        scrollView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            titleLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -10)
            ])
        
        contentLabel.text = "将此处替换为你自己的字符串（超过一屏），即可看见滑动效果"
        contentLabel.numberOfLines = 0
        scrollView.addSubview(contentLabel)
        
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            contentLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            contentLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            contentLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -20),
            ])
        
        scrollView.addSubview(bottomLabel)
        
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            bottomLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            bottomLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            // 3.最后一个 subview,添加跟 scrollView 的约束
            bottomLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10)
            ])
    }
}

