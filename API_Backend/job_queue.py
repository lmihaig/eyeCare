import threading
import os
import time


print()
print([(filename, os.remove("uploaded/"+filename))[0] for filename in os.listdir("uploaded") if(filename!=".gitkeep")])
print()

global last_id
last_id=0

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
    while True:
        if(len(job_queue) != 0):

            #   TEMP
            job=job_queue.pop(0)
            time.sleep(20)
            job.isDone=True
            print("'finished'", job.id)
            #
        else:
            time.sleep(1)

queue_thread=threading.Thread(target=queue_function, args=())
queue_thread.start()
