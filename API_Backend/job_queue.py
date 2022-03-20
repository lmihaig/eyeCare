import threading
import os
import time
from procesare import highlight


print()
print([(filename, os.remove("uploaded/"+filename))[0] for filename in os.listdir("uploaded") if(filename!=".gitkeep")])
print()

global last_id
last_id=0
global last_completed
last_completed=0
get_last_completed=lambda :last_completed

job_queue=[]
job_statuses={}

class Job:
    def __init__(self, id, isDone):
        self.id = id
        self.isDone = isDone


def add_to_queue():
    global last_id
    last_id+=1

    job=Job(last_id, False)
    job_queue.append(job)
    job_statuses[last_id]=job
    return last_id


def get_status(job_id):
    return job_id in job_statuses and job_statuses[job_id].isDone

def get_info(job_id):
    if(get_status(job_id)):
        return {}

def queue_function():
    print("Started queue thread")
    global last_completed
    while True:
        if(len(job_queue) != 0):

            #   TEMP
            job=job_queue.pop(0)
            # time.sleep(20)
            jpg_name=f"job_{str(job.id)}.jpg"
            highlight(f"uploaded/{jpg_name}", f"processed/{jpg_name}")
            job.isDone=True
            last_completed=job.id
            print("'finished'", job.id)
            #
        else:
            time.sleep(1)

queue_thread=threading.Thread(target=queue_function, args=())
queue_thread.start()
