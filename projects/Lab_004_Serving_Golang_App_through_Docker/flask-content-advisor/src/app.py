'''An advisor on what content type to try'''
from flask import Flask
from random import randint
app = Flask(__name__)

content = ['learning path', 'lab', 'course', 'quiz']


@app.route('/')
def hello_world():
    return 'How about trying a ' + content[randint(0, 3)] + ' next'


if __name__ == '__main__':
    # Make the server publicly available by default
    app.run(debug=True, host='0.0.0.0')
