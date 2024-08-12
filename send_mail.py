import sys

script_name, par1, par2, par3 = sys.argv

if len(sys.argv) < 4:
    sys.exit(255)

import smtplib
import mimetypes
from email.mime.multipart import MIMEMultipart
from email import encoders
from email.message import Message
from email.mime.audio import MIMEAudio
from email.mime.base import MIMEBase
from email.mime.image import MIMEImage
from email.mime.text import MIMEText

emailfrom = "your_mail@domain.tld"
emailto = par1.split(",")

username = "your_mail@domain.tld"
password = "*************"

msg = MIMEMultipart()
msg["From"] = emailfrom
msg["To"] = ",".join(emailto)
msg["Subject"] = par2

body = par3
msg.attach(MIMEText(body,'plain'))

#using TLS (comment out next two rows if use SSL)
server = smtplib.SMTP("smtp.domain.tld", 587)
server.starttls()

#using SSL (uncomment next row if use SSL)
#server = smtplib.SMTP_SSL('smtp.domain.tld', 465)

server.login(username,password)
server.set_debuglevel(0)
status = server.sendmail(emailfrom, emailto, msg.as_string())
server.quit()

if len(status) == 0:
    sys.exit(0)
else:
    sys.exit(status)
