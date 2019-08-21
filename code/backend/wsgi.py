from flask import Flask, Response

app = Flask(__name__)

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def backend(path):
	return Response(open(__file__).read(), mimetype='text/plain')
