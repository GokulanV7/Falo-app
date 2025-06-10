# Falo Backend

This is the backend service for the Falo application, responsible for misinformation detection and content analysis.

## 🚀 Features

- **Misinformation Detection**: Analyze and detect potential misinformation in content
- **RAG Integration**: Utilizes Retrieval-Augmented Generation for enhanced information verification
- **RSS Feed Processing**: Automatically ingest and process news from RSS feeds
- **API Endpoints**: RESTful API for frontend integration
- **Logging**: Comprehensive logging for monitoring and debugging

## 🛠️ Prerequisites

- Python 3.12.3+
- pip (Python package manager)
- Virtual environment (recommended)

## 🚦 Installation

1. **Clone the repository**
   ```bash
   git clone [your-repository-url]
   cd backend/misinfo_detection_project
   ```

2. **Create and activate a virtual environment**
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows use: .venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**
   Create a `.env` file in the project root and add necessary environment variables:
   ```
   # API Configuration
   DEBUG=True
   SECRET_KEY=your-secret-key
   
   # Database Configuration
   DATABASE_URL=sqlite:///./falo.db
   
   # Model Configuration
   MODEL_CACHE_DIR=./model_cache
   ```

## 🚀 Running the Application

1. **Start the API server**
   ```bash
   uvicorn api.main:app --reload
   ```

2. **Access the API documentation**
   - Swagger UI: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

## 📂 Project Structure

```
backend/
├── api/                  # API endpoints and routes
├── config/               # Configuration files
├── data/                 # Data files and datasets
├── logs/                 # Application logs
├── model_cache/          # Cached ML models
├── .gitignore
├── README.md
├── requirements.txt      # Python dependencies
└── rss_feed_ingestor.py  # RSS feed processing script
```

## 📊 API Endpoints

- `POST /api/analyze` - Analyze content for misinformation
- `GET /api/feed` - Get processed feed items
- `POST /api/verify` - Verify specific claims

## 🤖 Development

### Running Tests
```bash
pytest
```

### Code Style
This project uses `black` for code formatting and `flake8` for linting:
```bash
black .
flake8
```

## 📝 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments
- Built with FastAPI
- Uses HuggingFace Transformers for NLP tasks
- Vector database for efficient information retrieval
