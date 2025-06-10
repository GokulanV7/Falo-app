# Falo - AI-Powered Misinformation Detection

Falo is an intelligent assistant that helps you verify information and detect potential misinformation in text and URLs. Built with Flutter and powered by advanced AI, Falo provides instant credibility assessments to help you navigate the digital information landscape with confidence.

## 🌟 Key Features

- **AI-Powered Analysis**: Instantly assess the credibility of any text or URL
- **Comprehensive Reports**: Get detailed breakdowns of information reliability
- **Voice Input**: Use voice commands for hands-free verification
- **Dark Mode**: Comfortable viewing in any lighting condition
- **Cross-Platform**: Available on iOS, Android, and web

## 🏗 Project Structure

```
Falo/
├── Frontend/           # Flutter mobile application
│   └── Falo/          # Main Flutter project
├── backend/            # Python backend service
│   └── misinfo_detection_project/
│       ├── api/       # FastAPI endpoints
│       ├── config/     # Configuration files
│       └── data/       # Data storage and processing
└── Falotestphoto/      # Screenshots and demo assets
```

## 🚀 Getting Started

### Prerequisites

- **For Mobile Development**:
  - Flutter SDK (latest stable version)
  - Android Studio / Xcode
  - VS Code or Android Studio (recommended)

- **For Backend Development**:
  - Python 3.8+
  - pip (Python package manager)
  - Virtual environment (recommended)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/GokulanV7/Falo-app.git
   cd Falo
   ```

2. **Set up the backend**
   ```bash
   cd backend/misinfo_detection_project
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Set up the mobile app**
   ```bash
   cd ../../Frontend/Falo
   flutter pub get
   ```

4. **Run the applications**
   - Backend: `uvicorn api.main:app --reload`
   - Mobile: `flutter run`

## 📱 Screenshots

<div align="center">
  <h3>App Walkthrough</h3>
  
  <div style="display: flex; flex-wrap: wrap; justify-content: center; gap: 20px; margin-bottom: 30px;">
    <div style="flex: 1; min-width: 280px; max-width: 320px;">
      <img src="Falotestphoto/IMG_5909.PNG" alt="Welcome Screen" style="width: 100%; border-radius: 12px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);"/>
      <h4>1. Welcome to Falo</h4>
      <p>Your intelligent shield against misinformation. Get started with a clean, friendly interface.</p>
    </div>
    
    <div style="flex: 1; min-width: 280px; max-width: 320px;">
      <img src="Falotestphoto/IMG_5910.PNG" alt="Analysis Features" style="width: 100%; border-radius: 12px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);"/>
      <h4>2. Analyze Anything</h4>
      <p>Paste text or a URL. Falo assesses credibility, checks safety, and detects potential bias in seconds.</p>
    </div>
    
    <div style="flex: 1; min-width: 280px; max-width: 320px;">
      <img src="Falotestphoto/IMG_5911.PNG" alt="Get Started" style="width: 100%; border-radius: 12px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);"/>
      <h4>3. Stay Informed</h4>
      <p>Your reliable guide to verified knowledge. Get started with confidence.</p>
    </div>
  </div>

  <div style="display: flex; flex-wrap: wrap; justify-content: center; gap: 20px; margin-top: 20px;">
    <div style="flex: 1; min-width: 280px; max-width: 320px;">
      <img src="Falotestphoto/IMG_5912.PNG" alt="Chat Interface" style="width: 100%; border-radius: 12px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);"/>
      <h4>4. Interactive Chat</h4>
      <p>Natural language interface for analyzing content and getting instant feedback.</p>
    </div>
    
    <div style="flex: 1; min-width: 280px; max-width: 320px;">
      <img src="Falotestphoto/IMG_5913.PNG" alt="Voice Input" style="width: 100%; border-radius: 12px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);"/>
      <h4>5. Voice Commands</h4>
      <p>Use voice input for hands-free verification of information.</p>
    </div>
    
    <div style="flex: 1; min-width: 280px; max-width: 320px;">
      <img src="Falotestphoto/IMG_5914.PNG" alt="Analysis Results" style="width: 100%; border-radius: 12px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);"/>
      <h4>6. Detailed Analysis</h4>
      <p>Get comprehensive reports with confidence scores and evidence-based assessments.</p>
    </div>
  </div>

  <div style="margin: 40px 0; padding: 20px; background: linear-gradient(135deg, #f5f7fa 0%, #e4e8eb 100%); border-radius: 12px; max-width: 800px; margin: 40px auto;">
    <h3>📹 See Falo in Action</h3>
    <p>Interested in a live demo? Contact us to see how Falo can help combat misinformation in your workflow.</p>
    <p style="margin-top: 15px;">
      <a href="mailto:contact@falo.app" style="background-color: #4a6cf7; color: white; padding: 10px 20px; border-radius: 6px; text-decoration: none; font-weight: 500;">Request Demo</a>
    </p>
  </div>
</div>

## 📚 Documentation

For detailed technical documentation, please refer to:

- [Frontend Documentation](./Frontend/Falo/README.md) - Setup and development guide for the Flutter mobile app
- [Backend Documentation](./backend/misinfo_detection_project/README.md) - API documentation and setup instructions
- [API Reference](https://api.falo.app/docs) - Interactive API documentation (when deployed)

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

1. **Report Bugs**: Open an issue with detailed reproduction steps
2. **Suggest Features**: Share your ideas for new features
3. **Submit Pull Requests**: Follow these steps:
   - Fork the repository
   - Create a feature branch (`git checkout -b feature/amazing-feature`)
   - Commit your changes (`git commit -m 'Add amazing feature'`)
   - Push to the branch (`git push origin feature/amazing-feature`)
   - Open a Pull Request

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Special thanks to:
- The Flutter team for the amazing cross-platform framework
- The FastAPI team for the high-performance backend framework
- The open-source community for invaluable tools and libraries
- All our contributors and beta testers for their feedback

---

<div align="center" style="margin-top: 40px;">
  <p>Made with ❤️ by the Falo Team</p>
  <p>© 2025 Falo. All rights reserved.</p>
</div>