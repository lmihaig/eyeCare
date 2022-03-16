from flask import Flask, render_template, request

app = Flask("eyeCare API Backend")

print(__name__)



@app.route("/api/add_job", methods=["POST", ])
def fname():
    print("files", request.files)
    print('file' in request.files, upload_file_name in request.files)
    if 'file' not in request.files:
        return "WRONGEST"

    file=request.files['file']

    f=open("uploaded/Photo.jpg" ,"wb")
    file.save(f)
    f.close()

    return "OK"

@app.route("/")
def index():
    return "INDEX"


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=8008)
