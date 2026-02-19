from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def home():
    env = os.getenv('ENVIRONMENT', 'unknown')
    db_host = os.getenv('DB_HOST', 'not-set')
    debug = os.getenv('DEBUG', 'false')
    namespace = os.getenv('NAMESPACE', 'not-set')
    
    html = f"""
    <html>
    <head><title>ConfigMap Demo</title></head>
    <body style="font-family: Arial; padding: 50px;">
        <h1>🚀 ConfigMap Demo App</h1>
        <h2>Current Configuration:</h2>
        <ul>
            <li><strong>Namespace:</strong> {namespace}</li>
            <li><strong>Environment:</strong> {env}</li>
            <li><strong>Database Host:</strong> {db_host}</li>
            <li><strong>Debug Mode:</strong> {debug}</li>
        </ul>
    </body>
    </html>
    """
    return html

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
