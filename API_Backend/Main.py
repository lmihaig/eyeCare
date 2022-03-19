from flask import Flask, render_template, request, send_file
from job_queue import add_to_queue, get_status
app = Flask("eyeCare API Backend")


@app.route("/api/add_job", methods=["POST", ])
def api_add_job():
    if 'file' not in request.files:
        return {
            "status": "WRONGEST"
        }

    file = request.files['file']

    id = add_to_queue()
    f = open(f"uploaded/job_{str(id)}.jpg", "wb")
    file.save(f)
    f.close()

    json = {
        "status": "REGISTERED",
        "job_id": id
    }

    return json


@app.route("/api/get_job/<job_id>", methods=["GET", ])
def api_get_job(job_id):
    if job_id.isnumeric():
        job_id = int(job_id)
    else:
        return "WRONGEST"

    if get_status(job_id):
        return {
            "status": "DONE"
        }
    else:
        return {
            "status": "PROCESSING"
        }

@app.route("/api/get_result/<job_id>", methods=["GET", ])
def api_get_result(job_id):
    if job_id.isnumeric():
        job_id = int(job_id)
    else:
        return "WRONGEST"

    if get_status(job_id):
        return send_file(f"processed/job_{str(job_id)}.jpg", mimetype='image/jpg')
    else:
        return {
            "status": "PROCESSING"
        }


@app.route("/")
def index():
    return "INDEX"


if __name__ == '__main__':
    app.run(debug=False, host="0.0.0.0", port=8008)
