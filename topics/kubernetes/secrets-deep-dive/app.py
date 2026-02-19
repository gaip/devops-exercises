import os
from flask import Flask

app = Flask(__name__)

@app.route('/')

def home():
 app_mode = os.getenv("APP_MODE","unknown")
 db_host = os.getenv("DB_HOST", "unknown")
 db_port = os.getenv("DB_PORT", "unknown")
 db_user = os.getenv("DB_USER", "unknown")
 db_password = os.getenv("DB_PASSWORD", "unknown")
 
 html = f"""
 <html>
 <head><title>Secret Demo</title></head>
 <body style="font-family: Arial; padding: 50px;">
 <h1>🚀 Secret Demo</h1>
 <h2>Current Configuration:</h2>
 <ul>
 <li><strong>App Mode:</strong> {app_mode}</li>
 <li><strong>Database Host:</strong> {db_host}</li>
 <li><strong>Database Port:</strong> {db_port}</li>
 <li><strong>Database User:</strong> {db_user}</li>
 <li><strong>Database Password:</strong> {db_password}</li>
 </ul>
 </body>
 </html>
 """
 return html

if __name__ == '__main__':
 app.run(host='0.0.0.0', port=5000)