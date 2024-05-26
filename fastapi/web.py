from flask import Flask, jsonify, render_template
import pyodbc
import logging

app = Flask(__name__)

# Cấu hình logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
logger.addHandler(handler)

# Hàm này thiết lập và trả về kết nối đến cơ sở dữ liệu
def get_db_connection():
    return pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=127.0.0.1,1433;DATABASE=news;UID=sa;PWD=1234')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/data')
def get_data():
    try:
        # Thiết lập kết nối đến cơ sở dữ liệu
        with get_db_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM articles")
            columns = [column[0] for column in cursor.description]
            data = [dict(zip(columns, row)) for row in cursor.fetchall()]
            return jsonify(data)
    except Exception as e:
        # Ghi lại lỗi và trả về thông báo lỗi
        logger.error(f"Error occurred while fetching data: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/table')
def show_table():
    try:
        # Thiết lập kết nối đến cơ sở dữ liệu
        with get_db_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM articles")
            columns = [column[0] for column in cursor.description]
            data = [dict(zip(columns, row)) for row in cursor.fetchall()]
            return render_template('table.html', columns=columns, data=data)
    except Exception as e:
        # Ghi lại lỗi và trả về thông báo lỗi
        logger.error(f"Error occurred while fetching data: {str(e)}")
        return render_template('error.html', error=str(e))

@app.route('/chart')
def show_chart():
    return render_template('chart.html')

if __name__ == "__main__":
    app.run(debug=True)