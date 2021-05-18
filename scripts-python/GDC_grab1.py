#! /Library/Frameworks/Python.framework/Versions/3.9/bin/python3

import requests
import json
import re

data_endpt = "https://api.gdc.cancer.gov/data"

ids = [
    "766f7127-6dde-456e-9553-b2655b5c5c1b"
    ]

params = {"ids": ids}

response = requests.post(data_endpt,
                        data = json.dumps(params),
                        headers={
                            "Content-Type": "application/json"
                            })

response_head_cd = response.headers["Content-Disposition"]

file_name = re.findall("filename=(.+)", response_head_cd)[0]

with open(file_name, "wb") as output_file:
    output_file.write(response.content)
